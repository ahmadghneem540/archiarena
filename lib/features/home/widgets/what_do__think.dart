import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/home_api_service.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';

class WhatDoThink extends StatefulWidget {
  const WhatDoThink({super.key, required this.controller});
  final HomeController controller;

  @override
  State<WhatDoThink> createState() => _WhatDoThinkState();
}

class _WhatDoThinkState extends State<WhatDoThink> {
  final ImagePicker _imagePicker = ImagePicker();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _timerDaysController = TextEditingController();
  final _timerHoursController = TextEditingController();
  final _timerMinutesController = TextEditingController();

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
    _budgetController.dispose();
    _deadlineController.dispose();
    _timerDaysController.dispose();
    _timerHoursController.dispose();
    _timerMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) return;
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

  void _pickPlanFile() {
    Get.snackbar(
      'info'.tr,
      'plan_pdf_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  int? _parseInt(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    return int.tryParse(s.trim());
  }

  Future<void> _submitProject() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (_images.isEmpty) {
      _error('upload_project_main_image_required'.tr);
      return;
    }
    if (title.isEmpty) {
      _error('upload_project_title_required'.tr);
      return;
    }
    if (description.isEmpty) {
      _error('upload_project_description_required'.tr);
      return;
    }
    if (_selectedCategory == null) {
      _error('upload_project_category_required'.tr);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final timerDays = _parseInt(_timerDaysController.text);
      final timerHours = _parseInt(_timerHoursController.text);
      final timerMinutes = _parseInt(_timerMinutesController.text);

      final res = await HomeApiService.createPost(
        title: title,
        category: _selectedCategory!,
        description: description,
        budget: _budgetController.text.trim().isEmpty
            ? null
            : _budgetController.text.trim(),
        deadline: _deadlineController.text.trim().isEmpty
            ? null
            : _deadlineController.text.trim(),
        timerDays: timerDays,
        timerHours: timerHours,
        timerMinutes: timerMinutes,
        images: _images,
      );

      if (!mounted) return;

      if (res.isSuccess) {
        widget.controller.loadPosts();
        Get.back();
        Get.snackbar(
          'success'.tr,
          'upload_project_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.onPrimary,
        );
      } else {
        _error(res.message ?? 'upload_project_failed'.tr);
      }
    } catch (e) {
      if (mounted) _error('upload_project_failed'.tr);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _error(String msg) {
    Get.snackbar('alert'.tr, msg, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('upload_project'.tr), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildMainImageSection(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildBudgetField(),
                  const SizedBox(height: 16),
                  _buildDeadlineField(),
                  const SizedBox(height: 16),
                  _buildTimerSection(),
                  const SizedBox(height: 16),
                  _buildPlanFileSection(),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: _isUploading ? 0.7 : 1,
                    child: ArchiButton(
                      label: _isUploading ? 'uploading'.tr : 'upload_project'.tr,
                      onPressed: _isUploading ? () {} : _submitProject,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'upload_project_images_label'.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ...List.generate(_images.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _images[i],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_images.length < _maxImages)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.placeholder2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.grey600),
                        const SizedBox(height: 4),
                        Text(
                          'choose_main_image'.tr,
                          style: TextStyle(fontSize: 12, color: AppColors.grey600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'project_timer_label'.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _timerDaysController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'timer_days_hint'.tr,
                  prefixIcon: const Icon(Icons.calendar_today, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _timerHoursController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'timer_hours_hint'.tr,
                  prefixIcon: const Icon(Icons.schedule, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _timerMinutesController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'timer_minutes_hint'.tr,
                  prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'project_title_required'.tr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _titleController,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(hintText: 'enter_project_title'.tr),
      ),
    ],
  );

  Widget _buildDescriptionField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'project_description_label'.tr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _descriptionController,
        textDirection: TextDirection.rtl,
        maxLines: 4,
        decoration: InputDecoration(hintText: 'project_description_hint'.tr),
      ),
    ],
  );

  Widget _buildBudgetField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'project_budget'.tr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _budgetController,
        textDirection: TextDirection.rtl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'enter_budget'.tr,
          prefixIcon: const Icon(Icons.attach_money, size: 22),
        ),
      ),
    ],
  );

  Widget _buildDeadlineField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'project_deadline'.tr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _deadlineController,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'enter_deadline'.tr,
          prefixIcon: const Icon(Icons.timer_outlined, size: 22),
        ),
      ),
    ],
  );

  Widget _buildCategoryDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'تصنيف المشروع *',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _selectedCategory,
        hint: Text('choose_category'.tr),
        items: _categoryKeys
            .map((k) => DropdownMenuItem(value: k, child: Text('category_$k'.tr)))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
      ),
    ],
  );

  Widget _buildPlanFileSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'ملف مخطط المشروع (اختياري)',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _pickPlanFile,
        icon: const Icon(Icons.upload_file),
        label: Text('upload_plan_pdf'.tr),
      ),
    ],
  );
}
