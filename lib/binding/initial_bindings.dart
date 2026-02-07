import 'package:get/get.dart';
import '../core/class/network_controller.dart';
import '../features/splash/splash_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
    Get.put(NetworkController(), permanent: true);
  }
}