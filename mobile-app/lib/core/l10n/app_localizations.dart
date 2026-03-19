import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OmlaPay'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @pleaseLoginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please login first to continue'**
  String get pleaseLoginToContinue;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcomeToOmlaPay.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OmlaPay'**
  String get welcomeToOmlaPay;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @welcomeHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Home'**
  String get welcomeHome;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get homeScreen;

  /// No description provided for @historyScreen.
  ///
  /// In en, this message translates to:
  /// **'History Screen'**
  String get historyScreen;

  /// No description provided for @profileScreen.
  ///
  /// In en, this message translates to:
  /// **'Profile Screen'**
  String get profileScreen;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @kycVerification.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get kycVerification;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @aboutOmlapay.
  ///
  /// In en, this message translates to:
  /// **'About Omlapay'**
  String get aboutOmlapay;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhoneNumber;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @changePasscode.
  ///
  /// In en, this message translates to:
  /// **'Change Passcode'**
  String get changePasscode;

  /// No description provided for @walletsAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallets Address'**
  String get walletsAddress;

  /// No description provided for @evm.
  ///
  /// In en, this message translates to:
  /// **'EVM'**
  String get evm;

  /// No description provided for @bitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get bitcoin;

  /// No description provided for @tron.
  ///
  /// In en, this message translates to:
  /// **'Tron'**
  String get tron;

  /// No description provided for @solana.
  ///
  /// In en, this message translates to:
  /// **'Solana'**
  String get solana;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @usesDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Uses your device\'s settings'**
  String get usesDeviceSettings;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get en;

  /// No description provided for @beforeYouStart.
  ///
  /// In en, this message translates to:
  /// **'Before you start!'**
  String get beforeYouStart;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your Language'**
  String get chooseYourLanguage;

  /// No description provided for @languagePreferenceNote.
  ///
  /// In en, this message translates to:
  /// **'Your Language preference can be changed at any time from Setting'**
  String get languagePreferenceNote;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, please check your connection'**
  String get networkError;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcomeToOmlaPayNote.
  ///
  /// In en, this message translates to:
  /// **'Instant Cryptocurrency Payments'**
  String get welcomeToOmlaPayNote;

  /// No description provided for @fundsSafeSecure.
  ///
  /// In en, this message translates to:
  /// **'Your Funds, Safe and Secure'**
  String get fundsSafeSecure;

  /// No description provided for @advancedSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Advanced security protocols ensure your transactions are protected'**
  String get advancedSecurityNote;

  /// No description provided for @lowFeesMultipleCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Low Fees & Multiple Currencies'**
  String get lowFeesMultipleCurrencies;

  /// No description provided for @saveMoneyNote.
  ///
  /// In en, this message translates to:
  /// **'Save Money and Pay with Your Preferred Currency'**
  String get saveMoneyNote;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcomeBackToOmlapay.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back to Omlapay!'**
  String get welcomeBackToOmlapay;

  /// No description provided for @pleaseEnterYourNumberAndPasscodeToLogin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your number and Passcode to login'**
  String get pleaseEnterYourNumberAndPasscodeToLogin;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'000 000 0000'**
  String get phoneNumberPlaceholder;

  /// No description provided for @phoneNumberMustBe9Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 9 digits'**
  String get phoneNumberMustBe9Digits;

  /// No description provided for @forgotPasscode.
  ///
  /// In en, this message translates to:
  /// **'Forgot passcode'**
  String get forgotPasscode;

  /// No description provided for @dontHaveAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have account? Sign Up'**
  String get dontHaveAccountSignUp;

  /// No description provided for @welcomeToOmlapayLetsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Omlapay, Let\'s get started!'**
  String get welcomeToOmlapayLetsGetStarted;

  /// No description provided for @pleaseEnterYourDataToReceiveVerificationCodes.
  ///
  /// In en, this message translates to:
  /// **'Please enter your data to receive verification codes'**
  String get pleaseEnterYourDataToReceiveVerificationCodes;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get continueAsGuest;

  /// No description provided for @byCreatingAnAccountIAgreeToMushafars.
  ///
  /// In en, this message translates to:
  /// **'By creating an account I agree to Mushafar\'s'**
  String get byCreatingAnAccountIAgreeToMushafars;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andWord;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @enterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter your passcode'**
  String get enterPasscode;

  /// No description provided for @pleaseEnterYour6DigitPasscode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 6-digit passcode'**
  String get pleaseEnterYour6DigitPasscode;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @incorrectPasscode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passcode'**
  String get incorrectPasscode;

  /// No description provided for @incorrectPasscodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passcode. Try again.'**
  String get incorrectPasscodeTryAgain;

  /// No description provided for @whoIsOmlapay.
  ///
  /// In en, this message translates to:
  /// **'Who is \"Omlapay\"?'**
  String get whoIsOmlapay;

  /// No description provided for @aboutOmlapayDescription.
  ///
  /// In en, this message translates to:
  /// **'is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.'**
  String get aboutOmlapayDescription;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @faqsContent.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'**
  String get faqsContent;

  /// No description provided for @termsAndConditionsContent.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'**
  String get termsAndConditionsContent;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'**
  String get privacyPolicyContent;

  /// No description provided for @howCanWeHelpYouToday.
  ///
  /// In en, this message translates to:
  /// **'How can we help you today?'**
  String get howCanWeHelpYouToday;

  /// No description provided for @supportRequests.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT REQUESTS'**
  String get supportRequests;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @pastRequests.
  ///
  /// In en, this message translates to:
  /// **'Past Requests'**
  String get pastRequests;

  /// No description provided for @sendRequestContent.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.'**
  String get sendRequestContent;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your inquiry title'**
  String get titlePlaceholder;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe Your inquiry'**
  String get descriptionPlaceholder;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @attachFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Attach any related PNG, JPG, PDF'**
  String get attachFileDescription;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No Requests Found'**
  String get noRequestsFound;

  /// No description provided for @allRequestsWillBeListedHere.
  ///
  /// In en, this message translates to:
  /// **'All requests will be listed here'**
  String get allRequestsWillBeListedHere;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get transactionType;

  /// No description provided for @dateStart.
  ///
  /// In en, this message translates to:
  /// **'Date Start'**
  String get dateStart;

  /// No description provided for @dateEnd.
  ///
  /// In en, this message translates to:
  /// **'Date End'**
  String get dateEnd;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'Date from...'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'Date to...'**
  String get dateTo;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @seamlessCryptoPayments.
  ///
  /// In en, this message translates to:
  /// **'Seamless Crypto Payments'**
  String get seamlessCryptoPayments;

  /// No description provided for @instantSecureAnytime.
  ///
  /// In en, this message translates to:
  /// **'Instant, Secure, Anytime'**
  String get instantSecureAnytime;

  /// No description provided for @yourTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Your total balance'**
  String get yourTotalBalance;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get sar;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Transactions found.'**
  String get noTransactionsFound;

  /// No description provided for @allIncomingTransactionsListed.
  ///
  /// In en, this message translates to:
  /// **'All incoming Transactions will be listed here.'**
  String get allIncomingTransactionsListed;

  /// No description provided for @tetherUsdt.
  ///
  /// In en, this message translates to:
  /// **'Tether USDT'**
  String get tetherUsdt;

  /// No description provided for @ethereum.
  ///
  /// In en, this message translates to:
  /// **'Ethereum'**
  String get ethereum;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @readyToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Ready to log out?'**
  String get readyToLogOut;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your funds are safe. To get back in, we\'ll send a code to your registered mobile number.'**
  String get logoutDialogMessage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currencyName.
  ///
  /// In en, this message translates to:
  /// **'{choice, select, usd {USD} sar {SAR} other {{choice}}}'**
  String currencyName(String choice);

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'{choice, select, usd {\$} sar {﷼} other {{choice}}}'**
  String currencySymbol(String choice);

  /// No description provided for @coinHistory.
  ///
  /// In en, this message translates to:
  /// **'Coin History'**
  String get coinHistory;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current price'**
  String get currentPrice;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save As'**
  String get saveAs;

  /// No description provided for @shareTo.
  ///
  /// In en, this message translates to:
  /// **'Share to'**
  String get shareTo;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @transactionInformation.
  ///
  /// In en, this message translates to:
  /// **'Transaction Information'**
  String get transactionInformation;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @transactionHash.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get transactionHash;

  /// No description provided for @fromAddress.
  ///
  /// In en, this message translates to:
  /// **'From Address'**
  String get fromAddress;

  /// No description provided for @toAddress.
  ///
  /// In en, this message translates to:
  /// **'To Address'**
  String get toAddress;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get transactionHistory;

  /// No description provided for @sol.
  ///
  /// In en, this message translates to:
  /// **'Sol'**
  String get sol;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send To'**
  String get sendTo;

  /// No description provided for @transactionFees.
  ///
  /// In en, this message translates to:
  /// **'Transactions Fees'**
  String get transactionFees;

  /// No description provided for @png.
  ///
  /// In en, this message translates to:
  /// **'PNG'**
  String get png;

  /// No description provided for @jpg.
  ///
  /// In en, this message translates to:
  /// **'JPG'**
  String get jpg;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @imageSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully'**
  String get imageSavedSuccessfully;

  /// No description provided for @transactionSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction has been saved as {format} successfully'**
  String transactionSavedSuccessfully(String format);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @unreadNotification.
  ///
  /// In en, this message translates to:
  /// **'1 Unread Notification'**
  String get unreadNotification;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} Unread Notifications'**
  String unreadNotifications(int count);

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @forgotPasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot passcode'**
  String get forgotPasscodeTitle;

  /// No description provided for @verifyYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyYourPhoneNumber;

  /// No description provided for @verifyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get verifyYourAccount;

  /// No description provided for @verificationCodeSentViaSmsTo.
  ///
  /// In en, this message translates to:
  /// **'An 6 digit verification code has been sent via SMS to {phone}.'**
  String verificationCodeSentViaSmsTo(String phone);

  /// No description provided for @verificationCodesInSeconds.
  ///
  /// In en, this message translates to:
  /// **'You should receive the verification codes in {seconds} Seconds'**
  String verificationCodesInSeconds(int seconds);

  /// No description provided for @didntReceiveCodesResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the codes? Resend OTP.'**
  String get didntReceiveCodesResendOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @needHelpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Need Help? Contact Support'**
  String get needHelpContactSupport;

  /// No description provided for @setYourNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'Set your new passcode'**
  String get setYourNewPasscode;

  /// No description provided for @createAPasscode.
  ///
  /// In en, this message translates to:
  /// **'Create a passcode'**
  String get createAPasscode;

  /// No description provided for @confirmYourPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm your passcode'**
  String get confirmYourPasscode;

  /// No description provided for @passcodesMismatchTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Passcodes don\'t match. Try again.'**
  String get passcodesMismatchTryAgain;

  /// No description provided for @qrCodeScanner.
  ///
  /// In en, this message translates to:
  /// **'QR Code Scanner'**
  String get qrCodeScanner;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @scanAQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR Code'**
  String get scanAQrCode;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to scan QR codes'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please grant camera access in settings to scan QR codes.'**
  String get cameraPermissionDeniedMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @allowCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow Camera'**
  String get allowCamera;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get cameraError;

  /// No description provided for @cameraErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to access the camera. Please try again.'**
  String get cameraErrorMessage;

  /// No description provided for @cameraPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{appName} wants to access the camera'**
  String cameraPermissionDialogTitle(String appName);

  /// No description provided for @cameraPermissionDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'We need your permission to access the camera to be able to scan the codes'**
  String get cameraPermissionDialogMessage;

  /// No description provided for @doNotAllow.
  ///
  /// In en, this message translates to:
  /// **'Do not allow'**
  String get doNotAllow;

  /// No description provided for @invalidQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQrCode;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two Factor Authentication'**
  String get twoFactorAuthentication;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
