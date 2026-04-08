import 'package:get/get.dart';
import 'language_select_controller.dart';

class LanguageSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageSelectController>(() => LanguageSelectController());
  }
}
