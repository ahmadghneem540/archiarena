import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class TermsAndPrivacyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  void signUp() {
    _navigateToLogin();
  }

  void signUpWithoutUpdatingContact() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    // التحقق من المعاملات المرسلة من الصفحة السابقة
    final arguments = Get.arguments;
    final isCompany = arguments != null && arguments['isCompany'] == true;
    
    // تمرير نوع المستخدم إلى صفحة تسجيل الدخول
    Get.offAllNamed(AppRoutes.authLogin, arguments: {'isCompany': isCompany});
  }
}
