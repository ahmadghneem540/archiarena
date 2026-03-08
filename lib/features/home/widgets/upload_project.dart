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
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final categoryController = TextEditingController();
    final images = <File>[].obs;
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
                const Text(
                  'رفع مشروع جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'عنوان المشروع',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    hintText: 'التصنيف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...images.map(
                        (f) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                f,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () => images.remove(f),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (images.length < 10)
                        GestureDetector(
                          onTap: () async {
                            final x = await picker.pickMultiImage();
                            if (x.isNotEmpty) {
                              for (var f in x) {
                                images.add(File(f.path));
                              }
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_photo_alternate),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => ArchiButton(
                    label: isLoading.value ? 'جاري الرفع...' : 'رفع',
                    onPressed: () async {
                      if (isLoading.value) return;
                      final title = titleController.text.trim();
                      final category = categoryController.text.trim();
                      final desc = descController.text.trim();
                      if (title.isEmpty || category.isEmpty || desc.isEmpty) {
                        Get.snackbar(
                          'تنبيه',
                          'يرجى ملء العنوان والتصنيف والوصف',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      isLoading.value = true;
                      try {
                        final res = await HomeApiService.createPost(
                          title: title,
                          category: category,
                          description: desc,
                          images: images.isEmpty ? null : images,
                        );
                        if (res.isSuccess) {
                          Get.back();
                          homeController.closeUploadPage();
                          homeController.loadPosts();
                          Get.snackbar(
                            'تم بنجاح',
                            'تم رفع المشروع',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primary,
                            colorText: AppColors.onPrimary,
                          );
                        } else {
                          Get.snackbar(
                            'فشل',
                            res.message ?? 'حدث خطأ',
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
