import 'package:get/get.dart';
import 'create_account_company_describe_controller.dart';

class CreateAccountCompanyDescribeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAccountCompanyDescribeController>(
      () => CreateAccountCompanyDescribeController(),
    );
  }
}
