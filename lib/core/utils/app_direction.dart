import 'package:get/get.dart';

bool get isRTL => Get.locale?.languageCode == 'ar';
bool get isLTR => !isRTL;