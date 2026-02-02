import 'package:get/get.dart';
import 'create_account_name_controller.dart';

class CreateAccountNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAccountNameController>(
      () => CreateAccountNameController(),
    );
  }
}
