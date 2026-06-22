import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/extentions/number_extensions.dart';
import '../../../../core/extentions/string_extensions.dart';
import '../../../../core/l10n/app_localizations_from_storage.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../core/models/send_confirm_model/send_confirm_response_model.dart';
import '../../../../core/models/send_quote_model/send_quote_model.dart';
import '../../../../core/models/send_validate_address_model/send_validate_address_model.dart';
import '../../../../core/services/chain_resolver_service.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../../../../providers/wallets_provider.dart';
import '../services/send_service.dart';

class SendProvider extends ChangeNotifier {
  SendProvider(
    this.authProvider,
    this._coinsPricesProvider,
    this.walletsProvider, {
    String? initialCoinSymbol,
    String? initialRecipient,
    String? initialAmount,
  }) {
    networkController = TextEditingController();

    // Apply initial state before syncing coins so the first sync picks the
    // pre-selected coin instead of defaulting to the first entry, and so the
    // pre-filled recipient/amount are in place before _syncCoinsFromPrices()
    // triggers the first _validate().
    final trimmedSymbol = initialCoinSymbol?.trim() ?? '';
    if (trimmedSymbol.isNotEmpty) {
      _userPickedCoin = true;
      _userPickedSymbol = trimmedSymbol.toUpperCase();
    }
    if (initialRecipient != null && initialRecipient.isNotEmpty) {
      recipientController.text = initialRecipient.trim().removeAllWhitespace;
    }
    if (initialAmount != null && initialAmount.isNotEmpty) {
      amountController.text = initialAmount;
    }

    authProvider.addListener(notifyListeners);
    _coinsPricesProvider.addListener(_onStreamedCoinsUpdated);
    _syncCoinsFromPrices();
    amountController.addListener(_validate);
    recipientController.addListener(() {
      if (_selectedContact != null &&
          recipientController.text != _selectedContact!.phoneNumber) {
        // Selection is mainly via sheet; manual entry can diverge from stored contact.
      }
      _scheduleAddressValidation();
      _scheduleQuoteFetch();
      notifyListeners();
    });
  }

  final AuthProvider authProvider;
  final CoinsPricesProvider _coinsPricesProvider;
  final WalletsProvider walletsProvider;

  List<CoinModel> _coins = [];
  bool _isLoading = false;

  CoinModel? _selectedCoin;
  ContactModel? _selectedContact;

  bool _isSubmitting = false;
  String? _submitError;
  SendQuoteModel? _quote;
  // Localized error from the live quote call (e.g. "Insufficient balance"),
  // shown under the amount field and blocking [canSend]; `null` when valid.
  String? _quoteError;
  bool _isFetchingQuote = false;
  Timer? _quoteDebounceTimer;
  int _quoteRequestId = 0;
  String? _lastQuoteKey;
  static const Duration _quoteDebounce = Duration(milliseconds: 500);

  // Reactive recipient validation (validate-address). Holds the localized
  // reason the recipient is rejected (self-transfer, or a backend address
  // validation error such as an address/network mismatch); `null` when valid.
  // A non-null value disables [canSend] and surfaces via [recipientError].
  String? _recipientError;
  Timer? _addressDebounceTimer;
  int _addressRequestId = 0;
  String? _lastValidatedAddressKey;
  static const Duration _addressDebounce = Duration(milliseconds: 500);

  // OTP / confirm flow state.
  String? _sendToken;
  int _otpCountdown = 0;
  Timer? _otpTimer;
  bool _isOtpSubmitting = false;
  bool _hasOtpError = false;
  int? _remainingResends;
  String _otpInput = '';
  SendConfirmResponseModel? _confirmResponse;
  String? _confirmMessage;

  /// After the user picks a coin in the sheet, we keep that symbol across SSE updates.
  bool _userPickedCoin = false;
  String? _userPickedSymbol;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  late final TextEditingController networkController;

  String? _error;

  // Getters
  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  CoinModel? get selectedCoin => _selectedCoin;
  ContactModel? get selectedContact => _selectedContact;
  String? get error => _error;
  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  String get network => networkController.text;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  SendQuoteModel? get quote => _quote;
  bool get isFetchingQuote => _isFetchingQuote;
  double get minSendAmount =>
      double.tryParse(
        _selectedCoin?.minSendAmount ?? _selectedCoin?.minDeposit ?? '0',
      ) ??
      0;
  double get maxSendAmount =>
      double.tryParse(
        _selectedCoin?.maxSendAmount ?? _selectedCoin?.minDeposit ?? '0',
      ) ??
      0;

  // OTP / confirm getters.
  String? get sendToken => _sendToken;
  int get otpCountdown => _otpCountdown;
  bool get canResendOtp => _otpCountdown <= 0;
  bool get isOtpSubmitting => _isOtpSubmitting;
  bool get hasOtpError => _hasOtpError;
  int? get remainingResends => _remainingResends;
  String get otpInput => _otpInput;
  SendConfirmResponseModel? get confirmResponse => _confirmResponse;
  String? get confirmMessage => _confirmMessage;

  /// Stores the latest OTP the user has typed in the verification screen.
  /// Clears any prior verification error flag to reset the UI state.
  void setOtpInput(String value) {
    _otpInput = value;
    if (_hasOtpError) {
      _hasOtpError = false;
      notifyListeners();
    }
  }

  // Logic for showing warning:
  // Show if the user has NOT completed verification
  bool get showVerificationWarning => !isVerified;

  // Logic for enabling Send button:
  // 1. Amount is valid
  // 2. Contact is selected
  // 3. No errors
  // 4. User is verified
  bool get canSend =>
      _error == null &&
      _recipientError == null &&
      _quoteError == null &&
      amountController.text.isNotEmpty &&
      recipientController.text.trim().isNotEmpty &&
      isVerified;

  /// Localized error returned by the live quote call (e.g. "Insufficient
  /// balance"), to display under the amount field; `null` when the quote is
  /// valid or not yet attempted.
  String? get quoteError => _quoteError;

  /// Localized recipient validation error to display under the recipient
  /// field, or `null` when the recipient is valid. Covers self-transfers and
  /// backend address/network validation rejections.
  String? get recipientError => _recipientError;

  /// Updates the recipient validation error, notifying only on change.
  void _setRecipientError(String? value) {
    if (_recipientError == value) return;
    _recipientError = value;
    notifyListeners();
  }

  /// Coin symbols the last `validate-address` call reported as valid for the
  /// current recipient (e.g. `["ETH", "BNB"]` for an EVM address). Empty when no
  /// address has validated. Used by the coin selection sheet only to decide
  /// which coin rows to badge, and only when ambiguous (2+ candidates).
  List<String> _candidateSymbols = const [];
  List<String> get candidateSymbols => _candidateSymbols;

  /// The backend's resolved `coin` for the validated address (e.g. `"ETH"`).
  /// The coin selection sheet renders this single coin's icon as the badge on
  /// every candidate row; `null` when no address has validated.
  String? _candidateCoinSymbol;
  String? get candidateCoinSymbol => _candidateCoinSymbol;

  /// Updates the validated candidates and resolved coin, notifying on change.
  void _setCandidates(List<String> symbols, String? coinSymbol) {
    final sameList =
        _candidateSymbols.length == symbols.length &&
        _candidateSymbols.asMap().entries.every(
          (e) => e.value == symbols[e.key],
        );
    if (sameList && _candidateCoinSymbol == coinSymbol) return;
    _candidateSymbols = symbols;
    _candidateCoinSymbol = coinSymbol;
    notifyListeners();
  }

  void _onStreamedCoinsUpdated() {
    _syncCoinsFromPrices();
  }

  /// Mirrors [CoinsPricesProvider.coins] (SSE) into the send flow list.
  void _syncCoinsFromPrices() {
    final incoming = _coinsPricesProvider.coins;
    _isLoading = _coinsPricesProvider.isLoading && incoming.isEmpty;
    // Sort by fiat balance (highest first) so the list — and therefore the
    // default `_coins.first` selection — matches the home assets list and the
    // coin picker sheet.
    _coins = walletsProvider.sortByFiatBalanceDesc(incoming);

    if (_coins.isEmpty) {
      _selectedCoin = null;
      _validate();
      return;
    }

    if (!_userPickedCoin) {
      _selectedCoin = _coins.first;
    } else {
      final key = (_userPickedSymbol ?? _selectedCoin?.symbol ?? '')
          .trim()
          .toUpperCase();
      CoinModel? match;
      if (key.isNotEmpty) {
        for (final c in _coins) {
          if (c.symbol.toUpperCase() == key) {
            match = c;
            break;
          }
        }
      }
      _selectedCoin = match ?? _coins.first;
    }

    _updateNetwork();
    _validate();
  }

  void _updateNetwork() {
    networkController.text = _selectedCoin?.network ?? '';
  }

  void setSelectedCoin(CoinModel coin) {
    _userPickedCoin = true;
    _userPickedSymbol = coin.symbol;
    _selectedCoin = coin;
    _updateNetwork();
    _validate();
    _scheduleAddressValidation();
    _scheduleQuoteFetch();
  }

  void setSelectedContact(ContactModel contact) {
    _selectedContact = contact;
    recipientController.text = contact.phoneNumber.trim().removeAllWhitespace;
    _scheduleAddressValidation();
    notifyListeners();
  }

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    notifyListeners();
  }

  void setMaxAmount() {
    final coin = _selectedCoin;
    if (coin == null) return;
    // Fill with the balance truncated to the display precision. This same
    // truncated value is what gets sent to the API, so what the user sees
    // matches what is sent (see [_amountForApi]).
    amountController.text = walletsProvider
        .rawBalanceForCoin(coin.symbol)
        .toInputAmount();
    _validate();
  }

  /// The amount string to send to the API: the field value truncated (floored
  /// toward zero) to the coin display precision with no thousands grouping, so
  /// what we send always matches the value the user sees. Falls back to the raw
  /// text when it isn't a parseable number.
  String get _amountForApi {
    final text = amountController.text.trim();
    final parsed = double.tryParse(text);
    if (parsed == null) return text;
    return parsed.toInputAmount();
  }

  /// The recipient string to send to the backend with all whitespace stripped.
  /// Contact numbers are stored formatted (e.g. "+966 54 076 8260"); the spaces
  /// survive `.trim()` and break address validation, so remove them here while
  /// keeping the field display formatted.
  String get _recipientForApi => recipientController.text.removeAllWhitespace;

  /// Runs the send pre-flight: validate-address then fetch-quote.
  ///
  /// Returns `true` when the review screen is safe to open. On failure the
  /// backend's localized message is exposed via [submitError] so the caller
  /// can surface it (e.g. via a snackbar) and stay on the send form.
  Future<bool> prepareSendReview() async {
    if (_isSubmitting) return false;
    final coin = _selectedCoin;
    if (coin == null) return false;

    final recipient = _recipientForApi;
    final amount = amountController.text.trim();
    if (recipient.isEmpty || amount.isEmpty) return false;

    _submitError = null;
    _isSubmitting = true;
    notifyListeners();

    try {
      final validation = await SendService.validateAddress(
        coin: coin.symbol,
        address: recipient,
      );
      // Final guard: block self-transfers even if the reactive check raced.
      if (validation.isSelf) {
        final message =
            appLocalizationsFromStoredLocale().sendValidationCannotSendToSelf;
        _setRecipientError(message);
        _submitError = message;
        return false;
      }
      _setRecipientError(null);
      _quote = await SendService.fetchQuote(
        coin: coin.symbol,
        recipient: recipient,
        amount: _amountForApi,
      );
      return true;
    } on AppException catch (e) {
      final l10n = appLocalizationsFromStoredLocale();
      _submitError = e.localizedMessage(l10n);
      return false;
    } catch (_) {
      _submitError = appLocalizationsFromStoredLocale().unknownError;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearSubmitError() {
    if (_submitError == null) return;
    _submitError = null;
    notifyListeners();
  }

  /// Initiates the send and triggers an OTP to the user's phone.
  ///
  /// Returns the backend-localized success message on success (possibly an
  /// empty string if the backend didn't include one). Returns `null` when
  /// pre-flight validation prevents the call. Throws [AppException] on API
  /// failures so the view can surface the localized error via a snackbar.
  Future<String?> initiateSend() async {
    if (_isSubmitting) return null;
    final coin = _selectedCoin;
    if (coin == null) return null;

    final recipient = _recipientForApi;
    if (recipient.isEmpty || amountController.text.trim().isEmpty) return null;
    // Send the amount truncated to the display precision (see [_amountForApi]).
    final amount = double.tryParse(_amountForApi);
    if (amount == null) return null;

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await SendService.initiateSend(
        coin: coin.symbol,
        recipient: recipient,
        amount: amount,
        network: networkController.text.trim().isEmpty
            ? coin.symbol
            : networkController.text.trim(),
      );
      _sendToken = result.data.sendToken;
      _startOtpCountdown(result.data.otpExpirySeconds);
      return result.message ?? '';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Requests a fresh OTP for the ongoing send flow.
  ///
  /// Returns the backend-localized success message on success. Returns `null`
  /// when pre-flight conditions block the call (no token, countdown active).
  /// Throws [AppException] on API failures.
  Future<String?> resendSendOtp() async {
    final token = _sendToken;
    if (token == null || token.isEmpty) return null;
    if (_otpCountdown > 0) return null;

    try {
      final result = await SendService.resendOtp(sendToken: token);
      _sendToken = result.data.sendToken;
      _remainingResends = result.data.remainingResends;
      _startOtpCountdown(result.data.otpExpirySeconds);
      return result.message ?? '';
    } finally {
      notifyListeners();
    }
  }

  /// Submits the OTP to confirm the send.
  ///
  /// Returns `true` on success (and stores the queued transaction in
  /// [confirmResponse] plus the backend success message in [confirmMessage]).
  /// All backend failures are rethrown as [AppException] so the view can show
  /// an error snackbar. Only an actual OTP rejection ([AppException.isInvalidOtp])
  /// additionally sets [hasOtpError] so the OTP input renders its error state;
  /// unrelated failures (e.g. "Transfer failed.") leave the OTP field untouched.
  Future<bool> confirmSendWithOtp(String otp) async {
    final token = _sendToken;
    if (token == null || token.isEmpty) return false;
    if (_isOtpSubmitting) return false;

    _hasOtpError = false;
    _isOtpSubmitting = true;
    notifyListeners();

    try {
      final result = await SendService.confirmSend(sendToken: token, otp: otp);
      _confirmResponse = result.data;
      _confirmMessage = result.message;
      _stopOtpCountdown();
      return true;
    } on AppException catch (e) {
      // Only flag the OTP input as invalid when the backend actually rejected
      // the OTP. Other failures (e.g. "Transfer failed. Please try again.")
      // surface via the error snackbar instead of falsely marking the OTP.
      _hasOtpError = e.isInvalidOtp;
      rethrow;
    } finally {
      _isOtpSubmitting = false;
      notifyListeners();
    }
  }

  void _startOtpCountdown(int seconds) {
    _otpTimer?.cancel();
    _otpCountdown = seconds;
    notifyListeners();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown <= 1) {
        timer.cancel();
        _otpCountdown = 0;
      } else {
        _otpCountdown -= 1;
      }
      notifyListeners();
    });
  }

  void _stopOtpCountdown() {
    _otpTimer?.cancel();
    _otpTimer = null;
    _otpCountdown = 0;
  }

  void _validate() {
    final l10n = appLocalizationsFromStoredLocale();
    final text = amountController.text;

    _error = null;
    if (text.isEmpty) {
      _scheduleQuoteFetch();
      notifyListeners();
      return;
    }

    final displayAmount = double.tryParse(text);
    if (displayAmount == null) {
      _error = l10n.sendValidationInvalidAmount;
    } else if (_selectedCoin != null) {
      // Validate against the value actually sent (truncated to the display
      // precision) and the real, unrounded wallet balance.
      final amount = double.tryParse(_amountForApi) ?? displayAmount;
      final min = minSendAmount;
      final balance = walletsProvider.rawBalanceForCoin(_selectedCoin!.symbol);

      if (min > 0 && amount < min) {
        _error = l10n.sendValidationBelowMinimum(min.toFormattedMinAmount());
      } else if (amount > balance) {
        _error = l10n.sendValidationInsufficientBalance;
      }
    }
    _scheduleQuoteFetch();
    notifyListeners();
  }

  /// Debounces a fetch of the live send quote so the fee preview in the
  /// send footer stays in sync with the form. The API is only hit once all
  /// of {coin, network, recipient, amount} are present, the amount parses
  /// to a positive number, and there is no validation error blocking it.
  /// Repeated invocations with identical inputs (e.g. SSE price ticks that
  /// re-run validation) are deduped via [_lastQuoteKey] so the quote API is
  /// only hit when the user actually changes the form.
  void _scheduleQuoteFetch() {
    final coin = _selectedCoin;
    final recipient = _recipientForApi;
    // Quote against the exact value we'll send (truncated to display precision).
    final amountText = _amountForApi;
    final amount = double.tryParse(amountText);
    final network = networkController.text.trim();

    final hasAllInputs =
        coin != null &&
        recipient.isNotEmpty &&
        amountText.isNotEmpty &&
        network.isNotEmpty &&
        amount != null &&
        amount > 0 &&
        _error == null;

    if (!hasAllInputs) {
      _quoteDebounceTimer?.cancel();
      _lastQuoteKey = null;
      if (_quote != null || _isFetchingQuote || _quoteError != null) {
        _quote = null;
        _isFetchingQuote = false;
        _quoteError = null;
        notifyListeners();
      }
      return;
    }

    final key = '${coin.symbol}|$network|$recipient|$amountText';
    if (key == _lastQuoteKey) return;
    _lastQuoteKey = key;

    _quoteDebounceTimer?.cancel();
    // Drop any prior quote/error and start the loader immediately so the fee
    // row shows a spinner during the debounce window instead of stale data.
    _quote = null;
    _quoteError = null;
    _isFetchingQuote = true;
    notifyListeners();
    _quoteDebounceTimer = Timer(_quoteDebounce, () {
      _fetchQuote(coin: coin, recipient: recipient, amount: amountText);
    });
  }

  Future<void> _fetchQuote({
    required CoinModel coin,
    required String recipient,
    required String amount,
  }) async {
    final requestId = ++_quoteRequestId;
    _isFetchingQuote = true;
    notifyListeners();

    try {
      final result = await SendService.fetchQuote(
        coin: coin.symbol,
        recipient: recipient,
        amount: amount,
      );
      if (requestId != _quoteRequestId) return;
      _quote = result;
      _quoteError = null;
    } on AppException catch (e) {
      if (requestId != _quoteRequestId) return;
      _quote = null;
      // Surface real backend rejections (e.g. "Insufficient balance.") under
      // the amount field and block the send. Transient network/transport
      // errors fail open so a flaky quote doesn't blanket-block the form.
      _quoteError = e.messageKey == 'requestFailed'
          ? e.localizedMessage(appLocalizationsFromStoredLocale())
          : null;
    } catch (_) {
      if (requestId != _quoteRequestId) return;
      _quote = null;
      _quoteError = null;
    } finally {
      if (requestId == _quoteRequestId) {
        _isFetchingQuote = false;
        notifyListeners();
      }
    }
  }

  /// Debounces a `validate-address` call to surface recipient errors
  /// ([recipientError]) — self-transfers and backend address/network
  /// rejections. Runs as soon as a coin and a non-empty recipient are present
  /// (independent of the amount). Identical inputs are deduped via
  /// [_lastValidatedAddressKey].
  void _scheduleAddressValidation() {
    final coin = _selectedCoin;
    final recipient = _recipientForApi;

    if (coin == null || recipient.isEmpty) {
      _addressDebounceTimer?.cancel();
      _lastValidatedAddressKey = null;
      // Invalidate any stale request so a late response can't re-flag.
      _addressRequestId++;
      _setRecipientError(null);
      _setCandidates(const [], null);
      return;
    }

    final key = '${coin.symbol}|$recipient';
    if (key == _lastValidatedAddressKey) return;
    _lastValidatedAddressKey = key;

    _addressDebounceTimer?.cancel();
    _addressDebounceTimer = Timer(_addressDebounce, () {
      _validateRecipientAddress(coin: coin, recipient: recipient);
    });
  }

  Future<void> _validateRecipientAddress({
    required CoinModel coin,
    required String recipient,
  }) async {
    final requestId = ++_addressRequestId;
    try {
      final result = await SendService.validateAddress(
        coin: coin.symbol,
        address: recipient,
      );
      if (requestId != _addressRequestId) return;
      if (result.isSelf) {
        _setRecipientError(
          appLocalizationsFromStoredLocale().sendValidationCannotSendToSelf,
        );
        _setCandidates(const [], null);
        return;
      }
      _setRecipientError(null);
      _applyValidatedAddressMetadata(result);
    } on AppException catch (e) {
      if (requestId != _addressRequestId) return;
      // A `requestFailed` here is a real backend validation rejection — most
      // often the address doesn't match the selected coin/network. Before
      // surfacing it, fall back to resolving the address's chain via
      // blockchain.com and auto-switching to the matching coin; the
      // rescheduled validation then confirms the address against the right
      // coin. Only switch when the resolved coin differs from the current
      // selection (which also prevents a switch loop). Transient
      // network/transport errors fail open — the on-tap pre-flight in
      // [prepareSendReview] re-checks before proceeding.
      if (e.messageKey == 'requestFailed') {
        final switched = await _trySwitchCoinForResolvedChain(
          recipient: recipient,
          requestId: requestId,
        );
        if (switched) return;
        _setRecipientError(
          e.localizedMessage(appLocalizationsFromStoredLocale()),
        );
        _setCandidates(const [], null);
      } else {
        _setRecipientError(null);
      }
    } catch (_) {
      if (requestId != _addressRequestId) return;
      _setRecipientError(null);
    }
  }

  /// Resolves [recipient]'s chain via blockchain.com and, when it maps to a
  /// known coin different from the current selection, switches to it so the
  /// address validates against the right coin/network.
  ///
  /// Returns `true` when it either switched coins or the request was
  /// superseded by a newer validation (caller should stop and let that one own
  /// the outcome); `false` when no usable coin could be resolved so the caller
  /// surfaces the original rejection. The lookup is cached, so a chain resolved
  /// while scanning the QR is reused here without an extra round-trip.
  Future<bool> _trySwitchCoinForResolvedChain({
    required String recipient,
    required int requestId,
  }) async {
    final chain = await ChainResolverService.resolveChain(recipient);
    // A newer validation started while resolving — let it own the outcome.
    if (requestId != _addressRequestId) return true;
    if (chain == null || chain.isEmpty) return false;

    final match = _coinForSymbol(chain);
    if (match == null) return false;
    if (match.symbol.toUpperCase() == _selectedCoin?.symbol.toUpperCase()) {
      return false;
    }

    setSelectedCoin(match);
    return true;
  }

  /// Aligns the form's coin and network with a successfully validated address.
  ///
  /// - Coin: keeps the user's selection when it is still a valid candidate;
  ///   otherwise falls back to the backend's [guessedCoin]/[coin] when it maps
  ///   to an available coin. When the plural [candidates] list is empty, the
  ///   singular resolved [coin] is used as the sole candidate.
  /// - Network: prefers the entry from [networks] matching the selected coin's
  ///   network, else the first network the backend returned; when [networks]
  ///   is empty it falls back to the singular [network].
  void _applyValidatedAddressMetadata(SendValidateAddressModel result) {
    var changed = false;

    // Coin — only switch away from the user's selection when it isn't a valid
    // candidate for this address (on a 200 the selection is usually valid, so
    // this rarely fires; it mainly handles a raw address with a stale coin).
    final candidates = result.candidates
        .map((c) => c.trim().toUpperCase())
        .where((c) => c.isNotEmpty)
        .toSet();
    // Fallback: when the backend omits the plural `candidates` list it still
    // returns the resolved coin in the singular `coin` field (e.g. a SOL
    // address validated while ETH was selected comes back as `coin: "SOL"`
    // with an empty `candidates`). Fold it in so the selection is corrected
    // instead of an empty list being treated as "any coin is valid".
    if (candidates.isEmpty) {
      final resolvedCoin = result.coin?.trim().toUpperCase();
      if (resolvedCoin != null && resolvedCoin.isNotEmpty) {
        candidates.add(resolvedCoin);
      }
    }
    // Expose the validated candidates (for matching rows) and the resolved
    // `coin` (rendered as the badge icon) so the coin selection sheet can badge
    // the matching coins. Only acts on this when there are 2+ — see the sheet.
    _setCandidates(candidates.toList(), result.coin?.trim().toUpperCase());
    final currentSymbol = _selectedCoin?.symbol.toUpperCase();
    final selectionIsValid =
        currentSymbol != null &&
        (candidates.isEmpty || candidates.contains(currentSymbol));
    if (!selectionIsValid) {
      final targetSymbol = (result.guessedCoin ?? result.coin)
          ?.trim()
          .toUpperCase();
      if (targetSymbol != null && targetSymbol.isNotEmpty) {
        final match = _coinForSymbol(targetSymbol);
        if (match != null && match.symbol != _selectedCoin?.symbol) {
          _selectedCoin = match;
          _userPickedCoin = true;
          _userPickedSymbol = match.symbol;
          _updateNetwork();
          _lastValidatedAddressKey = '${match.symbol}|$_recipientForApi';
          changed = true;
        }
      }
    }

    // Network — populate from the authoritative networks the backend returned,
    // preferring the one matching the (possibly updated) selected coin.
    final networks = result.networks
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    // Fallback: when the plural `networks` list is empty, use the singular
    // `network` the backend resolved for the address (the common
    // INTERNAL-recipient case, e.g. `network: "SOL"`).
    if (networks.isEmpty) {
      final single = result.network?.trim();
      if (single != null && single.isNotEmpty) networks.add(single);
    }
    if (networks.isNotEmpty) {
      final coinNetwork = _selectedCoin?.network?.trim();
      final matched = coinNetwork != null && coinNetwork.isNotEmpty
          ? networks.firstWhere(
              (n) => n.toUpperCase() == coinNetwork.toUpperCase(),
              orElse: () => networks.first,
            )
          : networks.first;
      if (networkController.text != matched) {
        networkController.text = matched;
        changed = true;
      }
    }

    // [_validate] re-runs amount checks, reschedules the quote with the new
    // coin/network, and notifies listeners.
    if (changed) _validate();
  }

  CoinModel? _coinForSymbol(String symbol) {
    final key = symbol.trim().toUpperCase();
    for (final coin in _coins) {
      if (coin.symbol.toUpperCase() == key) return coin;
    }
    return null;
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _quoteDebounceTimer?.cancel();
    _addressDebounceTimer?.cancel();
    _coinsPricesProvider.removeListener(_onStreamedCoinsUpdated);
    authProvider.removeListener(notifyListeners);
    amountController.dispose();
    recipientController.dispose();
    networkController.dispose();
    super.dispose();
  }
}
