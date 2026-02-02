import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../models/user_profile_model.dart';

/// شاشة التاب الرابع — الملف الشخصي الاحترافي (الملف الخاص بي).
class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.myProfile;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCover(),
          const SizedBox(height: 8),
          _buildProfileHeader(p),
          const SizedBox(height: 16),
          _buildActionButtons(context, isOwnProfile: true),
          const SizedBox(height: 16),
          _buildPrivacyBanner(context),
          const SizedBox(height: 16),
          _buildAboutSection(p),
          const SizedBox(height: 20),
          _buildTimelineHeader(context),
          const SizedBox(height: 12),
          _buildTimelinePlaceholder(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.6),
            AppColors.primaryDark.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.onPrimary.withValues(alpha: 0.9),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel p) {
    final initial = p.name.isNotEmpty ? p.name[0] : '؟';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              initial.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 36,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p.username ?? p.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required bool isOwnProfile,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _gradientButton('إضافة لقصة', Icons.add_circle_outline),
          ),
          const SizedBox(width: 12),
          Expanded(child: _outlinedButton('تعديل الملف', Icons.edit_outlined)),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.more_horiz, color: AppColors.grey600),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _gradientButton(String label, IconData icon) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlinedButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.grey700,
        side: BorderSide(color: AppColors.grey400),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildPrivacyBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.grey600, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ملفك الشخصي مقفل',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'اعرف المزيد',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(UserProfileModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.job != null) _aboutRow(Icons.work_outline, p.job!),
            if (p.education != null)
              _aboutRow(Icons.school_outlined, p.education!),
            if (p.livesIn != null) _aboutRow(Icons.home_outlined, p.livesIn!),
            if (p.from != null) _aboutRow(Icons.location_on_outlined, p.from!),
            const SizedBox(height: 12),
            Text(
              'عرض معلوماتك العامة',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey700,
                  side: BorderSide(color: AppColors.grey400),
                ),
                child: const Text('تعديل التفاصيل العامة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.grey600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'المنشورات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('عرض الكل')),
        ],
      ),
    );
  }

  Widget _buildTimelinePlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'لا توجد منشورات بعد',
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
          ),
        ),
      ),
    );
  }
}
