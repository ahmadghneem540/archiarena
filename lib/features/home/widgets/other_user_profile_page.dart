import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';
import '../models/user_profile_model.dart';

/// صفحة ملف مستخدم آخر — مع زر طلب صداقة أو موافقة/رفض إن كان طلباً وارداً.
class OtherUserProfilePage extends StatelessWidget {
  const OtherUserProfilePage({
    super.key,
    required this.controller,
    required this.user,
    this.fromRequest = false,
  });

  final HomeController controller;
  final UserProfileModel user;

  /// إن كان الدخول من قائمة طلبات الصداقة نعرض موافقة/رفض بدل طلب صداقة.
  final bool fromRequest;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Get.back(),
          ),
          title: Text(
            user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCover(),
              const SizedBox(height: 8),
              _buildProfileHeader(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final sent = controller.sentFriendRequestIds.contains(
                    user.id,
                  );
                  final isFriend = controller.myFriends.any(
                    (f) => f.id == user.id,
                  );
                  return _buildFriendButton(
                    context,
                    sent: sent,
                    isFriend: isFriend,
                  );
                }),
              ),
              const SizedBox(height: 16),
              _buildAboutSection(),
              const SizedBox(height: 20),
              _buildTimelineHeader(),
              const SizedBox(height: 12),
              _buildTimelinePlaceholder(),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
    );
  }

  Widget _buildProfileHeader() {
    final initial = user.name.isNotEmpty ? user.name[0] : '؟';
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
            user.username ?? user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          if (user.mutualCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              user.mutualCount == 1
                  ? 'صديق واحد مشترك'
                  : '${user.mutualCount} أصدقاء مشتركين',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendButton(
    BuildContext context, {
    required bool sent,
    required bool isFriend,
  }) {
    if (fromRequest) {
      return Row(
        children: [
          Expanded(
            child: ArchiButton(
              label: 'موافقة',
              height: 48,
              fontSize: 16,
              onPressed: () {
                controller.acceptFriendRequest(user.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت الموافقة. أصبح صديقاً.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
                Get.back();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                controller.rejectFriendRequest(user.id);
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey700,
                side: BorderSide(color: AppColors.grey400),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('رفض'),
            ),
          ),
        ],
      );
    }

    if (isFriend) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'صديق',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    if (sent) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, color: AppColors.grey600, size: 20),
              SizedBox(width: 8),
              Text(
                'تم إرسال طلب الصداقة',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ArchiButton(
      label: 'طلب صداقة',
      height: 48,
      fontSize: 16,
      icon: Icons.person_add_alt_1,
      iconSize: 20,
      onPressed: () {
        controller.sendFriendRequest(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلب الصداقة. في انتظار الموافقة.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
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
            if (user.job != null) _aboutRow(Icons.work_outline, user.job!),
            if (user.education != null)
              _aboutRow(Icons.school_outlined, user.education!),
            if (user.livesIn != null)
              _aboutRow(Icons.home_outlined, user.livesIn!),
            if (user.from != null)
              _aboutRow(Icons.location_on_outlined, user.from!),
            if (user.job == null &&
                user.education == null &&
                user.livesIn == null &&
                user.from == null) ...[
              Text(
                'لا توجد معلومات عامة',
                style: TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'معلومات عامة',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

  Widget _buildTimelineHeader() {
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
            'لا توجد منشورات',
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
          ),
        ),
      ),
    );
  }
}
