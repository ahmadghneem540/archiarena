import 'package:get/get.dart';
import '../features/language_select/language_select_view.dart';
import '../features/language_select/language_select_binding.dart';
import '../features/splash/splash_view.dart';
import '../features/splash/splash_binding.dart';
import '../features/home/home_view.dart';
import '../features/home/home_binding.dart';
import '../features/auth/create_account_intro/create_account_intro_view.dart';
import '../features/auth/create_account_intro/create_account_intro_binding.dart';
import '../features/auth/create_account_describe/create_account_describe_view.dart';
import '../features/auth/create_account_describe/create_account_describe_binding.dart';
import '../features/auth/create_account_name/create_account_name_view.dart';
import '../features/auth/create_account_name/create_account_name_binding.dart';
import '../features/auth/create_account_company/create_account_company_view.dart';
import '../features/auth/create_account_company/create_account_company_binding.dart';
import '../features/auth/create_account_company_describe/create_account_company_describe_view.dart';
import '../features/auth/create_account_company_describe/create_account_company_describe_binding.dart';
import '../features/auth/terms_and_privacy/terms_and_privacy_view.dart';
import '../features/auth/terms_and_privacy/terms_and_privacy_binding.dart';
import '../features/auth/verify_email/verify_email_view.dart';
import '../features/auth/verify_email/verify_email_binding.dart';
import '../features/auth/login/login_view.dart';
import '../features/auth/login/login_binding.dart';
import '../features/auth/forgot_password_request/forgot_password_request_view.dart';
import '../features/auth/forgot_password_request/forgot_password_request_binding.dart';
import '../features/auth/forgot_password_reset/forgot_password_reset_view.dart';
import '../features/auth/forgot_password_reset/forgot_password_reset_binding.dart';
import '../features/auth/change_password/change_password_view.dart';
import '../features/auth/change_password/change_password_binding.dart';
import '../features/menu/privacy_security_view.dart';
import '../features/menu/professional_account_view.dart';
import '../features/menu/notification_settings_view.dart';
import '../features/menu/language_view.dart';
import '../features/menu/appearance_view.dart';
import '../features/menu/help_support_view.dart';
import '../features/menu/feedback_view.dart';
import '../features/menu/about_view.dart';
import '../core/routes/app_routes.dart';

class AppBindings {
  static List<GetPage> get pages => [
    GetPage(
      name: AppRoutes.languageSelect,
      page: () => const LanguageSelectView(),
      binding: LanguageSelectBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.authLogin,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordRequest,
      page: () => const ForgotPasswordRequestView(),
      binding: ForgotPasswordRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordReset,
      page: () => const ForgotPasswordResetView(),
      binding: ForgotPasswordResetBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.createAccountIntro,
      page: () => const CreateAccountIntroView(),
      binding: CreateAccountIntroBinding(),
    ),
    GetPage(
      name: AppRoutes.createAccountDescribe,
      page: () => const CreateAccountDescribeView(),
      binding: CreateAccountDescribeBinding(),
    ),
    GetPage(
      name: AppRoutes.createAccountName,
      page: () => const CreateAccountNameView(),
      binding: CreateAccountNameBinding(),
    ),
    GetPage(
      name: AppRoutes.createAccountCompany,
      page: () => const CreateAccountCompanyView(),
      binding: CreateAccountCompanyBinding(),
    ),
    GetPage(
      name: AppRoutes.createAccountCompanyDescribe,
      page: () => const CreateAccountCompanyDescribeView(),
      binding: CreateAccountCompanyDescribeBinding(),
    ),
    GetPage(
      name: AppRoutes.termsAndPrivacy,
      page: () => const TermsAndPrivacyView(),
      binding: TermsAndPrivacyBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
      binding: VerifyEmailBinding(),
    ),
    // صفحات فرعية للقائمة
    GetPage(
      name: AppRoutes.menuPrivacySecurity,
      page: () => const PrivacySecurityView(),
    ),
    GetPage(
      name: AppRoutes.menuProfessionalAccount,
      page: () => const ProfessionalAccountView(),
    ),
    GetPage(
      name: AppRoutes.menuNotificationSettings,
      page: () => const NotificationSettingsView(),
    ),
    GetPage(name: AppRoutes.menuLanguage, page: () => const LanguageView()),
    GetPage(name: AppRoutes.menuAppearance, page: () => const AppearanceView()),
    GetPage(
      name: AppRoutes.menuHelpSupport,
      page: () => const HelpSupportView(),
    ),
    GetPage(name: AppRoutes.menuFeedback, page: () => const FeedbackView()),
    GetPage(name: AppRoutes.menuAbout, page: () => const AboutView()),
  ];
}
