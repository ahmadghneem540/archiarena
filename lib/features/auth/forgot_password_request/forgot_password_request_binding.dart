import 'package:get/get.dart';
import 'forgot_password_request_controller.dart';

class ForgotPasswordRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordRequestController>(
      () => ForgotPasswordRequestController(),
    );
  }
}
