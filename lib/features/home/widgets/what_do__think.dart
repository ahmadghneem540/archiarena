import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
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

  File? _mainImage;
  final List<File> _secondaryImages = [];
  static const int _maxSecondaryImages = 6;
  String? _selectedCategory;
  bool _isUploading = false;

  final List<String> _categories = [
    'سكني',
    'تجاري',
    'إداري',
    'تعليمي',
    'صحي',
    'ترفيهي',
    'آخر',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file != null) {
      setState(() => _mainImage = File(file.path));
    }
  }

  void _pickPlanFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('plan_pdf_soon'.tr),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitProject() {
    final title = _titleController.text.trim();

    if (_mainImage == null) {
      _error('يجب اختيار صورة رئيسية للمشروع');
      return;
    }
    if (title.isEmpty) {
      _error('يجب إدخال عنوان المشروع');
      return;
    }
    if (_selectedCategory == null) {
      _error('يجب اختيار تصنيف المشروع');
      return;
    }

    setState(() => _isUploading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('upload_project_success'.tr),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context); // رجوع تلقائي بعد النجاح
    });
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
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
          child: const Text(
            'الصورة الرئيسية للمشروع *',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMainImage,
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // عرض الشاشة كامل
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.placeholder2,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: _mainImage != null
                      ? AppColors.primary
                      : AppColors.border,
                  width: _mainImage != null ? 2 : 1,
                ),
              ),
              child: _mainImage != null
                  ? Image.file(
                      _mainImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 48),
                        const SizedBox(height: 8),
                        Text('choose_main_image'.tr),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'عنوان المشروع *',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _titleController,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(hintText: 'أدخل عنوان المشروع'),
      ),
    ],
  );

  Widget _buildDescriptionField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'شرح المشروع *',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _descriptionController,
        textDirection: TextDirection.rtl,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'وصف المشروع وتفاصيله'),
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
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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
