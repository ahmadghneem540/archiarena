import 'package:get/get.dart';
import 'create_account_describe_controller.dart';

class CreateAccountDescribeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAccountDescribeController>(
      () => CreateAccountDescribeController(),
    );
  }
}
