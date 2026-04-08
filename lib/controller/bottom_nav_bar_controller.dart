import 'package:get/get.dart';

class BottomNavBarController extends GetxController {
  RxInt currentIndex = 3.obs; // Default to Home (index 3 based on existing LorryBottomNavBar)

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
