// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Omlapay';

  @override
  String get login => 'Login';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get pleaseLoginToContinue => 'Please login first to continue';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get welcomeToOmlaPay => 'Welcome to Omlapay';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterAValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'Password must be at least 6 characters';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get welcomeHome => 'Welcome Home';

  @override
  String get homeScreen => 'Home Screen';

  @override
  String get historyScreen => 'History Screen';

  @override
  String get profileScreen => 'Profile Screen';

  @override
  String get logout => 'Logout';

  @override
  String get kycVerification => 'KYC Verification';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get aboutOmlapay => 'About Omlapay';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'ACCOUNT';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get changePhoneNumber => 'Change Phone Number';

  @override
  String get stepsForChangingPhoneNumber =>
      'Steps for changing your Phone Number';

  @override
  String get changePhoneStepsDescription =>
      'To change your registered phone number, follow these steps:';

  @override
  String get changePhoneStep1 =>
      'Verify your current registered phone number with a verification code.';

  @override
  String get changePhoneStep2 =>
      'Enter your new phone number (the one you want to use for your account).';

  @override
  String get changePhoneStep3 =>
      'Verify your new phone number with a verification code.';

  @override
  String get changePhoneStep4 =>
      'Verify your account with a passcode to confirm the changes.';

  @override
  String get changePhoneAfterStepsNote =>
      'After you verify the code, your account will use the new phone number.';

  @override
  String get changePhoneEnterNewSubtitle =>
      'After you continue, we will send a verification code to this number.';

  @override
  String get enterNewPhoneNumber => 'Enter new phone number';

  @override
  String get verifyNewPhoneNumber => 'Verify new phone number';

  @override
  String changePhoneCurrentOtpSent(String phone) {
    return 'An 6 digit verification code has been sent via WhatsApp to $phone.';
  }

  @override
  String changePhoneNewOtpSent(String phone) {
    return 'A 6-digit verification code was sent to $phone.';
  }

  @override
  String get enterValidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get phoneNumberChangedSuccessfully =>
      'Your phone number has been changed successfully';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get stepsForChangingEmail => 'Steps for changing your Email';

  @override
  String get changeEmailStepsDescription =>
      'To change your registered email address we will follow these steps :';

  @override
  String get step1Label => 'Step 1';

  @override
  String get step2Label => 'Step 2';

  @override
  String get step3Label => 'Step 3';

  @override
  String get step4Label => 'Step 4';

  @override
  String get changeEmailStep1 =>
      'A verification code will be sent to your registered phone number.';

  @override
  String get changeEmailStep2 =>
      'After entering the code that was sent, enter the new email address.';

  @override
  String get changeEmailStep3 =>
      'A verification code will be sent to the new email address entered by you.';

  @override
  String get changeEmailStep4 =>
      'Verify your account with a passcode to confirm changes to your account.';

  @override
  String get changeEmailAfterStepsNote =>
      'After following these steps, your current email address will be changed to the new one.';

  @override
  String get verifyCurrentPhoneNumber => 'Verify current phone number';

  @override
  String get enterNewEmailAddress => 'Enter new email address';

  @override
  String get verifyNewEmailAddress => 'Verify new email address';

  @override
  String changeEmailPhoneOtpSent(String phone) {
    return 'An 6 digit verification code has been sent via WhatsApp to $phone.';
  }

  @override
  String changeEmailEmailOtpSent(String email) {
    return 'An 6 digit verification code has been sent to $email.';
  }

  @override
  String get enterYourNewEmailAddressToReceiveOtp =>
      'Please enter your new email address to receive OTP';

  @override
  String get enterEmailAddressHint => 'Enter new email address';

  @override
  String get enterValidEmailAddress => 'Please enter a valid email address';

  @override
  String get continueButton => 'Continue';

  @override
  String get invalidOtpTryAgain => 'Invalid OTP. Try again.';

  @override
  String get emailChangedSuccessfully =>
      'Your email address has been changed successfully';

  @override
  String get changePasscode => 'Change Passcode';

  @override
  String get passcodeChangedSuccessfully =>
      'Your passcode has been changed successfully';

  @override
  String get backHome => 'Back Home';

  @override
  String get walletsAddress => 'Wallets Address';

  @override
  String get evm => 'EVM';

  @override
  String get tron => 'Tron';

  @override
  String get copy => 'Copy';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get notification => 'Notification';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get usesDeviceSettings => 'Uses your device\'s settings';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get en => 'EN';

  @override
  String get beforeYouStart => 'Before you start!';

  @override
  String get chooseYourLanguage => 'Choose your Language';

  @override
  String get languagePreferenceNote =>
      'Your Language preference can be changed at any time from Setting';

  @override
  String get continueAction => 'Continue';

  @override
  String get networkError => 'Network error, please check your connection';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get invalidServerResponse => 'Invalid response from server';

  @override
  String get softLoginFailed => 'Soft login failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get unableToChangePasscode => 'Unable to change passcode';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get skip => 'Skip';

  @override
  String get welcomeToOmlaPayNote => 'Instant Cryptocurrency Payments';

  @override
  String get fundsSafeSecure => 'Your Funds, Safe and Secure';

  @override
  String get advancedSecurityNote =>
      'Advanced security protocols ensure your transactions are protected';

  @override
  String get lowFeesMultipleCurrencies => 'Low Fees & Multiple Currencies';

  @override
  String get saveMoneyNote => 'Save Money and Pay with Your Preferred Currency';

  @override
  String get register => 'Register';

  @override
  String get hello => 'Hello!';

  @override
  String get welcomeBackToOmlapay => 'Welcome Back to Omlapay!';

  @override
  String get pleaseEnterYourNumberAndPasscodeToLogin =>
      'Please enter your number and Passcode to login';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberPlaceholder => '000 000 0000';

  @override
  String get phoneNumberMustBe9Digits => 'Phone number must be 9 digits';

  @override
  String get forgotPasscode => 'Forgot passcode';

  @override
  String get forgotPasscodePhoneMissing =>
      'We couldn\'t load your phone number. Log out and sign in again, or contact support.';

  @override
  String get dontHaveAccountSignUp => 'Don\'t have account? Sign Up';

  @override
  String get welcomeToOmlapayLetsGetStarted =>
      'Welcome to Omlapay, Let\'s get started!';

  @override
  String get pleaseEnterYourDataToReceiveVerificationCodes =>
      'Please enter your data to receive verification codes';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get continueAsGuest => 'Continue as a guest';

  @override
  String get byCreatingAnAccountIAgreeToMushafars =>
      'By creating an account I agree';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andWord => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get enterPasscode => 'Enter your passcode';

  @override
  String get pleaseEnterYour6DigitPasscode =>
      'Please enter your 6-digit passcode';

  @override
  String get userNotFound => 'User not found';

  @override
  String get incorrectPasscode => 'Incorrect passcode';

  @override
  String get incorrectPasscodeTryAgain => 'Incorrect passcode. Try again.';

  @override
  String get whoIsOmlapay => 'Who is \"Omlapay\"?';

  @override
  String get aboutOmlapayDescription =>
      'is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

  @override
  String get faqs => 'FAQs';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get faqsContent =>
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.';

  @override
  String get termsAndConditionsContent =>
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.';

  @override
  String get privacyPolicyContent =>
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.';

  @override
  String get howCanWeHelpYouToday => 'How can we help you today?';

  @override
  String get supportRequests => 'SUPPORT REQUESTS';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get pastRequests => 'Past Requests';

  @override
  String get sendRequestContent =>
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

  @override
  String get title => 'Title';

  @override
  String get titlePlaceholder => 'Enter your inquiry title';

  @override
  String get description => 'Description';

  @override
  String get descriptionPlaceholder => 'Describe Your inquiry';

  @override
  String get attachment => 'Attachment';

  @override
  String attachFileDescription(String extensions) {
    return 'Attach any related $extensions';
  }

  @override
  String get send => 'Send';

  @override
  String get noRequestsFound => 'No Requests Found';

  @override
  String get allRequestsWillBeListedHere => 'All requests will be listed here';

  @override
  String get filter => 'Filter';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get dateStart => 'Date Start';

  @override
  String get dateEnd => 'Date End';

  @override
  String get dateFrom => 'Date from...';

  @override
  String get dateTo => 'Date to...';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get all => 'All';

  @override
  String get open => 'Open';

  @override
  String get solved => 'Solved';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get seamlessCryptoPayments => 'Seamless Crypto Payments';

  @override
  String get instantSecureAnytime => 'Instant, Secure, Anytime';

  @override
  String get yourTotalBalance => 'Your total balance';

  @override
  String get assets => 'Assets';

  @override
  String get usd => 'USD';

  @override
  String get sar => 'SAR';

  @override
  String get transactions => 'Transactions';

  @override
  String get noTransactionsFound => 'No Transactions found.';

  @override
  String get allIncomingTransactionsListed =>
      'All incoming Transactions will be listed here.';

  @override
  String get tetherUsdt => 'Tether USDT';

  @override
  String get ethereum => 'Ethereum';

  @override
  String get bitcoin => 'Bitcoin';

  @override
  String get currency => 'Currency';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get readyToLogOut => 'Ready to log out?';

  @override
  String get logoutDialogMessage =>
      'Your funds are safe. To get back in, we\'ll send a code to your registered mobile number.';

  @override
  String get save => 'Save';

  @override
  String currencyName(String choice) {
    String _temp0 = intl.Intl.selectLogic(choice, {
      'usd': 'USD',
      'sar': 'SAR',
      'other': '$choice',
    });
    return '$_temp0';
  }

  @override
  String get receive => 'Receive';

  @override
  String get swap => 'Swap';

  @override
  String currencySymbol(String choice) {
    String _temp0 = intl.Intl.selectLogic(choice, {
      'usd': '\$',
      'sar': '﷼',
      'other': '$choice',
    });
    return '$_temp0';
  }

  @override
  String get coinHistory => 'Coin History';

  @override
  String get sent => 'Sent';

  @override
  String get currentPrice => 'Current price';

  @override
  String get coinDetailsPriceUnavailable => '—';

  @override
  String get today => 'today';

  @override
  String get total => 'Total';

  @override
  String get date => 'Date';

  @override
  String get sender => 'Sender';

  @override
  String get address => 'Address';

  @override
  String get network => 'Network';

  @override
  String get saveAs => 'Save As';

  @override
  String get shareTo => 'Share to';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get messages => 'Messages';

  @override
  String get mail => 'Mail';

  @override
  String get recently => 'Recently';

  @override
  String get received => 'Received';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get transactionInformation => 'Transaction Information';

  @override
  String get type => 'Type';

  @override
  String get fee => 'Fee';

  @override
  String get transactionHash => 'Transaction Hash';

  @override
  String get fromAddress => 'From Address';

  @override
  String get toAddress => 'To Address';

  @override
  String get note => 'Note';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get transactionHistory => 'Transaction history';

  @override
  String get sol => 'Sol';

  @override
  String get solana => 'Solana';

  @override
  String get sendTo => 'Send To';

  @override
  String get transactionFees => 'Transactions Fees';

  @override
  String get png => 'PNG';

  @override
  String get jpg => 'JPG';

  @override
  String get pdf => 'PDF';

  @override
  String get imageSavedSuccessfully => 'Image saved successfully';

  @override
  String transactionSavedSuccessfully(String format) {
    return 'Transaction has been saved as $format successfully';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get unreadNotification => '1 Unread Notification';

  @override
  String unreadNotifications(int count) {
    return '$count Unread Notifications';
  }

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get forgotPasscodeTitle => 'Forgot passcode';

  @override
  String get verifyYourPhoneNumber => 'Verify your phone number';

  @override
  String get verifyYourAccount => 'Verify your account';

  @override
  String verificationCodeSentViaSmsTo(String phone) {
    return 'An 6 digit verification code has been sent via SMS to $phone.';
  }

  @override
  String get verificationCodesIn =>
      'You should receive the verification codes in';

  @override
  String secondsCount(int seconds) {
    return '$seconds Seconds';
  }

  @override
  String get didntReceiveCodesResendOtp =>
      'Didn\'t receive the codes? Resend OTP.';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get needHelpContactSupport => 'Need Help? Contact Support';

  @override
  String get setYourNewPasscode => 'Set your new passcode';

  @override
  String get createAPasscode => 'Create a passcode';

  @override
  String get enterYourCurrentPasscode => 'Enter your current passcode';

  @override
  String get enterYourNewPasscode => 'Enter your new passcode';

  @override
  String get confirmYourNewPasscode => 'Confirm your new passcode';

  @override
  String get confirmYourPasscode => 'Confirm your passcode';

  @override
  String get passcodesMismatchTryAgain => 'Passcodes don\'t match. Try again.';

  @override
  String get qrCodeScanner => 'QR Code Scanner';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get scanAQrCode => 'Scan a QR Code';

  @override
  String get cameraPermissionRequired =>
      'Camera access is required to scan QR codes';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get cameraPermissionDeniedMessage =>
      'Please grant camera access in settings to scan QR codes.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get allowCamera => 'Allow Camera';

  @override
  String get cameraError => 'Camera error';

  @override
  String get cameraErrorMessage =>
      'Unable to access the camera. Please try again.';

  @override
  String cameraPermissionDialogTitle(String appName) {
    return '$appName wants to access the camera';
  }

  @override
  String get cameraPermissionDialogMessage =>
      'We need your permission to access the camera to be able to scan the codes';

  @override
  String get doNotAllow => 'Do not allow';

  @override
  String get invalidQrCode => 'Invalid QR code';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get twoFactorAuthentication => 'Two Factor Authentication';

  @override
  String get sendFlowReviewTitle => 'Review';

  @override
  String get sendFlowSendingTitle => 'Sending';

  @override
  String get feeFree => 'Free';

  @override
  String get accountNoUserDataAvailable => 'No user data available';

  @override
  String copyLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get shareComingSoon => 'Share functionality coming soon';

  @override
  String errorPickingFile(String error) {
    return 'Error picking file: $error';
  }

  @override
  String get helpRequestSentSuccess => 'Request sent successfully';

  @override
  String get verificationCodeResentSuccess =>
      'Verification code resent successfully.';

  @override
  String get pasteHintLongPress => 'Press and hold to paste';

  @override
  String get minAmountHint => 'Min 0';

  @override
  String get searchHint => 'Search';

  @override
  String get searchContactsHint => 'Search name or number';

  @override
  String get sendFlowVerifyAccountTitle => 'Verify Account';

  @override
  String sendOtpInstructionsMasked(String phoneMask) {
    return 'Enter the code sent to $phoneMask';
  }

  @override
  String get verifyAction => 'Verify';

  @override
  String get swapSuccessMessage => 'Successfully swapped';

  @override
  String get sendSuccessMessage => 'Successfully sent';

  @override
  String get successScreenTitle => 'Success';

  @override
  String get confirmSecurely => 'Confirm Securely';

  @override
  String get youAreSending => 'You are sending';

  @override
  String get reviewOrderTitle => 'Review Order';

  @override
  String get swapDirectionFrom => 'From';

  @override
  String get swapDirectionTo => 'To';

  @override
  String get swapMaxAction => 'Max';

  @override
  String get selectCoinTitle => 'Select Coin';

  @override
  String get selectCoinPlaceholder => 'Select';

  @override
  String get swapFeesColon => 'Swap fees:';

  @override
  String get confirmSwapButton => 'Confirm swap';

  @override
  String get verifyNowButton => 'Verify Now';

  @override
  String get swapNowButton => 'Swap Now';

  @override
  String get sendFormCoinLabel => 'Coin';

  @override
  String get sendFormPhoneOrAddressLabel => 'Phone Number Or Wallet Address';

  @override
  String get sendFormAmountLabel => 'Amount to be sent';

  @override
  String get sendValidationInvalidAmount => 'Invalid amount';

  @override
  String get sendValidationInsufficientBalance => 'Insufficient balance';

  @override
  String get sendDefaultNetworkCode => 'TRC20';

  @override
  String availableBalanceFormatted(String amount, String symbol) {
    return 'Available $amount $symbol';
  }

  @override
  String get sendTransactionFeesColon => 'Transaction fees:';

  @override
  String get sendSentAmountLabel => 'Sent amount';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get yourWalletsTitle => 'Your wallets';

  @override
  String get networkFeeLabel => 'Network Fee';

  @override
  String get valueNotAvailable => 'N/A';

  @override
  String get amountInputHint => '0.00';

  @override
  String get qrCodeLabel => 'QR Code';

  @override
  String get saveImage => 'Save image';

  @override
  String get shareAction => 'Share';

  @override
  String get hideZeroBalance => 'Hide zero balance';

  @override
  String get contactsSheetTitle => 'Contacts';

  @override
  String sendSuccessRecipientLine(String recipient) {
    return 'To: $recipient';
  }

  @override
  String get sendKycVerificationRequiredBody =>
      'Identity verification is required to send coins. Please complete your KYC profile to enable transfers. ';

  @override
  String get swapKycVerificationRequiredBody =>
      'Identity verification is required to swap coins. Please complete your KYC profile to enable transfers. ';

  @override
  String get receiveKycVerificationRequiredBody =>
      'Identity verification is required to receive coins. Please complete your KYC profile to enable transfers. ';

  @override
  String get swapFeesTitle => 'Swap Fees';

  @override
  String get transferToLabel => 'To';

  @override
  String get addressCopiedToast => 'Copied';

  @override
  String get availableShortLabel => 'Available';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notificationsLoadError => 'Failed to load notifications';

  @override
  String get retry => 'Retry';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get kycFirstNameLabel => 'First Name';

  @override
  String get kycLastNameLabel => 'Last Name';

  @override
  String get kycDateOfBirthLabel => 'Date of Birth';

  @override
  String get kycResidentialCountryLabel => 'Residential Country';

  @override
  String get kycDocumentCountryLabel => 'Document Country';

  @override
  String get kycCityLabel => 'City';

  @override
  String get kycAddressLabel => 'Address';

  @override
  String get kycCountryCodeHint => 'e.g., GBR, USA, IND';

  @override
  String get kycSelectDateHint => 'MM/DD/YYYY';

  @override
  String get kycRequiredFieldError => 'This field is required';

  @override
  String get kycSubmitButton => 'Submit';

  @override
  String get kycInvalidDateError => 'Please select a valid date';

  @override
  String get kycStartedSuccess => 'KYC process started successfully.';

  @override
  String get youAreOffline => 'You are offline';

  @override
  String get contactsPermissionDenied =>
      'Contacts permission is required to select a contact. Please enable it in your device settings.';

  @override
  String get contactsLoading => 'Loading contacts...';

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String contactsPermissionDialogTitle(String appName) {
    return '$appName wants to access your contacts';
  }

  @override
  String get contactsPermissionDialogMessage =>
      'We need your permission to access your contacts to send payments to people in your address book';

  @override
  String get allowContacts => 'Allow Contacts';

  @override
  String get sendInvitationDialogTitle => 'Send invitation';

  @override
  String get sendInvitationDialogMessage =>
      'This number does not have an account on Omlapay. For a better experience, send him an invitation.';

  @override
  String get sendInvitationDialogNote =>
      'Note: you can complete the transaction though';

  @override
  String get sendInvitationInviteButton => 'Invite';

  @override
  String get checkingUserStatus => 'Checking user...';

  @override
  String get kycEnterEmail => 'Enter Email';

  @override
  String get kycWhatsYourEmail => 'What\'s your email?';

  @override
  String get kycEmailSubtitle =>
      'We\'ll send a verification code to confirm your email';

  @override
  String get kycEmailHint => 'Enter your email address';

  @override
  String get kycEmailRequiredError => 'Email address is required';

  @override
  String get kycEmailInvalidError => 'Please enter a valid email address';

  @override
  String get kycVerifyEmail => 'Verify Email';

  @override
  String get kycVerifyEmailTitle => 'Enter verification code';

  @override
  String kycVerifyEmailSubtitle(String email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String get kycEmailVerified => 'Email verified successfully';

  @override
  String get pleaseEnterATitle => 'Please enter a title';

  @override
  String titleMustNotExceedCharacters(int maxLength) {
    return 'Title must not exceed $maxLength characters';
  }

  @override
  String get pleaseEnterADescription => 'Please enter a description';

  @override
  String descriptionMustNotExceedCharacters(int maxLength) {
    return 'Description must not exceed $maxLength characters';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get failedToLoadMoreNotifications =>
      'Failed to load more notifications';

  @override
  String get failedToMarkNotificationAsRead =>
      'Failed to mark notification as read';

  @override
  String get failedToMarkAllNotificationsAsRead =>
      'Failed to mark all notifications as read';

  @override
  String get failedToLoadSupportRequests => 'Failed to load support requests';

  @override
  String get failedToLoadMoreRequests => 'Failed to load more requests';
}
