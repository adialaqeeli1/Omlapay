import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations_from_storage.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../core/models/send_confirm_model/send_confirm_response_model.dart';
import '../../../../core/models/send_quote_model/send_quote_model.dart';
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
      recipientController.text = initialRecipient;
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
  bool _isFetchingQuote = false;
  Timer? _quoteDebounceTimer;
  int _quoteRequestId = 0;
  String? _lastQuoteKey;
  static const Duration _quoteDebounce = Duration(milliseconds: 500);

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
      amountController.text.isNotEmpty &&
      recipientController.text.trim().isNotEmpty &&
      isVerified;

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
    _scheduleQuoteFetch();
  }

  void setSelectedContact(ContactModel contact) {
    _selectedContact = contact;
    recipientController.text = contact.phoneNumber;
    notifyListeners();
  }

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    notifyListeners();
  }

  void setMaxAmount() {
    if (_selectedCoin == null) return;
    amountController.text = walletsProvider
        .balanceForCoin(_selectedCoin!.symbol)
        .replaceAll(',', '');
    _validate();
  }

  /// Runs the send pre-flight: validate-address then fetch-quote.
  ///
  /// Returns `true` when the review screen is safe to open. On failure the
  /// backend's localized message is exposed via [submitError] so the caller
  /// can surface it (e.g. via a snackbar) and stay on the send form.
  Future<bool> prepareSendReview() async {
    if (_isSubmitting) return false;
    final coin = _selectedCoin;
    if (coin == null) return false;

    final recipient = recipientController.text.trim();
    final amount = amountController.text.trim();
    if (recipient.isEmpty || amount.isEmpty) return false;

    _submitError = null;
    _isSubmitting = true;
    notifyListeners();

    try {
      await SendService.validateAddress(coin: coin.symbol, address: recipient);
      _quote = await SendService.fetchQuote(
        coin: coin.symbol,
        recipient: recipient,
        amount: amount,
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

    final recipient = recipientController.text.trim();
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (recipient.isEmpty || amount == null) return null;

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
  /// Returns `false` when the backend rejects the OTP, setting [hasOtpError]
  /// so the OTP input renders its error state. Non-OTP API failures are
  /// rethrown as [AppException] so the view can show an error snackbar.
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
    } on AppException {
      _hasOtpError = true;
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
    _error = null;
    final text = amountController.text;
    if (text.isEmpty) {
      _scheduleQuoteFetch();
      notifyListeners();
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      _error = l10n.sendValidationInvalidAmount;
    } else if (_selectedCoin != null) {
      final min = minSendAmount;
      final balanceStr = walletsProvider
          .balanceForCoin(_selectedCoin!.symbol)
          .replaceAll(',', '');
      final balance = double.tryParse(balanceStr) ?? 0.0;

      if (min > 0 && amount < min) {
        _error = l10n.sendValidationBelowMinimum(min.toString());
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
    final recipient = recipientController.text.trim();
    final amountText = amountController.text.trim();
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
      if (_quote != null || _isFetchingQuote) {
        _quote = null;
        _isFetchingQuote = false;
        notifyListeners();
      }
      return;
    }

    final key = '${coin.symbol}|$network|$recipient|$amountText';
    if (key == _lastQuoteKey) return;
    _lastQuoteKey = key;

    _quoteDebounceTimer?.cancel();
    // Drop any prior quote and start the loader immediately so the fee row
    // shows a spinner during the debounce window instead of stale data.
    _quote = null;
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
    } catch (_) {
      if (requestId != _quoteRequestId) return;
      _quote = null;
    } finally {
      if (requestId == _quoteRequestId) {
        _isFetchingQuote = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _quoteDebounceTimer?.cancel();
    _coinsPricesProvider.removeListener(_onStreamedCoinsUpdated);
    authProvider.removeListener(notifyListeners);
    amountController.dispose();
    recipientController.dispose();
    networkController.dispose();
    super.dispose();
  }
}
