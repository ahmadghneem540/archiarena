import 'package:get/get.dart';
import 'terms_and_privacy_controller.dart';

class TermsAndPrivacyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsAndPrivacyController>(() => TermsAndPrivacyController());
  }
}
