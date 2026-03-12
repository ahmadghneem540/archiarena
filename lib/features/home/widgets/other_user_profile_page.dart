import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../models/friend_request_model.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import 'countdown_timer.dart';
import 'shimmer_loading.dart';

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
            onPressed: () {
              controller.clearOtherUserProfile();
              Get.back();
            },
          ),
          title: Obx(
            () => Text(
              controller.otherUserProfile.value?.name ?? user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isOtherUserLoading.value) {
            return const SingleChildScrollView(
              child: ShimmerProfile(),
            );
          }
          final p = controller.otherUserProfile.value ?? user;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCoverWithProfile(p),
                const SizedBox(height: 60),
                _buildProfileHeader(p),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                if (p.isProfileLocked) ...[
                  const SizedBox(height: 16),
                  _buildPrivacyBanner(),
                ],
                const SizedBox(height: 16),
                _buildAboutSection(p),
                const SizedBox(height: 20),
                _buildTimelineHeader(),
                const SizedBox(height: 12),
                _buildPostsList(),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCoverWithProfile(UserProfileModel p) {
    final initial = p.name.isNotEmpty ? p.name[0] : '؟';
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          child: p.coverImage != null && p.coverImage!.isNotEmpty
              ? Image.network(
                  p.coverImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _coverPlaceholder(),
                )
              : _coverPlaceholder(),
        ),
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
                      errorBuilder: (_, __, ___) => _avatarPlaceholder(initial),
                    )
                  : _avatarPlaceholder(initial),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() {
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

  Widget _avatarPlaceholder(String initial) {
    return Container(
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
    );
  }

  Widget _buildProfileHeader(UserProfileModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            p.username ?? p.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          if (p.mutualCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              p.mutualCount == 1
                  ? 'صديق واحد مشترك'
                  : '${p.mutualCount} أصدقاء مشتركين',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacyBanner() {
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
                'الملف الشخصي مقفل',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final sent = controller.sentFriendRequestIds.contains(user.id);
        final isFriend = controller.myFriends.any((f) => f.id == user.id);
        // التحقق إذا كان المستخدم أرسل طلب صداقة لي (نطابق المرسل بـ senderUserId أو id)
        FriendRequestModel? incomingRequest;
        for (final r in controller.friendRequests) {
          if (r.senderUserId == user.id || r.id == user.id) {
            incomingRequest = r;
            break;
          }
        }
        final hasReceivedRequest = incomingRequest != null;

        // إذا كان المستخدم أرسل طلب صداقة لي (من طلبات الصداقة الواردة) ونملك request_id للموافقة/الرفض
        if ((fromRequest || hasReceivedRequest) && incomingRequest != null) {
          final requestId = incomingRequest.id;
          return Row(
            children: [
              Expanded(
                child: _gradientButton('accept'.tr, Icons.check, () {
                  controller.acceptFriendRequest(requestId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('friend_request_accepted'.tr),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Get.back();
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _outlinedButton('reject'.tr, Icons.close, () {
                  controller.rejectFriendRequest(requestId);
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
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.grey600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'already_friends'.tr,
                    style: const TextStyle(
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
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, color: AppColors.grey600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'friend_request_sent_pending'.tr,
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
        return _gradientButton('send_friend_request'.tr, Icons.person_add_alt_1, () {
          controller.sendFriendRequest(user.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('friend_request_sent'.tr),
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
            if (p.job == null &&
                p.education == null &&
                p.livesIn == null &&
                p.from == null) ...[
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
        children: [
          Text(
            'المنشورات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    final list = controller.otherUserPosts;
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
              'لا توجد منشورات',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ),
        ),
      );
    }
    final p = controller.otherUserProfile.value ?? user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: list.map((post) => _postCard(post, p.name)).toList(),
      ),
    );
  }

  Widget _postCard(PostModel post, String authorName) {
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
                      (authorName.isNotEmpty ? authorName[0] : '؟')
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
                        authorName,
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
                  errorBuilder: (_, __, ___) => Container(
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
                if (post.description != null &&
                    post.description!.isNotEmpty) ...[
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
                    (post.deadline != null && post.deadline!.isNotEmpty) ||
                    (post.projectTimer != null && post.projectTimer!.isNotEmpty)) ...[
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
                              Text('project_cost'.tr, style: TextStyle(fontSize: 11, color: AppColors.grey600)),
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
                              Text('project_deadline_remaining'.tr, style: TextStyle(fontSize: 11, color: AppColors.grey600)),
                              const SizedBox(height: 2),
                              CountdownTimer(deadline: post.deadline, iconSize: 18),
                            ],
                          ),
                        ),
                      if (post.projectTimer != null && post.projectTimer!.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('deal_timer'.tr, style: TextStyle(fontSize: 11, color: AppColors.grey600)),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(post.projectTimer!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 22,
                      color: post.isLiked
                          ? AppColors.primary
                          : AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(fontSize: 15, color: AppColors.grey700),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.comment_outlined,
                      size: 22,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(fontSize: 15, color: AppColors.grey700),
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
