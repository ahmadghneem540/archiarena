import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/home_api_service.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';
import '../models/post_model.dart';

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

  static const List<MapEntry<String, String>> _categoryOptions = [
    MapEntry('residential', 'category_residential'),
    MapEntry('commercial', 'category_commercial'),
    MapEntry('admin', 'category_admin'),
    MapEntry('education', 'category_education'),
    MapEntry('health', 'category_health'),
    MapEntry('entertainment', 'category_entertainment'),
    MapEntry('interior', 'category_interior'),
    MapEntry('other', 'category_other'),
  ];

  /// نموذج تقديم عرض على مشروع (من صفحة الأعمال) — رسالة + صورة
  static void showProposalSheet(PostModel post, HomeController controller) {
    if (post.isDealExpired) {
      Get.snackbar(
        'alert'.tr,
        'project_time_ended'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.bottomSheet(
      _ProposalOfferSheet(post: post, controller: controller),
      isScrollControlled: true,
    );
  }

  void _showUploadSheet(BuildContext context, HomeController homeController) {
    final imageFile = Rxn<File>();
    final isLoading = false.obs;
    final title = ''.obs;
    final description = ''.obs;
    final categoryValue = 'other'.obs;
    final picker = ImagePicker();
    final titleController = TextEditingController();
    final descController = TextEditingController();

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
          decoration: BoxDecoration(
            color: context.themeSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'upload_project'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.themeOnSurface,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  onChanged: (v) => title.value = v,
                  decoration: InputDecoration(
                    labelText: 'project_title_hint'.tr,
                    hintText: 'enter_project_title'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  onChanged: (v) => description.value = v,
                  decoration: InputDecoration(
                    labelText: 'project_description_label'.tr,
                    hintText: 'project_description_hint'.tr,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: categoryValue.value,
                    decoration: InputDecoration(
                      labelText: 'project_type'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: _categoryOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value.tr),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) categoryValue.value = v;
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
                                border: Border.all(color: context.themeBorder),
                                borderRadius: BorderRadius.circular(12),
                                color: context.themeCardBackground,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: context.themeGrey600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'choose_main_image'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.themeGrey600,
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
                      final titleStr = titleController.text.trim();
                      final descStr = descController.text.trim();
                      if (titleStr.isEmpty) {
                        Get.snackbar(
                          'alert'.tr,
                          'upload_project_title_required'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      if (descStr.isEmpty) {
                        Get.snackbar(
                          'alert'.tr,
                          'upload_project_description_required'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      isLoading.value = true;
                      try {
                        final res = await HomeApiService.createCompanyPost(
                          title: titleStr,
                          category: categoryValue.value,
                          description: descStr,
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
    ).then((_) {
      titleController.dispose();
      descController.dispose();
    });
  }
}

/// شيت تقديم العرض — StatefulWidget لربط [TextEditingController] بدورة حياة الويدجت وتجنب dispose مبكر.
class _ProposalOfferSheet extends StatefulWidget {
  const _ProposalOfferSheet({
    required this.post,
    required this.controller,
  });

  final PostModel post;
  final HomeController controller;

  @override
  State<_ProposalOfferSheet> createState() => _ProposalOfferSheetState();
}

class _ProposalOfferSheetState extends State<_ProposalOfferSheet> {
  final Rxn<File> imageFile = Rxn<File>();
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final controller = widget.controller;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: context.themeSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${'submit_proposal'.tr} — ${post.title}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.themeOnSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Obx(() {
                final conditions = controller.uploadConditions;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.themeCardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.themeBorder),
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
                      Text(
                        'الشروط:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: context.themeOnSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (conditions.isEmpty)
                        Text(
                          '• احصل على تقييم كامل بعلامة ناجح',
                          style: TextStyle(color: context.themeGrey700),
                        )
                      else
                        ...conditions.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $c',
                              style: TextStyle(color: context.themeGrey700),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'رسالة العرض',
                  hintText: 'اكتب تفاصيل عرضك هنا',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
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
                            final x = await _picker.pickImage(
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
                              border: Border.all(color: context.themeBorder),
                              borderRadius: BorderRadius.circular(12),
                              color: context.themeCardBackground,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: context.themeGrey600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'choose_proposal_image'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.themeGrey600,
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
                  label:
                      isLoading.value ? 'uploading'.tr : 'submit_proposal'.tr,
                  onPressed: () async {
                    if (isLoading.value) return;
                    final message = _messageController.text.trim();
                    final file = imageFile.value;
                    if (message.isEmpty) {
                      Get.snackbar(
                        'alert'.tr,
                        'يرجى كتابة رسالة العرض',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    if (file == null) {
                      Get.snackbar(
                        'alert'.tr,
                        'proposal_image_required'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    isLoading.value = true;
                    try {
                      final orderId = post.orderId ?? post.id;

                      if (orderId <= 0) {
                        Get.snackbar(
                          'error'.tr,
                          'لا يمكن تقديم عرض على هذا المشروع',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final res = await HomeApiService.submitProposal(
                        orderId,
                        message: message,
                        image: file,
                      );
                      if (res.isSuccess) {
                        Get.back();
                        Get.snackbar(
                          'success'.tr,
                          'proposal_submitted_success'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: AppColors.onPrimary,
                        );
                      } else {
                        Get.snackbar(
                          'error'.tr,
                          res.message ?? 'proposal_submit_failed'.tr,
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
    );
  }
}
