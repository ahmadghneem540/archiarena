import 'package:get/get.dart';
import 'create_account_intro_controller.dart';

class CreateAccountIntroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAccountIntroController>(
      () => CreateAccountIntroController(),
    );
  }
}
