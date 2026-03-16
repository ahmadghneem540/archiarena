import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/profile_api_service.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';

/// شيت إنشاء منشور للملف الشخصي — يظهر في صفحة المستخدم فقط (POST /profile/me/posts)
class ProfilePostCreateSheet extends StatefulWidget {
  const ProfilePostCreateSheet({super.key, required this.controller});

  final HomeController controller;

  @override
  State<ProfilePostCreateSheet> createState() => _ProfilePostCreateSheetState();
}

class _ProfilePostCreateSheetState extends State<ProfilePostCreateSheet> {
  final ImagePicker _imagePicker = ImagePicker();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File> _images = [];
  static const int _maxImages = 10;
  String? _selectedCategory;
  bool _isUploading = false;

  static const List<String> _categoryKeys = [
    'residential', 'commercial', 'admin', 'education', 'health',
    'entertainment', 'interior', 'other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= _maxImages) return;
    final files = await _imagePicker.pickMultiImage(imageQuality: 90);
    if (files.isEmpty) return;
    setState(() {
      for (var i = 0; i < files.length && _images.length < _maxImages; i++) {
        _images.add(File(files[i].path));
      }
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (_images.isEmpty) {
      Get.snackbar('alert'.tr, 'upload_project_main_image_required'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (title.isEmpty) {
      Get.snackbar('alert'.tr, 'upload_project_title_required'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (description.isEmpty) {
      Get.snackbar('alert'.tr, 'upload_project_description_required'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedCategory == null) {
      Get.snackbar('alert'.tr, 'upload_project_category_required'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final res = await ProfileApiService.createProfilePost(
        title: title,
        description: description,
        category: _selectedCategory!,
        images: _images,
      );

      if (!mounted) return;

      if (res.isSuccess) {
        widget.controller.loadMyProfilePosts();
        Get.back();
        Get.snackbar(
          'success'.tr,
          'upload_project_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.onPrimary,
        );
      } else {
        Get.snackbar('error'.tr, res.message ?? 'upload_project_failed'.tr, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      if (mounted) Get.snackbar('error'.tr, 'upload_project_failed'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
                'what_do_you_think'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 16),
              _buildImagesSection(),
              const SizedBox(height: 16),
              _buildTitleField(isRtl),
              const SizedBox(height: 12),
              _buildDescriptionField(isRtl),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              ArchiButton(
                label: _isUploading ? 'uploading'.tr : 'upload_project'.tr,
                onPressed: _isUploading ? () {} : _submit,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('upload_project_images_label'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(_images.length, (i) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_images[i], width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              if (_images.length < _maxImages)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.placeholder2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.grey600, size: 28),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isRtl) {
    return TextField(
      controller: _titleController,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: 'project_title_hint'.tr,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDescriptionField(bool isRtl) {
    return TextField(
      controller: _descriptionController,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'project_description_hint'.tr,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      hint: Text('choose_category'.tr),
      items: _categoryKeys.map((k) => DropdownMenuItem(value: k, child: Text('category_$k'.tr))).toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
    );
  }
}
