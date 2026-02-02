import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'models/comment_model.dart';
import 'models/friend_request_model.dart';
import 'models/notification_model.dart';
import 'models/user_profile_model.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/home_post_details_sheet.dart';

enum HomeTab { home, work, groups, profile, notifications, menu }

class HomeController extends GetxController {
  final Rx<HomeTab> currentTab = HomeTab.home.obs;
  final notificationCount = 3;

  // تفاعلات البوست الأول
  final post1Likes = 0.obs;
  final post1Comments = 0.obs;
  final post1IsLiked = false.obs;
  final post1CommentsList = <CommentModel>[].obs;

  // تفاعلات البوست الثاني
  final post2Likes = 0.obs;
  final post2Comments = 0.obs;
  final post2IsLiked = false.obs;
  final post2CommentsList = <CommentModel>[].obs;

  // طلبات الصداقة والأصدقاء (التاب الثالث)
  final friendRequests = <FriendRequestModel>[].obs;
  final myFriends = <FriendRequestModel>[].obs;
  final sentFriendRequestIds = <String>[].obs;

  // الملف الشخصي والاقتراحات (التاب الرابع)
  late final UserProfileModel myProfile;
  final suggestionUsers = <UserProfileModel>[].obs;

  // الإشعارات (التاب الخامس)
  final notifications = <NotificationModel>[].obs;

  bool hasSentFriendRequest(String userId) =>
      sentFriendRequestIds.contains(userId);
  bool isFriend(String userId) => myFriends.any((f) => f.id == userId);

  void sendFriendRequest(String userId) {
    if (!sentFriendRequestIds.contains(userId)) {
      sentFriendRequestIds.add(userId);
    }
  }

  List<CommentModel> getCommentsListForPost(int postId) {
    if (postId == 1) return post1CommentsList;
    return post2CommentsList;
  }

  void addComment(int postId, String text, [String? parentId]) {
    final list = getCommentsListForPost(postId);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final comment = CommentModel(
      id: id,
      authorName: 'المستخدم',
      text: text,
      parentId: parentId,
      createdAt: _formatTime(DateTime.now()),
    );
    list.add(comment);
    _updateCommentCount(postId);
  }

  void addAudioComment(
    int postId,
    String audioPath, [
    String? parentId,
    int? durationSeconds,
  ]) {
    final list = getCommentsListForPost(postId);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final comment = CommentModel(
      id: id,
      authorName: 'المستخدم',
      audioPath: audioPath,
      audioDurationSeconds: durationSeconds,
      parentId: parentId,
      createdAt: _formatTime(DateTime.now()),
    );
    list.add(comment);
    _updateCommentCount(postId);
  }

  void _updateCommentCount(int postId) {
    if (postId == 1) {
      post1Comments.value = _totalCount(post1CommentsList);
    } else {
      post2Comments.value = _totalCount(post2CommentsList);
    }
  }

  int _totalCount(List<CommentModel> list) {
    return list.length;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void togglePost1Like() {
    post1IsLiked.value = !post1IsLiked.value;
    post1Likes.value += post1IsLiked.value ? 1 : -1;
  }

  void addPost1Comment() {
    openCommentsSheet(1);
  }

  void togglePost2Like() {
    post2IsLiked.value = !post2IsLiked.value;
    post2Likes.value += post2IsLiked.value ? 1 : -1;
  }

  void addPost2Comment() {
    openCommentsSheet(2);
  }

  void acceptFriendRequest(String id) {
    final index = friendRequests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      final request = friendRequests.removeAt(index);
      myFriends.add(request);
    }
  }

  void rejectFriendRequest(String id) {
    friendRequests.removeWhere((r) => r.id == id);
  }

  void openCommentsSheet(int postId) {
    Get.bottomSheet(
      CommentsSheet(postId: postId),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      ignoreSafeArea: false,
    );
  }

  void openPost1DetailsSheet() {
    Get.bottomSheet(
      const HomePostDetailsSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      ignoreSafeArea: false,
    );
  }

  void selectTab(HomeTab tab) {
    currentTab.value = tab;
    // يمكن لاحقاً تبديل المحتوى أو التنقل حسب التاب
    switch (tab) {
      case HomeTab.menu:
        // فتح القائمة الجانبية أو نافذة
        break;
      default:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    myProfile = UserProfileModel(
      id: 'me',
      name: 'المستخدم',
      username: 'uid0526',
      job: 'مؤسس ومدير تنفيذي في شركة زيرو لقص الليزر',
      education: 'دراسة هندسة عمارة في جامعة دمشق',
      livesIn: 'سوريا',
      from: 'درعا، داعل',
    );
    _addSampleComments();
    _addSampleFriendRequests();
    _addSuggestionUsers();
    _addSampleNotifications();
  }

  void _addSampleNotifications() {
    notifications.addAll([
      NotificationModel(
        id: 'n1',
        type: NotificationType.interaction,
        senderName: 'سارة أحمد',
        message: 'تفاعلت مع منشورك. ما رأيك؟',
        timeAgo: 'منذ ساعتين',
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.comment,
        senderName: 'محمد علي',
        message: 'علق على منشورك: "تصميم رائع، أتمنى رؤية المزيد"',
        timeAgo: 'منذ 3 ساعات',
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.friendAcceptance,
        senderName: 'نورة سالم',
        message: 'وافقت على طلب صداقتك.',
        timeAgo: 'منذ 5 ساعات',
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.interaction,
        senderName: 'أحمد غنيم',
        message: 'أعجب بمنشورك في المشروع الأخير.',
        timeAgo: 'منذ 6 ساعات',
      ),
      NotificationModel(
        id: 'n5',
        type: NotificationType.comment,
        senderName: 'فاطمة حسن',
        message: 'ردت على تعليقك في منشور شركة زيرو.',
        timeAgo: 'منذ يوم',
      ),
      NotificationModel(
        id: 'n6',
        type: NotificationType.friendAcceptance,
        senderName: 'خالد العمري',
        message: 'وافقت على طلب صداقتك.',
        timeAgo: 'منذ يومين',
      ),
    ]);
  }

  void _addSuggestionUsers() {
    suggestionUsers.addAll([
      UserProfileModel(
        id: 'u1',
        name: 'أحمد غنيم',
        username: 'ahmed_ghanim',
        job: 'مهندس معماري',
        mutualCount: 15,
      ),
      UserProfileModel(
        id: 'u2',
        name: 'لينا محمد',
        username: 'lina_m',
        job: 'مصممة داخلية',
        mutualCount: 8,
      ),
      UserProfileModel(
        id: 'u3',
        name: 'عمر سعيد',
        username: 'omar_s',
        education: 'هندسة معمارية',
        mutualCount: 22,
      ),
    ]);
  }

  void _addSampleFriendRequests() {
    friendRequests.addAll([
      FriendRequestModel(
        id: 'fr1',
        name: 'سارة أحمد',
        mutualCount: 12,
        timeAgo: 'منذ 9 أسابيع',
      ),
      FriendRequestModel(
        id: 'fr2',
        name: 'محمد علي',
        mutualCount: 5,
        timeAgo: 'منذ 10 أسابيع',
      ),
      FriendRequestModel(
        id: 'fr3',
        name: 'نورة سالم',
        mutualCount: 20,
        timeAgo: 'منذ 12 أسبوعاً',
      ),
      FriendRequestModel(
        id: 'fr4',
        name: 'خالد العمري',
        mutualCount: 3,
        timeAgo: 'منذ 19 أسبوعاً',
      ),
      FriendRequestModel(
        id: 'fr5',
        name: 'فاطمة حسن',
        mutualCount: 8,
        timeAgo: 'منذ 20 أسبوعاً',
      ),
    ]);
  }

  void _addSampleComments() {
    final c1 = CommentModel(
      id: '1',
      authorName: 'عبد الحريري',
      text: 'هل استطيع ان اقوم بتعديل التصميم بعد شراءه؟',
      createdAt: 'منذ ساعتين',
    );
    final c2 = CommentModel(
      id: '2',
      authorName: 'احمد غنیم',
      text: 'نعم تستطيع',
      parentId: '1',
      createdAt: 'منذ ساعة',
    );
    final c3 = CommentModel(
      id: '3',
      authorName: 'عبد الحريري',
      text: 'شكراً على التوضيح',
      parentId: '2',
      createdAt: 'منذ ٤٥ دقيقة',
    );
    post1CommentsList.addAll([c1, c2, c3]);
    post1Comments.value = post1CommentsList.length;
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.createAccountIntro);
  }

  /// تسجيل الخروج مع تأكيد ثم التوجيه لشاشة تسجيل الدخول.
  void logout(BuildContext context) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.authLogin);
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
