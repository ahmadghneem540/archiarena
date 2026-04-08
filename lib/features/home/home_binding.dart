import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // إنشاء الـ controller عند دخول /home فقط، ويُحذف تلقائياً عند الخروج (SmartManagement)
    Get.lazyPut<HomeController>(() => HomeController(), fenix: false);
  }
}
