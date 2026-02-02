import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class TermsAndPrivacyController extends GetxController {
  void signUp() {
    Get.offAllNamed(AppRoutes.home);
  }

  void signUpWithoutUpdatingContact() {
    Get.offAllNamed(AppRoutes.home);
  }
}
