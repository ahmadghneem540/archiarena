import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
              _buildCoverWithProfile(),
              const SizedBox(height: 60), // لتعويض مساحة صورة البروفايل
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
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

  /// الجزء العلوي: غلاف + صورة البروفايل العائمة
  Widget _buildCoverWithProfile() {
    final initial = user.name.isNotEmpty ? user.name[0] : '؟';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        /// الخلفية (Cover)
        Container(
          height: 200,
          width: double.infinity,
          child: Image.asset(
            'assets/post5.jfif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
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
                child: Center(
                  child: Icon(
                    Icons.architecture,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 64,
                  ),
                ),
              );
            },
          ),
        ),

        /// صورة البروفايل مربعة بحواف مدوّرة وتطفو على الغلاف
        Positioned(
          bottom: -48,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: AppColors.primary.withValues(alpha: 0.2),
                child: Center(
                  child: Text(
                    initial.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// الاسم أسفل البروفايل
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
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

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final sent = controller.sentFriendRequestIds.contains(user.id);
        final isFriend = controller.myFriends.any((f) => f.id == user.id);
        // التحقق إذا كان المستخدم أرسل طلب صداقة لي
        final hasReceivedRequest = controller.friendRequests.any(
          (r) => r.id == user.id,
        );

        // إذا كان المستخدم أرسل طلب صداقة لي (من طلبات الصداقة الواردة)
        if (fromRequest || hasReceivedRequest) {
          return Row(
            children: [
              Expanded(
                child: _gradientButton('موافقة', Icons.check, () {
                  controller.acceptFriendRequest(user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت الموافقة. أصبح صديقاً.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Get.back();
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _outlinedButton('رفض', Icons.close, () {
                  controller.rejectFriendRequest(user.id);
                  Get.back();
                }),
              ),
            ],
          );
        }

        if (isFriend) {
          return Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.grey600, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'صديق',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (sent) {
          return Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(10),
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
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // زر طلب الصداقة بنفس تصميم الأزرار في البروفايل الشخصي
        return _gradientButton('طلب صداقة', Icons.person_add_alt_1, () {
          controller.sendFriendRequest(user.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال طلب الصداقة. في انتظار الموافقة.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
            ),
          );
        });
      }),
    );
  }

  Widget _gradientButton(String label, IconData icon, VoidCallback onPressed) {
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
          onTap: onPressed,
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

  Widget _outlinedButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.grey700,
        side: BorderSide(color: AppColors.grey400),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 44),
      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0] : '؟',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username ?? user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'منذ ساعتين',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'تصميم داخلي',
                      style: TextStyle(fontSize: 13, color: AppColors.grey700),
                    ),
                  ],
                ),
              ),
              Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.placeholder1,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/post3.jfif',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.placeholder1,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.grey400,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.username ?? user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مكتب هندسي مساحة تقريبية 80-120 م، تقسم إلى منطقة استقبال وعرض بمساحة 15 م لعرض المشاريع واستقبال العملاء، منطقة عمل مفتوحة للفريق بمساحة 35-45 م',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
