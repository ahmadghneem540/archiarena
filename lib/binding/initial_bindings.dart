import 'package:get/get.dart';
import '../core/class/network_controller.dart';
import '../features/splash/splash_controller.dart';

/// تسجيل الخدمات العامة قبل أي شاشة — خفيف وسريع حتى لا يؤخر ظهور الـ splash.
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController(), permanent: false);
    Get.put(NetworkController(), permanent: true);
  }
}