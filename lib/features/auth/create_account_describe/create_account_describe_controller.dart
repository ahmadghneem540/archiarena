import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';

enum UserType { hobbyist, engineer, advancedStudies }

class CreateAccountDescribeController extends GetxController {
  final Rx<UserType> selectedType = UserType.engineer.obs;
  final Rx<File?> certificateFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  void selectType(UserType type) {
    selectedType.value = type;
  }

  Future<void> pickCertificate() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      certificateFile.value = File(file.path);
    }
  }

  void next() {
    Get.toNamed(AppRoutes.termsAndPrivacy);
  }

  void alreadyHaveAccount() {
    Get.back();
  }
}
