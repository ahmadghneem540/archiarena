import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class CreateAccountIntroController extends GetxController {
  void next() {
    Get.toNamed(AppRoutes.createAccountName);
  }

  void alreadyHaveAccount() {
    Get.offAllNamed(AppRoutes.authLogin);
  }
}
