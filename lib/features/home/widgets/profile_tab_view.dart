import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import 'countdown_timer.dart';
import 'edit_profile_page.dart';
import 'home_interaction_row.dart';
import 'shimmer_loading.dart';

/// شاشة التاب الرابع — الملف الشخصي الاحترافي (الملف الخاص بي).
class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isProfileLoading.value) {
        return const SingleChildScrollView(
          child: ShimmerProfile(),
        );
      }
      final p = controller.myProfile;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCoverWithProfile(p),
            const SizedBox(height: 60),
            _buildProfileHeader(p),
            const SizedBox(height: 16),
            _buildActionButtons(context, isOwnProfile: true),
            if (p.isProfileLocked) ...[
              const SizedBox(height: 16),
              _buildPrivacyBanner(context),
            ],
            const SizedBox(height: 16),
            _buildAboutSection(p),
            const SizedBox(height: 20),
            _buildTimelineHeader(context),
            const SizedBox(height: 12),
            _buildProfilePostsList(),
            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }

  /// الجزء العلوي: غلاف + صورة البروفايل العائمة
  Widget _buildCoverWithProfile(UserProfileModel p) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        /// الخلفية (Cover) من الـ API
        Container(
          height: 200,
          width: double.infinity,
          child: p.coverImage != null && p.coverImage!.isNotEmpty
              ? Image.network(
                  p.coverImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildCoverPlaceholder(),
                )
              : _buildCoverPlaceholder(),
        ),
        /// صورة البروفايل من الـ API
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
              child: p.profilePicture != null && p.profilePicture!.isNotEmpty
                  ? Image.network(
                      p.profilePicture!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarPlaceholder(),
                    )
                  : _buildAvatarPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPlaceholder() {
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
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.placeholder1,
      child: Icon(Icons.person, color: AppColors.grey400, size: 48),
    );
  }

  /// الاسم أسفل البروفايل (من الـ API فقط)
  Widget _buildProfileHeader(UserProfileModel p) {
    final displayName = (p.username != null && p.username!.isNotEmpty)
        ? p.username!
        : (p.name.isNotEmpty ? p.name : '');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            displayName.isNotEmpty ? displayName : '—',
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
          Expanded(
            child: _outlinedButton('تعديل الملف', Icons.edit_outlined, onTap: () {
              Get.to(() => EditProfilePage(controller: controller));
            }),
          ),
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

  Widget _outlinedButton(String label, IconData icon, {VoidCallback? onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap ?? () {},
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
                child: Text('edit_general_details'.tr),
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
            'posts'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          TextButton(onPressed: () {}, child: Text('show_all'.tr)),
        ],
      ),
    );
  }

  /// قائمة منشورات الملف الشخصي من الـ API
  Widget _buildProfilePostsList() {
    return Obx(() {
      if (controller.isProfilePostsLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(2, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShimmerPostCard(),
            )),
          ),
        );
      }
      final list = controller.profilePosts;
      if (list.isEmpty) {
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: list.map((post) => _profilePostCard(post)).toList(),
        ),
      );
    });
  }

  Widget _profilePostCard(PostModel post) {
    final imageUrl = post.imageUrl != null && post.imageUrl!.isNotEmpty
        ? HomeController.fullImageUrl(post.imageUrl)
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      (controller.myProfile.name.isNotEmpty
                              ? controller.myProfile.name[0]
                              : '؟')
                          .toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.myProfile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (post.createdAt != null)
                        Text(
                          post.createdAt!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (post.category != null)
                  Text(
                    post.category!,
                    style: TextStyle(fontSize: 13, color: AppColors.grey700),
                  ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.placeholder1,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.placeholder1,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.grey400,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
                if (post.description != null && post.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if ((post.budget != null && post.budget!.isNotEmpty) ||
                    (post.deadline != null && post.deadline!.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.budget != null && post.budget!.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('تكلفة المشروع', style: TextStyle(fontSize: 11, color: AppColors.grey600)),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(post.budget!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (post.deadline != null && post.deadline!.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('متبقي حتى انتهاء المشروع', style: TextStyle(fontSize: 11, color: AppColors.grey600)),
                              const SizedBox(height: 2),
                              CountdownTimer(deadline: post.deadline, iconSize: 18),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: HomeInteractionRow(
                        likesCount: post.likesCount,
                        commentsCount: post.commentsCount,
                        isLikedValue: post.isLiked,
                        onLike: () async {
                          await controller.togglePostLike(post.id);
                          controller.loadMyProfilePosts();
                        },
                        onComment: () =>
                            controller.openCommentsSheet(post.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ArchiButton(
                        label: 'رفع المشروع ',
                        height: 44,
                        fontSize: 14,
                        onPressed: controller.openUploadPage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
