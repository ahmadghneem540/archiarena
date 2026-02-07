import 'package:get/get.dart';
import 'create_account_company_controller.dart';

class CreateAccountCompanyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAccountCompanyController>(
      () => CreateAccountCompanyController(),
    );
  }
}
