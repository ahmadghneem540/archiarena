import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';

/// شاشة التاب الثاني — رفع المشاريع مع الشروط والنموذج.
class UploadProjectView extends StatefulWidget {
  const UploadProjectView({super.key, required this.controller});

  final HomeController controller;

  @override
  State<UploadProjectView> createState() => _UploadProjectViewState();
}

class _UploadProjectViewState extends State<UploadProjectView> {
  final ImagePicker _imagePicker = ImagePicker();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

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

  Future<void> _pickSecondaryImage(int index) async {
    if (_secondaryImages.length >= _maxSecondaryImages) return;
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() {
        if (index < _secondaryImages.length) {
          _secondaryImages[index] = File(file.path);
        } else {
          _secondaryImages.add(File(file.path));
        }
      });
    }
  }

  void _removeSecondaryImage(int index) {
    setState(() => _secondaryImages.removeAt(index));
  }

  void _pickPlanFile() async {
    // يمكن إضافة file_picker لاحقاً لاختيار PDF
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختيار ملف المخطط (PDF) — قريباً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _submitProject() {
    final title = _titleController.text.trim();

    if (_mainImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب اختيار صورة رئيسية للمشروع'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال عنوان المشروع'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب اختيار تصنيف المشروع'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    // محاكاة رفع — يمكن ربطها بالـ API لاحقاً
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع المشروع بنجاح'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _mainImage = null;
        _secondaryImages.clear();
        _selectedCategory = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          _buildConditions(),
          const SizedBox(height: 24),
          _buildMainImageSection(),
          const SizedBox(height: 20),
          _buildSecondaryImagesSection(),
          const SizedBox(height: 20),
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildPlanFileSection(),
          const SizedBox(height: 24),
          Opacity(
            opacity: _isUploading ? 0.7 : 1,
            child: ArchiButton(
              label: _isUploading ? 'جاري الرفع...' : 'رفع المشروع',
              onPressed: _isUploading ? () {} : _submitProject,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الشروط:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _conditionItem(
            'تحميل المشروع كامل بصورة واضحة (يجب اختيار صورة رئيسية)',
          ),
          _conditionItem('الصورة تحوي على لقطات للمشروع (تحميل صور فرعية)'),
          _conditionItem('يكون المشروع تم تصميمه حديثاً وضمن الشروط المطلوبة'),
          _conditionItem('وضع عنوان للمشروع'),
          _conditionItem('وضع شرح للمشروع'),
          _conditionItem('رفع ملف اختياري لمخطط المشروع'),
          _conditionItem('تصنيف المشروع'),
        ],
      ),
    );
  }

  Widget _conditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الصورة الرئيسية للمشروع *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.placeholder2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _mainImage != null
                    ? AppColors.primary
                    : AppColors.border,
                width: _mainImage != null ? 2 : 1,
              ),
            ),
            child: _mainImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      _mainImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اختر صورة رئيسية',
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
  }

  Widget _buildSecondaryImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صور فرعية (لقطات المشروع) — حتى $_maxSecondaryImages *',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _maxSecondaryImages,
            itemBuilder: (context, index) {
              final hasImage = index < _secondaryImages.length;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => _pickSecondaryImage(index),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.placeholder1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: hasImage
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.file(
                                  _secondaryImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: GestureDetector(
                                  onTap: () => _removeSecondaryImage(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.error,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: AppColors.grey500,
                                size: 28,
                              ),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عنوان المشروع *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أدخل عنوان المشروع',
            hintStyle: TextStyle(color: AppColors.grey600),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'شرح المشروع *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          textDirection: TextDirection.rtl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'وصف المشروع وتفاصيله',
            hintStyle: TextStyle(color: AppColors.grey600),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تصنيف المشروع *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              hint: Text(
                'اختر التصنيف',
                style: TextStyle(color: AppColors.grey600),
              ),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, textDirection: TextDirection.rtl),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملف مخطط المشروع (اختياري)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickPlanFile,
          icon: const Icon(Icons.upload_file, size: 20),
          label: const Text('رفع ملف المخطط (PDF)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
