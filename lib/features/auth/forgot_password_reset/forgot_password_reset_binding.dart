import 'package:get/get.dart';
import 'forgot_password_reset_controller.dart';

class ForgotPasswordResetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordResetController>(
      () => ForgotPasswordResetController(),
    );
  }
}
