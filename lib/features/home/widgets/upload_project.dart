import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/home_api_service.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';

class UploadProjectPage extends StatelessWidget {
  const UploadProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// الشروط من الـ API
          Obx(() {
            final conditions = controller.uploadConditions;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الشروط:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (conditions.isEmpty)
                    Text(
                      '• احصل على تقييم كامل بعلامة ناجح',
                      style: TextStyle(color: AppColors.grey700),
                    )
                  else
                    ...conditions.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $c'),
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          /// كارد الرفع
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xffEAF4F4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.teal.withOpacity(.2)),
            ),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'شارك أعمالك وتصاميمك الإبداعية',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ArchiButton(
                  label: 'رفع المشروع',
                  height: 48,
                  fontSize: 16,
                  icon: Icons.upload_file_outlined,
                  onPressed: () => _showUploadSheet(context, controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadSheet(BuildContext context, HomeController homeController) {
    final imageFile = Rxn<File>();
    final isLoading = false.obs;
    final picker = ImagePicker();

    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'upload_project'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () {
                    final file = imageFile.value;
                    return Column(
                      children: [
                        if (file != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  file,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: GestureDetector(
                                  onTap: () => imageFile.value = null,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () async {
                              final x = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 90,
                              );
                              if (x != null) {
                                imageFile.value = File(x.path);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.cardBackground,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: AppColors.grey500,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'choose_main_image'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Obx(
                  () => ArchiButton(
                    label: isLoading.value ? 'uploading'.tr : 'upload_project'.tr,
                    onPressed: () async {
                      if (isLoading.value) return;
                      final file = imageFile.value;
                      if (file == null) {
                        Get.snackbar(
                          'alert'.tr,
                          'upload_project_main_image_required'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      isLoading.value = true;
                      try {
                        final res = await HomeApiService.createCompanyPost(
                          title: 'مشروع',
                          category: 'other',
                          description: '—',
                          images: [file],
                        );
                        if (res.isSuccess) {
                          Get.back();
                          homeController.closeUploadPage();
                          homeController.loadOrders();
                          Get.snackbar(
                            'success'.tr,
                            'upload_project_success'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primary,
                            colorText: AppColors.onPrimary,
                          );
                        } else {
                          Get.snackbar(
                            'error'.tr,
                            res.message ?? 'upload_project_failed'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      } finally {
                        isLoading.value = false;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
