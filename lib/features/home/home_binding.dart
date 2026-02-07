import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // استخدام put بدلاً من lazyPut لضمان وجود Controller فوراً
    Get.put<HomeController>(HomeController());
  }
}
