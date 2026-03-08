import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';

class CreateAccountCompanyDescribeController extends GetxController {
  final Rx<File?> licenseFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickLicenseFile() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      licenseFile.value = File(file.path);
    }
  }

  void next() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final data = Map<String, dynamic>.from(args)
      ..['licenseFile'] = licenseFile.value;
    Get.toNamed(AppRoutes.termsAndPrivacy, arguments: data);
  }

  void alreadyHaveAccount() {
    Get.back();
  }
}
