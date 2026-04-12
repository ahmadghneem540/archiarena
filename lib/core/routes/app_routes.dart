abstract class AppRoutes {
  static const String languageSelect = '/language-select';
  static const String splash = '/splash';
  static const String home = '/home';
  static const String authLogin = '/auth/login';
  static const String forgotPasswordRequest = '/auth/forgot-password-request';
  static const String forgotPasswordReset = '/auth/forgot-password-reset';
  static const String changePassword = '/auth/change-password';
  static const String createAccountIntro = '/auth/create-account-intro';
  static const String createAccountDescribe = '/auth/create-account-describe';
  static const String createAccountName = '/auth/create-account-name';
  static const String createAccountCompany = '/auth/create-account-company';
  static const String createAccountCompanyDescribe = '/auth/create-account-company-describe';
  static const String termsAndPrivacy = '/auth/terms-and-privacy';
  static const String verifyEmail = '/auth/verify-email';

  // صفحات فرعية للقائمة (Menu)
  static const String menuPrivacySecurity = '/menu/privacy-security';
  static const String menuProfessionalAccount = '/menu/professional-account';
  static const String menuNotificationSettings = '/menu/notification-settings';
  static const String menuLanguage = '/menu/language';
  static const String menuAppearance = '/menu/appearance';
  static const String menuHelpSupport = '/menu/help-support';
  static const String menuFeedback = '/menu/feedback';
  static const String menuAbout = '/menu/about';
  /// سياسة الخصوصية وشروط الاستخدام (النص الكامل للمتاجر)
  static const String menuTermsPrivacy = '/menu/terms-privacy';

  /// صندوق الوارد (محادثات + طلبات مراسلة)
  static const String chatInbox = '/chat/inbox';
}
