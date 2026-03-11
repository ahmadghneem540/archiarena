import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/profile_api_service.dart';
import '../home_controller.dart';

/// شاشة تعديل الملف الشخصي — PUT /profile/me ورفع صورة البروفايل/الغلاف.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.controller});

  final HomeController controller;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _jobController;
  late TextEditingController _companyController;
  late TextEditingController _educationController;
  late TextEditingController _livesInController;
  late TextEditingController _fromController;

  bool _isProfileLocked = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.controller.myProfile;
    _nameController = TextEditingController(text: p.name);
    _usernameController = TextEditingController(text: p.username ?? '');
    _bioController = TextEditingController(text: p.bio ?? '');
    _jobController = TextEditingController(text: p.job ?? '');
    _companyController = TextEditingController(text: p.company ?? '');
    _educationController = TextEditingController(text: p.education ?? '');
    _livesInController = TextEditingController(text: p.livesIn ?? '');
    _fromController = TextEditingController(text: p.from ?? '');
    _isProfileLocked = p.isProfileLocked;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    _livesInController.dispose();
    _fromController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    final ok = await widget.controller.updateMyProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      professionalTitle: _jobController.text.trim().isEmpty ? null : _jobController.text.trim(),
      company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
      education: _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
      currentLocation: _livesInController.text.trim().isEmpty ? null : _livesInController.text.trim(),
      originLocation: _fromController.text.trim().isEmpty ? null : _fromController.text.trim(),
      isProfileLocked: _isProfileLocked,
    );
    setState(() => _isSaving = false);
    if (ok && mounted) Get.back();
  }

  Future<void> _pickAndUpdateProfilePicture() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null || !mounted) return;
    final file = File(x.path);
    final res = await ProfileApiService.updateProfilePicture(file);
    if (res.isSuccess && mounted) {
      await widget.controller.loadMyProfile();
      Get.snackbar('تم', 'تم تحديث صورة البروفايل', snackPosition: SnackPosition.BOTTOM);
    } else if (mounted) {
      Get.snackbar('فشل', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _pickAndUpdateCover() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null || !mounted) return;
    final file = File(x.path);
    final res = await ProfileApiService.updateCoverImage(file);
    if (res.isSuccess && mounted) {
      await widget.controller.loadMyProfile();
      Get.snackbar('تم', 'تم تحديث صورة الغلاف', snackPosition: SnackPosition.BOTTOM);
    } else if (mounted) {
      Get.snackbar('فشل', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.controller.myProfile;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle('الصور'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _imageButton(
                      label: 'صورة البروفايل',
                      imageUrl: p.profilePicture,
                      onTap: _pickAndUpdateProfilePicture,
                    ),
                    const SizedBox(width: 16),
                    _imageButton(
                      label: 'صورة الغلاف',
                      imageUrl: p.coverImage,
                      onTap: _pickAndUpdateCover,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle('البيانات الأساسية'),
                const SizedBox(height: 8),
                _textField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _usernameController,
                  label: 'اسم المستخدم',
                  hint: '@username',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _bioController,
                  label: 'نبذة عنك',
                  hint: 'اكتب نبذة قصيرة',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _sectionTitle('المهنة والعمل'),
                const SizedBox(height: 8),
                _textField(
                  controller: _jobController,
                  label: 'المسمى الوظيفي',
                  hint: 'مثال: مهندس معماري',
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _companyController,
                  label: 'الشركة',
                  hint: 'اسم الشركة',
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _educationController,
                  label: 'المؤهل الدراسي',
                  hint: 'مثال: بكالوريوس هندسة معمارية',
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 24),
                _sectionTitle('الموقع'),
                const SizedBox(height: 8),
                _textField(
                  controller: _livesInController,
                  label: 'مكان الإقامة',
                  hint: 'المدينة أو الدولة',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: _fromController,
                  label: 'مكان المنشأ',
                  hint: 'المدينة أو الدولة',
                  icon: Icons.place_outlined,
                ),
                const SizedBox(height: 24),
                _sectionTitle('الخصوصية'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 22, color: AppColors.grey600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'قفل الملف الشخصي',
                          style: TextStyle(fontSize: 15, color: AppColors.onSurface),
                        ),
                      ),
                      Switch(
                        value: _isProfileLocked,
                        onChanged: (v) => setState(() => _isProfileLocked = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _imageButton({
    required String label,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.add_photo_alternate, color: AppColors.grey500, size: 40),
                  ),
                )
              else
                Icon(Icons.add_photo_alternate, color: AppColors.grey500, size: 40),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 22, color: AppColors.grey600),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
