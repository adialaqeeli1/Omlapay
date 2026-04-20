// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أوملاباي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get pleaseLoginToContinue => 'يرجى تسجيل الدخول أولاً للمتابعة';

  @override
  String get home => 'الرئيسية';

  @override
  String get history => 'السجل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get welcomeToOmlaPay => 'مرحبًا بك في أوملا باي!';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get pleaseEnterYourEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterAValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterYourPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get welcomeHome => 'مرحباً بك في المنزل';

  @override
  String get homeScreen => 'شاشة الرئيسية';

  @override
  String get historyScreen => 'شاشة السجل';

  @override
  String get profileScreen => 'شاشة الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get kycVerification => 'التحقق من الهوية';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get aboutOmlapay => 'حول أوملا باي';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get account => 'الحساب';

  @override
  String get accountDetails => 'تفاصيل الحساب';

  @override
  String get changePhoneNumber => 'تغيير رقم الهاتف';

  @override
  String get stepsForChangingPhoneNumber => 'خطوات تغيير رقم هاتفك';

  @override
  String get changePhoneStepsDescription =>
      'لتغيير رقم هاتفك المسجل، اتبع الخطوات التالية:';

  @override
  String get changePhoneStep1 =>
      'تحقق من رقم هاتفك المسجل الحالي باستخدام رمز تحقق.';

  @override
  String get changePhoneStep2 =>
      'أدخل رقم الهاتف الجديد الذي تريد استخدامه في حسابك.';

  @override
  String get changePhoneStep3 => 'تحقق من رقم هاتفك الجديد باستخدام رمز تحقق.';

  @override
  String get changePhoneStep4 =>
      'تحقق من حسابك باستخدام رمز المرور لتأكيد التغييرات.';

  @override
  String get changePhoneAfterStepsNote =>
      'بعد التحقق من الرمز، سيصبح رقم هاتف حسابك هو الرقم الجديد.';

  @override
  String get changePhoneEnterNewSubtitle =>
      'بعد أن تضغط متابعة، سنرسل رمز تحقق إلى هذا الرقم.';

  @override
  String get enterNewPhoneNumber => 'أدخل رقم الهاتف الجديد';

  @override
  String get verifyNewPhoneNumber => 'تحقق من رقم الهاتف الجديد';

  @override
  String changePhoneCurrentOtpSent(String phone) {
    return 'تم إرسال رمز تحقق مكون من 6 أرقام عبر واتساب إلى $phone.';
  }

  @override
  String changePhoneNewOtpSent(String phone) {
    return 'تم إرسال رمز تحقق مكون من 6 أرقام إلى $phone.';
  }

  @override
  String get verifyYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String twoFactorEmailOtpSent(String email) {
    return 'تم إرسال رمز تحقق مكون من 6 أرقام إلى $email.';
  }

  @override
  String get enterValidPhoneNumber => 'يرجى إدخال رقم هاتف صالح';

  @override
  String get phoneNumberChangedSuccessfully => 'تم تغيير رقم هاتفك بنجاح';

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get stepsForChangingEmail => 'خطوات تغيير بريدك الإلكتروني';

  @override
  String get changeEmailStepsDescription =>
      'لتغيير بريدك الإلكتروني المسجل سنتبع الخطوات التالية:';

  @override
  String get step1Label => 'الخطوة 1';

  @override
  String get step2Label => 'الخطوة 2';

  @override
  String get step3Label => 'الخطوة 3';

  @override
  String get step4Label => 'الخطوة 4';

  @override
  String get changeEmailStep1 => 'سيتم إرسال رمز تحقق إلى رقم هاتفك المسجل.';

  @override
  String get changeEmailStep2 =>
      'بعد إدخال الرمز المُرسل، أدخل البريد الإلكتروني الجديد.';

  @override
  String get changeEmailStep3 =>
      'سيتم إرسال رمز تحقق إلى البريد الإلكتروني الجديد الذي أدخلته.';

  @override
  String get changeEmailStep4 =>
      'تحقق من حسابك باستخدام رمز المرور لتأكيد التغييرات على حسابك.';

  @override
  String get changeEmailAfterStepsNote =>
      'بعد اتباع هذه الخطوات، سيتم تغيير بريدك الإلكتروني الحالي إلى البريد الجديد.';

  @override
  String get verifyCurrentPhoneNumber => 'تحقق من رقم الهاتف الحالي';

  @override
  String get enterNewEmailAddress => 'أدخل البريد الإلكتروني الجديد';

  @override
  String get verifyNewEmailAddress => 'تحقق من البريد الإلكتروني الجديد';

  @override
  String changeEmailPhoneOtpSent(String phone) {
    return 'تم إرسال رمز تحقق مكون من 6 أرقام عبر واتساب إلى $phone.';
  }

  @override
  String changeEmailEmailOtpSent(String email) {
    return 'تم إرسال رمز تحقق مكون من 6 أرقام إلى $email.';
  }

  @override
  String get enterYourNewEmailAddressToReceiveOtp =>
      'يرجى إدخال بريدك الإلكتروني الجديد لاستلام رمز التحقق';

  @override
  String get enterEmailAddressHint => 'أدخل البريد الإلكتروني الجديد';

  @override
  String get enterValidEmailAddress => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get continueButton => 'متابعة';

  @override
  String get invalidOtpTryAgain => 'رمز التحقق غير صالح. حاول مرة أخرى.';

  @override
  String get emailChangedSuccessfully => 'تم تغيير بريدك الإلكتروني بنجاح';

  @override
  String get changePasscode => 'تغيير رمز المرور';

  @override
  String get passcodeChangedSuccessfully => 'تم تغيير رمز المرور بنجاح';

  @override
  String get backHome => 'العودة للرئيسية';

  @override
  String get walletsAddress => 'عنوان المحفظة';

  @override
  String get evm => 'EVM';

  @override
  String get tron => 'ترون';

  @override
  String get copy => 'نسخ';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get notification => 'الإشعارات';

  @override
  String get dark => 'داكن';

  @override
  String get light => 'فاتح';

  @override
  String get system => 'النظام';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get usesDeviceSettings => 'يستخدم إعدادات جهازك';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get en => 'EN';

  @override
  String get beforeYouStart => 'قبل أن تبدأ!';

  @override
  String get chooseYourLanguage => 'اختر لغتك';

  @override
  String get languagePreferenceNote =>
      'يمكن تغيير تفضيل اللغة في أي وقت من الإعدادات';

  @override
  String get continueAction => 'متابعة';

  @override
  String get networkError => 'خطأ في الشبكة، يرجى التحقق من اتصالك';

  @override
  String get requestFailed => 'فشل الطلب';

  @override
  String get invalidServerResponse => 'استجابة غير صالحة من الخادم';

  @override
  String get softLoginFailed => 'فشل تسجيل الدخول السريع';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get unableToChangePasscode => 'تعذر تغيير رمز المرور';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get skip => 'تخطي';

  @override
  String get welcomeToOmlaPayNote => 'مدفوعات فورية بالعملات المشفرة';

  @override
  String get fundsSafeSecure => 'أموالك آمنة ومحمية';

  @override
  String get advancedSecurityNote =>
      'بروتوكولات أمان متقدمة تضمن حماية معاملاتك';

  @override
  String get lowFeesMultipleCurrencies => 'رسوم منخفضة وعملات متعددة';

  @override
  String get saveMoneyNote => 'وفر المال وادفع بعملتك المفضلة';

  @override
  String get register => 'يسجل';

  @override
  String get hello => 'مرحبًا!';

  @override
  String get helloComma => 'مرحبًا،';

  @override
  String get welcomeBackToOmlapay => 'مرحبًا بعودتك إلى أوملاباي!';

  @override
  String get pleaseEnterYourNumberAndPasscodeToLogin =>
      'يرجى إدخال رقمك وكلمة المرور لتسجيل الدخول';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneNumberPlaceholder => '000 000 0000';

  @override
  String get phoneNumberMustBe9Digits => 'يجب أن يكون رقم الهاتف 9 أرقام';

  @override
  String get forgotPasscode => 'نسيت كلمة المرور';

  @override
  String get forgotPasscodePhoneMissing =>
      'تعذر تحميل رقم هاتفك. سجّل الخروج ثم أعد تسجيل الدخول، أو تواصل مع الدعم.';

  @override
  String get dontHaveAccountSignUp => 'ليس لديك حساب؟ سجل';

  @override
  String get welcomeToOmlapayLetsGetStarted => 'مرحبًا بك في أوملاباي، لنبدأ!';

  @override
  String get pleaseEnterYourDataToReceiveVerificationCodes =>
      'يرجى إدخال بياناتك لاستلام رموز التحقق';

  @override
  String get alreadyHaveAccountLogin => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get byCreatingAnAccountIAgreeToMushafars => 'بإنشاء حساب، أوافق';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get andWord => 'و';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get enterPasscode => 'أدخل رمز المرور';

  @override
  String get pleaseEnterYour6DigitPasscode =>
      'يرجى إدخال رمز المرور المكون من 6 أرقام';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get incorrectPasscode => 'رمز المرور غير صحيح';

  @override
  String get incorrectPasscodeTryAgain => 'رمز المرور غير صحيح. حاول مرة أخرى.';

  @override
  String get whoIsOmlapay => 'من هو \"أوملاباي\"؟';

  @override
  String get aboutOmlapayDescription =>
      'هو ببساطة نص وهمي لصناعة الطباعة والتنضيد. كان لوريم إيبسوم المعيار الصناعي للنص الوهمي منذ القرن الخامس عشر الميلادي، عندما أخذت طابعة غير معروفة لوحة من النوع وعكستها لعمل كتاب عينة.';

  @override
  String get faqs => 'الأسئلة الشائعة';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get faqsContent =>
      'لوريم إيبسوم هو ببساطة نص وهمي لصناعة الطباعة والتنضيد. كان لوريم إيبسوم المعيار الصناعي للنص الوهمي منذ القرن الخامس عشر الميلادي، عندما أخذت طابعة غير معروفة لوحة من النوع وعكستها لعمل كتاب عينة. لقد نجا ليس فقط من خمسة قرون، بل أيضًا من القفزة في التنضيد الإلكتروني، وظل دون تغيير جوهري.';

  @override
  String get termsAndConditionsContent =>
      'لوريم إيبسوم هو ببساطة نص وهمي لصناعة الطباعة والتنضيد. كان لوريم إيبسوم المعيار الصناعي للنص الوهمي منذ القرن الخامس عشر الميلادي، عندما أخذت طابعة غير معروفة لوحة من النوع وعكستها لعمل كتاب عينة. لقد نجا ليس فقط من خمسة قرون، بل أيضًا من القفزة في التنضيد الإلكتروني، وظل دون تغيير جوهري.';

  @override
  String get privacyPolicyContent =>
      'لوريم إيبسوم هو ببساطة نص وهمي لصناعة الطباعة والتنضيد. كان لوريم إيبسوم المعيار الصناعي للنص الوهمي منذ القرن الخامس عشر الميلادي، عندما أخذت طابعة غير معروفة لوحة من النوع وعكستها لعمل كتاب عينة. لقد نجا ليس فقط من خمسة قرون، بل أيضًا من القفزة في التنضيد الإلكتروني، وظل دون تغيير جوهري.';

  @override
  String get howCanWeHelpYouToday => 'كيف يمكننا مساعدتك اليوم؟';

  @override
  String get supportRequests => 'طلبات الدعم';

  @override
  String get sendRequest => 'إرسال طلب';

  @override
  String get pastRequests => 'الطلبات السابقة';

  @override
  String get sendRequestContent =>
      'لوريم إيبسوم هو ببساطة نص وهمي لصناعة الطباعة والتنضيد. كان لوريم إيبسوم المعيار الصناعي للنص الوهمي منذ القرن الخامس عشر الميلادي، عندما أخذت طابعة غير معروفة لوحة من النوع وعكستها لعمل كتاب عينة.';

  @override
  String get title => 'العنوان';

  @override
  String get titlePlaceholder => 'أدخل عنوان استفسارك';

  @override
  String get description => 'الوصف';

  @override
  String get descriptionPlaceholder => 'اوصف استفسارك';

  @override
  String get attachment => 'المرفق';

  @override
  String attachFileDescription(String extensions) {
    return 'أرفق أي ملفات $extensions ذات صلة';
  }

  @override
  String get send => 'إرسال';

  @override
  String get noRequestsFound => 'لم يتم العثور على طلبات';

  @override
  String get allRequestsWillBeListedHere => 'سيتم سرد جميع الطلبات هنا';

  @override
  String get filter => 'تصفية';

  @override
  String get transactionType => 'نوع المعاملة';

  @override
  String get dateStart => 'تاريخ البداية';

  @override
  String get dateEnd => 'تاريخ النهاية';

  @override
  String get dateFrom => 'التاريخ من...';

  @override
  String get dateTo => 'التاريخ إلى...';

  @override
  String get year => 'السنة';

  @override
  String get month => 'الشهر';

  @override
  String get day => 'اليوم';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get apply => 'تطبيق';

  @override
  String get all => 'الكل';

  @override
  String get open => 'مفتوح';

  @override
  String get solved => 'محلول';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get rejected => 'مرفوض';

  @override
  String get seamlessCryptoPayments => 'مدفوعات تشفير سلسة';

  @override
  String get instantSecureAnytime => 'فوري، آمن، في أي وقت';

  @override
  String get yourTotalBalance => 'إجمالي رصيدك';

  @override
  String get assets => 'الأصول';

  @override
  String get usd => 'دولار أمريكي';

  @override
  String get sar => 'ريال سعودي';

  @override
  String get transactions => 'المعاملات';

  @override
  String get noTransactionsFound => 'لم يتم العثور على معاملات.';

  @override
  String get allIncomingTransactionsListed =>
      'سيتم إدراج جميع المعاملات الواردة هنا.';

  @override
  String get tetherUsdt => 'تيثر USDT';

  @override
  String get ethereum => 'إيثيريوم';

  @override
  String get bitcoin => 'بيتكوين';

  @override
  String get currency => 'العملة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get readyToLogOut => 'هل أنت مستعد لتسجيل الخروج؟';

  @override
  String get logoutDialogMessage =>
      'أموالك في أمان. للعودة، سنرسل رمزاً إلى رقم هاتفك المسجل.';

  @override
  String get save => 'حفظ';

  @override
  String currencyName(String choice) {
    String _temp0 = intl.Intl.selectLogic(choice, {
      'usd': 'دولار أمريكي',
      'sar': 'ريال سعودي',
      'other': '$choice',
    });
    return '$_temp0';
  }

  @override
  String get receive => 'استلام';

  @override
  String get swap => 'مبادلة';

  @override
  String currencySymbol(String choice) {
    String _temp0 = intl.Intl.selectLogic(choice, {
      'usd': '\$',
      'sar': '⃁',
      'other': '$choice',
    });
    return '$_temp0';
  }

  @override
  String get coinHistory => 'تاريخ العملة';

  @override
  String get sent => 'أرسلت';

  @override
  String get currentPrice => 'السعر الحالي';

  @override
  String get coinDetailsPriceUnavailable => '—';

  @override
  String get today => 'اليوم';

  @override
  String get total => 'الإجمالي';

  @override
  String get date => 'التاريخ';

  @override
  String get sender => 'المرسل';

  @override
  String get address => 'العنوان';

  @override
  String get network => 'الشبكة';

  @override
  String get saveAs => 'حفظ كـ';

  @override
  String get shareTo => 'مشاركة إلى';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get messages => 'الرسائل';

  @override
  String get mail => 'البريد';

  @override
  String get recently => 'مؤخراً';

  @override
  String get received => 'تم الاستلام';

  @override
  String get transactionDetails => 'تفاصيل المعاملة';

  @override
  String get transactionInformation => 'معلومات المعاملة';

  @override
  String get type => 'النوع';

  @override
  String get fee => 'الرسوم';

  @override
  String get transactionHash => 'رمز المعاملة';

  @override
  String get fromAddress => 'من العنوان';

  @override
  String get toAddress => 'إلى العنوان';

  @override
  String get note => 'ملاحظة';

  @override
  String get completed => 'مكتمل';

  @override
  String get failed => 'فشل';

  @override
  String get yesterday => 'أمس';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get sol => 'سول';

  @override
  String get solana => 'سولانا';

  @override
  String get sendTo => 'إرسال إلى';

  @override
  String get transactionFees => 'رسوم المعاملات';

  @override
  String get png => 'PNG';

  @override
  String get jpg => 'JPG';

  @override
  String get pdf => 'PDF';

  @override
  String get imageSavedSuccessfully => 'تم حفظ الصورة بنجاح';

  @override
  String transactionSavedSuccessfully(String format) {
    return 'تم حفظ المعاملة كـ $format بنجاح';
  }

  @override
  String get notifications => 'الإشعارات';

  @override
  String get unreadNotification => 'إشعار واحد غير مقروء';

  @override
  String unreadNotifications(int count) {
    return '$count إشعارات غير مقروءة';
  }

  @override
  String get markAsRead => 'تعليم كمقروء';

  @override
  String get forgotPasscodeTitle => 'نسيت رمز المرور';

  @override
  String get verifyYourPhoneNumber => 'تحقق من رقم هاتفك';

  @override
  String get verifyYourAccount => 'تحقق من حسابك';

  @override
  String verificationCodeSentViaSmsTo(String phone) {
    return 'تم إرسال رمز التحقق المكون من 6 أرقام عبر الرسائل القصيرة إلى $phone.';
  }

  @override
  String get verificationCodesIn => 'يجب أن تستلم رموز التحقق خلال';

  @override
  String secondsCount(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String get didntReceiveCodesResendOtp =>
      'لم تستلم الرموز؟ إعادة إرسال رمز التحقق.';

  @override
  String get resendOtp => 'إعادة إرسال رمز التحقق';

  @override
  String get needHelpContactSupport => 'تحتاج مساعدة؟ تواصل مع الدعم';

  @override
  String get setYourNewPasscode => 'قم بتعيين رمز المرور الجديد';

  @override
  String get createAPasscode => 'إنشاء رمز مرور';

  @override
  String get enterYourCurrentPasscode => 'أدخل رمز المرور الحالي';

  @override
  String get enterYourNewPasscode => 'أدخل رمز المرور الجديد';

  @override
  String get confirmYourNewPasscode => 'أكد رمز المرور الجديد';

  @override
  String get confirmYourPasscode => 'تأكيد رمز المرور';

  @override
  String get passcodesMismatchTryAgain =>
      'رموز المرور غير متطابقة. حاول مرة أخرى.';

  @override
  String get qrCodeScanner => 'ماسح رمز QR';

  @override
  String get scanQrCode => 'مسح رمز QR';

  @override
  String get scanAQrCode => 'امسح رمز الاستجابة السريعة';

  @override
  String get cameraPermissionRequired =>
      'الوصول إلى الكاميرا مطلوب لمسح رموز QR';

  @override
  String get cameraPermissionDenied => 'تم رفض إذن الكاميرا';

  @override
  String get cameraPermissionDeniedMessage =>
      'يرجى منح الوصول إلى الكاميرا في الإعدادات لمسح رموز QR.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get allowCamera => 'السماح بالكاميرا';

  @override
  String get cameraError => 'خطأ في الكاميرا';

  @override
  String get cameraErrorMessage =>
      'تعذر الوصول إلى الكاميرا. يرجى المحاولة مرة أخرى.';

  @override
  String cameraPermissionDialogTitle(String appName) {
    return '$appName يريد الوصول إلى الكاميرا';
  }

  @override
  String get cameraPermissionDialogMessage =>
      'نحتاج إلى إذنك للوصول إلى الكاميرا لمسح الرموز';

  @override
  String get doNotAllow => 'عدم السماح';

  @override
  String get invalidQrCode => 'رمز QR غير صالح';

  @override
  String get qrInvalidWalletAddress => 'عنوان المحفظة غير صالح';

  @override
  String get qrAddressVerificationFailed =>
      'تعذر التحقق من العنوان. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get qrAddressNotValidated => 'تعذر التحقق من صحة هذا العنوان';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get twoFactorAuthentication => 'المصادقة الثنائية';

  @override
  String get sendFlowReviewTitle => 'تأكيد';

  @override
  String get sendFlowSendingTitle => 'جاري الإرسال';

  @override
  String get feeFree => 'مجاناً';

  @override
  String get accountNoUserDataAvailable => 'لا توجد بيانات مستخدم';

  @override
  String copyLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get shareComingSoon => 'ميزة المشاركة قريباً';

  @override
  String errorPickingFile(String error) {
    return 'خطأ في اختيار الملف: $error';
  }

  @override
  String get helpRequestSentSuccess => 'تم إرسال الطلب بنجاح';

  @override
  String get verificationCodeResentSuccess =>
      'تم إعادة إرسال رمز التحقق بنجاح.';

  @override
  String get pasteHintLongPress => 'اضغط مع الاستمرار للصق';

  @override
  String get minAmountHint => 'الحد الأدنى 0';

  @override
  String get searchHint => 'بحث';

  @override
  String get searchContactsHint => 'ابحث بالاسم أو الرقم';

  @override
  String get sendFlowVerifyAccountTitle => 'التحقق من الحساب';

  @override
  String sendOtpInstructionsMasked(String phoneMask) {
    return 'أدخل الرمز المرسل إلى $phoneMask';
  }

  @override
  String get verifyAction => 'تحقق';

  @override
  String get swapSuccessMessage => 'تمت المبادلة بنجاح';

  @override
  String get sendSuccessMessage => 'تم الإرسال بنجاح';

  @override
  String get successScreenTitle => 'نجاح';

  @override
  String get confirmSecurely => 'تأكيد بأمان';

  @override
  String get youAreSending => 'أنت ترسل';

  @override
  String get youWillSend => 'ستقوم بإرسال';

  @override
  String get walletAddress => 'عنوان المحفظة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get confirmationWarning =>
      'تأكد من صحة العنوان والشبكة، لا يمكن إلغاء المعاملة بعد التأكيد.';

  @override
  String get sendInProgress => 'جارٍ الإرسال';

  @override
  String get estimatedTimeOfExecution => 'الوقت التقديري للتنفيذ';

  @override
  String get sendCompletionNotification => 'عند الاكتمال، ستتلقى إشعار تأكيد';

  @override
  String get verifyAccount => 'التحقق من الحساب';

  @override
  String get reviewOrderTitle => 'مراجعة الطلب';

  @override
  String get swapDirectionFrom => 'من';

  @override
  String get swapDirectionTo => 'إلى';

  @override
  String get swapMaxAction => 'الحد الأقصى';

  @override
  String get selectCoinTitle => 'اختر العملة';

  @override
  String get selectCoinPlaceholder => 'اختر';

  @override
  String get swapFeesColon => 'رسوم المبادلة:';

  @override
  String get confirmSwapButton => 'تأكيد المبادلة';

  @override
  String get verifyNowButton => 'تحقق الآن';

  @override
  String get swapNowButton => 'ابدأ المبادلة';

  @override
  String get sendFormCoinLabel => 'العملة';

  @override
  String get sendFormPhoneOrAddressLabel => 'رقم الهاتف أو عنوان المحفظة';

  @override
  String get sendFormAmountLabel => 'المبلغ المراد إرساله';

  @override
  String get sendValidationInvalidAmount => 'مبلغ غير صالح';

  @override
  String get sendValidationInsufficientBalance => 'الرصيد غير كافٍ';

  @override
  String get sendDefaultNetworkCode => 'TRC20';

  @override
  String availableBalanceFormatted(String amount, String symbol) {
    return 'المتاح $amount $symbol';
  }

  @override
  String get sendTransactionFeesColon => 'رسوم المعاملة:';

  @override
  String get sendSentAmountLabel => 'المبلغ المرسل';

  @override
  String get walletsTitle => 'المحافظ';

  @override
  String get yourWalletsTitle => 'محافظك';

  @override
  String get networkFeeLabel => 'رسوم الشبكة';

  @override
  String get valueNotAvailable => 'غير متوفر';

  @override
  String get amountInputHint => '0.00';

  @override
  String get qrCodeLabel => 'رمز QR';

  @override
  String get saveImage => 'حفظ الصورة';

  @override
  String get shareAction => 'مشاركة';

  @override
  String get hideZeroBalance => 'إخفاء الرصيد الصفري';

  @override
  String get contactsSheetTitle => 'جهات الاتصال';

  @override
  String sendSuccessRecipientLine(String recipient) {
    return 'إلى: $recipient';
  }

  @override
  String get sendKycVerificationRequiredBody =>
      'التحقق من الهوية مطلوب لإرسال العملات. يُرجى إكمال ملف التحقق من الهوية (KYC) لتفعيل التحويلات. ';

  @override
  String get swapKycVerificationRequiredBody =>
      'التحقق من الهوية مطلوب لمبادلة العملات. يُرجى إكمال ملف التحقق من الهوية (KYC) لتفعيل التحويلات. ';

  @override
  String get receiveKycVerificationRequiredBody =>
      'التحقق من الهوية مطلوب لاستلام العملات. يُرجى إكمال ملف التحقق من الهوية (KYC) لتفعيل التحويلات. ';

  @override
  String get kyc_submitted_under_review =>
      'تم تقديم التحقق من هويتك وهو قيد المراجعة.';

  @override
  String get kyc_pending_subtitle =>
      'نحن نراجع مستنداتك. يستغرق هذا عادةً بضع دقائق. سيتم إعلامك عند اكتمال المراجعة.';

  @override
  String get kyc_rejected => 'تم رفض التحقق من هويتك.';

  @override
  String kyc_rejected_with_reason(String reason) {
    return 'تم رفض التحقق من هويتك: $reason';
  }

  @override
  String get kyc_retry_button => 'إعادة التحقق';

  @override
  String get swapFeesTitle => 'رسوم المبادلة';

  @override
  String get swapExchangeRate => 'سعر الصرف';

  @override
  String get transferToLabel => 'إلى';

  @override
  String get addressCopiedToast => 'تم النسخ';

  @override
  String get availableShortLabel => 'المتاح';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد';

  @override
  String get notificationsLoadError => 'فشل تحميل الإشعارات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get kycFirstNameLabel => 'الاسم الأول';

  @override
  String get kycLastNameLabel => 'اسم العائلة';

  @override
  String get kycDateOfBirthLabel => 'تاريخ الميلاد';

  @override
  String get kycResidentialCountryLabel => 'بلد الإقامة';

  @override
  String get kycDocumentCountryLabel => 'بلد الوثيقة';

  @override
  String get kycCityLabel => 'المدينة';

  @override
  String get kycAddressLabel => 'العنوان';

  @override
  String get kycCountryCodeHint => 'مثال: GBR، USA، IND';

  @override
  String get kycSelectDateHint => 'MM/DD/YYYY';

  @override
  String get kycRequiredFieldError => 'هذا الحقل مطلوب';

  @override
  String get kycSubmitButton => 'إرسال';

  @override
  String get kycInvalidDateError => 'يرجى اختيار تاريخ صالح';

  @override
  String get kycStartedSuccess => 'تم بدء عملية التحقق من الهوية بنجاح.';

  @override
  String get youAreOffline => 'أنت غير متصل بالإنترنت';

  @override
  String get contactsPermissionDenied =>
      'يلزم إذن الوصول إلى جهات الاتصال لاختيار جهة اتصال. يُرجى تفعيله من إعدادات جهازك.';

  @override
  String get contactsLoading => 'جارٍ تحميل جهات الاتصال...';

  @override
  String get noContactsFound => 'لم يتم العثور على جهات اتصال';

  @override
  String contactsPermissionDialogTitle(String appName) {
    return '$appName يريد الوصول إلى جهات الاتصال';
  }

  @override
  String get contactsPermissionDialogMessage =>
      'نحتاج إلى إذنك للوصول إلى جهات الاتصال لإرسال المدفوعات إلى الأشخاص في دفتر العناوين الخاص بك';

  @override
  String get allowContacts => 'السماح بجهات الاتصال';

  @override
  String get sendInvitationDialogTitle => 'إرسال دعوة';

  @override
  String get sendInvitationDialogMessage =>
      'هذا الرقم لا يملك حسابًا على أوملاباي. لتجربة أفضل، أرسل له دعوة.';

  @override
  String get sendInvitationDialogNote =>
      'ملاحظة: يمكنك إتمام المعاملة على أي حال';

  @override
  String get sendInvitationInviteButton => 'دعوة';

  @override
  String get checkingUserStatus => 'جارٍ التحقق من المستخدم...';

  @override
  String get kycEnterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get kycWhatsYourEmail => 'ما هو بريدك الإلكتروني؟';

  @override
  String get kycEmailSubtitle => 'سنرسل رمز تحقق لتأكيد بريدك الإلكتروني';

  @override
  String get kycEmailHint => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get kycEmailRequiredError => 'عنوان البريد الإلكتروني مطلوب';

  @override
  String get kycEmailInvalidError => 'يرجى إدخال عنوان بريد إلكتروني صالح';

  @override
  String get kycVerifyEmail => 'تحقق من البريد الإلكتروني';

  @override
  String get kycVerifyEmailTitle => 'أدخل رمز التحقق';

  @override
  String kycVerifyEmailSubtitle(String email) {
    return 'لقد أرسلنا رمزًا مكونًا من 6 أرقام إلى $email';
  }

  @override
  String get kycEmailVerified => 'تم التحقق من البريد الإلكتروني بنجاح';

  @override
  String get pleaseEnterATitle => 'يرجى إدخال عنوان';

  @override
  String titleMustNotExceedCharacters(int maxLength) {
    return 'يجب ألا يتجاوز العنوان $maxLength حرفًا';
  }

  @override
  String get pleaseEnterADescription => 'يرجى إدخال وصف';

  @override
  String descriptionMustNotExceedCharacters(int maxLength) {
    return 'يجب ألا يتجاوز الوصف $maxLength حرفًا';
  }

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get failedToLoadNotifications => 'فشل في تحميل الإشعارات';

  @override
  String get failedToLoadMoreNotifications =>
      'فشل في تحميل المزيد من الإشعارات';

  @override
  String get failedToMarkNotificationAsRead => 'فشل في تحديد الإشعار كمقروء';

  @override
  String get failedToMarkAllNotificationsAsRead =>
      'فشل في تحديد جميع الإشعارات كمقروءة';

  @override
  String get failedToLoadSupportRequests => 'فشل في تحميل طلبات الدعم';

  @override
  String get failedToLoadMoreRequests => 'فشل في تحميل المزيد من الطلبات';

  @override
  String get walletAddressMasked => 'XXXX XXXX XXXX XXXX';

  @override
  String get walletAddressNotAvailable => 'العنوان غير متوفر بعد';

  @override
  String get noAddressFound => 'لم يتم العثور على عنوان';

  @override
  String get issueNotResolved => 'المشكلة لم تحل؟';

  @override
  String get reopenTicket => 'إعادة فتح التذكرة';

  @override
  String createdOn(String date) {
    return 'تم الإنشاء في $date';
  }

  @override
  String get requestReopened => 'تم إعادة فتح التذكرة بنجاح';

  @override
  String get failedToReopenRequest => 'فشل في إعادة فتح التذكرة';

  @override
  String get failedToLoadRequestDetail => 'فشل في تحميل تفاصيل الطلب';

  @override
  String get inReview => 'قيد المراجعة';

  @override
  String resolvesBy(String date) {
    return 'يُحل بحلول $date';
  }

  @override
  String get resolvedStatus => 'تم الحل';

  @override
  String get rejectedStatus => 'مرفوض';

  @override
  String get failureReason => 'السبب';

  @override
  String approximateAmount(String amount, String currency) {
    return '≈$amount $currency';
  }
}
