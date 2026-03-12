import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/api/api_response.dart';
import '../../core/constant/const_data.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/friends_api_service.dart';
import '../../data/services/home_api_service.dart';
import '../../data/services/notifications_api_service.dart';
import '../../data/services/profile_api_service.dart';
import 'models/comment_model.dart';
import 'models/friend_request_model.dart';
import 'models/notification_model.dart';
import 'models/order_model.dart';
import 'models/post_model.dart';
import 'models/project_image_model.dart';
import 'models/user_profile_model.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/home_post_details_sheet.dart';
import 'widgets/order_details_view.dart';

enum HomeTab { home, work, orders, groups, profile, notifications, menu }

class HomeController extends GetxController {
  final Rx<HomeTab> currentTab = HomeTab.home.obs;
  final showUploadPage = false.obs;
  // نوع المستخدم: true للشركات، false للأشخاص
  final RxBool isCompany = false.obs; // يمكن تغييرها حسب نوع المستخدم المسجل

  void openUploadPage() {
    showUploadPage.value = true;
  }

  void closeUploadPage() {
    showUploadPage.value = false;
  }

  final notificationCount = 0.obs;
  /// عدد طلبات الصداقة المعلقة — للشارة الحمراء على أيقونة الأصدقاء
  final friendRequestCount = 0.obs;

  // شروط رفع المشروع من الـ API
  final uploadConditions = <String>[].obs;

  // المنشورات من الـ API
  final posts = <PostModel>[].obs;
  /// منشورات تم نقلها إلى الأعمال بعد تحميل المخطط
  final transferredPostIds = <int>[].obs;

  /// منشورات الصفحة الرئيسية (لم تُنقل بعد)
  List<PostModel> get mainFeedPosts =>
      posts.where((p) => !transferredPostIds.contains(p.id)).toList();

  /// منشورات تبويب الأعمال (بعد تحميل المخطط ونقلها)
  List<PostModel> get worksPosts =>
      posts.where((p) => transferredPostIds.contains(p.id)).toList();

  void markPostAsTransferred(int postId) {
    if (!transferredPostIds.contains(postId)) {
      transferredPostIds.add(postId);
    }
  }
  final isPostsLoading = false.obs;
  final isProfileLoading = false.obs;
  final isProfilePostsLoading = false.obs;
  final isFriendRequestsLoading = false.obs;
  final isSuggestionsLoading = false.obs;
  final isNotificationsLoading = false.obs;
  final isOtherUserLoading = false.obs;

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

  /// تعليقات المنشورات من الـ API (مفتاح: postId)
  final Map<int, RxList<CommentModel>> postCommentsMap = {};

  // طلبات الصداقة والأصدقاء (التاب الثالث)
  final friendRequests = <FriendRequestModel>[].obs;
  final myFriends = <FriendRequestModel>[].obs;
  final sentFriendRequestIds = <String>[].obs;

  // الملف الشخصي والاقتراحات (التاب الرابع) — تُملأ من الـ API فقط
  final isProfileLocked = false.obs;
  UserProfileModel myProfile = UserProfileModel(
    id: 'me',
    name: '',
    username: '',
    job: '',
    education: '',
    livesIn: '',
    from: '',
  );
  /// منشورات الملف الشخصي (من /profile/me/posts)
  final profilePosts = <PostModel>[].obs;
  /// ملف مستخدم آخر (عند فتح صفحة ملفه)
  final Rxn<UserProfileModel> otherUserProfile = Rxn<UserProfileModel>();
  /// منشورات مستخدم آخر
  final otherUserPosts = <PostModel>[].obs;
  final suggestionUsers = <UserProfileModel>[].obs;

  /// نتائج بحث المستخدمين
  final searchResults = <UserProfileModel>[].obs;
  final isSearchLoading = false.obs;

  // الإشعارات (التاب الخامس)
  final notifications = <NotificationModel>[].obs;

  // الطلبات/المشاريع المرفوعة (للشركات)
  final orders = <OrderModel>[].obs;
  
  // صور المشاريع (مفتاح: orderId)
  final Map<String, RxList<ProjectImageModel>> orderImages = {};

  bool hasSentFriendRequest(String userId) =>
      sentFriendRequestIds.contains(userId);
  bool isFriend(String userId) => myFriends.any((f) => f.id == userId);

  Future<void> sendFriendRequest(String userId) async {
    if (sentFriendRequestIds.contains(userId)) return;
    final id = int.tryParse(userId);
    if (id == null) return;
    final res = await FriendsApiService.sendRequest(id);
    if (res.isSuccess) {
      sentFriendRequestIds.add(userId);
    } else {
      Get.snackbar('فشل', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
    }
  }

  RxList<CommentModel> getCommentsListForPost(int postId) {
    if (postId == 1) return post1CommentsList;
    if (postId == 2) return post2CommentsList;
    postCommentsMap[postId] ??= <CommentModel>[].obs;
    return postCommentsMap[postId]!;
  }

  /// جلب التعليقات من الـ API وحفظها للمنشور
  Future<void> loadPostComments(int postId) async {
    final res = await HomeApiService.getComments(postId);
    final list = getCommentsListForPost(postId);
    if (res.isSuccess && res.data != null) {
      final rawList = res.data!['comments'] ?? res.data!['data'];
      if (rawList is List && rawList.isNotEmpty) {
        final topLevel = rawList
            .map((e) => e is Map
                ? CommentModel.fromJson(
                    Map.from(e),
                    formatTime: _formatTimeAgo,
                  )
                : null)
            .whereType<CommentModel>()
            .toList();
        final flat = <CommentModel>[];
        for (final c in topLevel) {
          flat.add(c);
          flat.addAll(c.replies);
        }
        list.assignAll(flat);
      } else {
        list.assignAll(<CommentModel>[]);
      }
    }
    _updateCommentCount(postId);
  }

  /// إضافة تعليق نصي أو رد — يستدعي الـ API ثم يضيف النتيجة للقائمة
  Future<bool> addComment(int postId, String text, [String? parentId]) async {
    final list = getCommentsListForPost(postId);
    ApiResponse<Map<String, dynamic>> res;
    if (parentId == null || parentId.isEmpty) {
      res = await HomeApiService.addComment(postId, body: text);
    } else {
      final commentId = int.tryParse(parentId);
      if (commentId == null) {
        Get.snackbar('خطأ', 'معرف التعليق غير صالح', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      res = await HomeApiService.replyComment(commentId, body: text);
    }
    if (!res.isSuccess) {
      Get.snackbar('فشل إرسال التعليق', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final comment = _parseCommentFromResponse(res.data);
    if (comment != null) {
      list.add(comment);
      _updateCommentCount(postId);
      return true;
    }
    return true;
  }

  /// إضافة تعليق صوتي أو رد صوتي — يستدعي الـ API مع الملف الصوتي
  Future<bool> addAudioComment(
    int postId,
    String audioPath, [
    String? parentId,
    int? durationSeconds,
  ]) async {
    final list = getCommentsListForPost(postId);
    ApiResponse<Map<String, dynamic>> res;
    if (parentId == null || parentId.isEmpty) {
      res = await HomeApiService.addComment(postId, audioPath: audioPath);
    } else {
      final commentId = int.tryParse(parentId);
      if (commentId == null) {
        Get.snackbar('خطأ', 'معرف التعليق غير صالح', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      res = await HomeApiService.replyComment(commentId, audioPath: audioPath);
    }
    if (!res.isSuccess) {
      Get.snackbar('فشل إرسال التعليق الصوتي', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final comment = _parseCommentFromResponse(res.data, audioDurationSeconds: durationSeconds);
    if (comment != null) {
      list.add(comment);
      _updateCommentCount(postId);
      return true;
    }
    return true;
  }

  CommentModel? _parseCommentFromResponse(Map<String, dynamic>? data, {int? audioDurationSeconds}) {
    if (data == null) return null;
    final raw = data['comment'] ?? data['data'] ?? data;
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final comment = CommentModel.fromJson(map, formatTime: _formatTimeAgo);
    if (audioDurationSeconds != null && comment.audioPath != null) {
      return comment.copyWith(audioDurationSeconds: audioDurationSeconds);
    }
    return comment;
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

  Future<void> togglePostLike(int postId) async {
    final res = await HomeApiService.toggleLike(postId);
    if (res.isSuccess) {
      loadPosts();
    }
  }

  Future<void> acceptFriendRequest(String id) async {
    final requestId = int.tryParse(id);
    if (requestId != null) {
      final res = await FriendsApiService.confirmRequest(requestId);
      if (res.isSuccess) {
        final index = friendRequests.indexWhere((r) => r.id == id);
        if (index >= 0) {
          final request = friendRequests.removeAt(index);
          myFriends.add(request);
        }
      } else {
        Get.snackbar('فشل', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> rejectFriendRequest(String id) async {
    final requestId = int.tryParse(id);
    if (requestId != null) {
      final res = await FriendsApiService.deleteRequest(requestId);
      if (res.isSuccess) {
        friendRequests.removeWhere((r) => r.id == id);
      }
    } else {
      friendRequests.removeWhere((r) => r.id == id);
    }
  }

  void openCommentsSheet(int postId) {
    loadPostComments(postId);
    Get.bottomSheet(
      CommentsSheet(postId: postId),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      ignoreSafeArea: false,
    );
  }

  /// جلب تفاصيل منشور كاملة (تفاصيل التصميم، المخططات، الصور) — GET /home/posts/:id
  Future<PostModel?> loadPostDetails(int postId) async {
    final res = await HomeApiService.getPost(postId);
    if (!res.isSuccess || res.data == null) return null;
    return PostModel.fromJson(res.data!);
  }

  void openPostDetailsSheet(PostModel post) {
    Get.bottomSheet(
      HomePostDetailsSheet(controller: this, post: post),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      ignoreSafeArea: false,
    );
  }

  void openPost1DetailsSheet() {
    openPostDetailsSheet(posts.isNotEmpty ? posts.first : PostModel(id: 0, title: ''));
  }

  void openOrderDetails(String orderId, String orderTitle) {
    Get.to(() => OrderDetailsView(
          controller: this,
          orderId: orderId,
          orderTitle: orderTitle,
        ));
  }

  RxList<ProjectImageModel> getOrderImages(String orderId) {
    if (!orderImages.containsKey(orderId)) {
      orderImages[orderId] = _generateSampleImages(orderId).obs;
    }
    return orderImages[orderId]!;
  }

  void acceptImage(String orderId, String imageId) {
    final images = orderImages[orderId];
    if (images == null) return;

    // رفض جميع الصور الأخرى وقبول الصورة المختارة
    for (var image in images) {
      if (image.id == imageId) {
        image.isAccepted.value = true;
        image.isRejected.value = false;
      } else {
        image.isAccepted.value = false;
        image.isRejected.value = true;
      }
    }
  }

  void downloadAllImages(String orderId) {
    final images = orderImages[orderId];
    if (images == null || images.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد صور للتحميل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // هنا يمكن إضافة منطق التحميل الفعلي
    Get.snackbar(
      'نجح',
      'تم تحميل ${images.length} صورة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: AppColors.onPrimary,
    );
  }

  List<ProjectImageModel> _generateSampleImages(String orderId) {
    final imageAssets = [
      'assets/order1.jfif',
      'assets/order2.jfif',
      'assets/order3.jfif',
      'assets/order4.jfif',
      'assets/order5.jfif',
      'assets/order6.jfif',
    ];
    
    final authors = ['م كوم', 'م احمد', 'شركة الخلف', 'معلا', 'خالد', 'engAbd'];
    
    return List.generate(6, (index) {
      return ProjectImageModel(
        id: 'img_${orderId}_$index',
        imageUrl: imageAssets[index % imageAssets.length],
        authorName: authors[index % authors.length],
        timeAgo: 'منذ ساعتين',
        isAccepted: false,
        isRejected: false,
      );
    });
  }

  void selectTab(HomeTab tab) {
    currentTab.value = tab;
    switch (tab) {
      case HomeTab.home:
      case HomeTab.work:
        loadPosts();
        break;
      case HomeTab.groups:
        loadFriendRequests();
        loadMyFriends();
        break;
      case HomeTab.profile:
        loadMyProfile();
        loadMyProfilePosts();
        break;
      case HomeTab.notifications:
        loadNotifications();
        break;
      case HomeTab.menu:
        break;
      default:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments['isCompany'] == true) {
        isCompany.value = true;
      } else if (arguments['isCompany'] == false) {
        isCompany.value = false;
      } else {
        _loadIsCompanyFromStorage();
      }
    } else {
      _loadIsCompanyFromStorage();
    }

    loadMyProfile();
    loadMyProfilePosts();
    _addSampleComments();
    loadUploadConditions();
    loadPosts();
    loadFriendRequests();
    loadMyFriends();
    loadNotifications();
    _addSampleOrders();
  }

  Future<void> _loadIsCompanyFromStorage() async {
    final saved = await MyServices.getStringValue(ConstData.keyIsCompany);
    if (saved == '1') isCompany.value = true;
  }

  /// جلب شروط رفع المشروع
  Future<void> loadUploadConditions() async {
    final res = await HomeApiService.getUploadConditions();
    if (res.isSuccess && res.data != null) {
      final conditions = res.data!['conditions'];
      if (conditions is List) {
        uploadConditions.value =
            conditions.map((e) => e.toString()).toList();
      }
    }
  }

  /// جلب المنشورات من الـ API
  Future<void> loadPosts() async {
    isPostsLoading.value = true;
    try {
      final res = await HomeApiService.getPosts();
      if (res.isSuccess && res.data != null) {
      final list = res.data!['posts'] ?? res.data!['data'];
      if (list is List && list.isNotEmpty) {
        posts.value = list
            .map((e) => e is Map ? PostModel.fromJson(Map.from(e)) : null)
            .whereType<PostModel>()
            .toList();
      } else {
        posts.value = [];
      }
    } else {
      posts.value = [];
    }
    } finally {
      isPostsLoading.value = false;
    }
  }

  /// آخر عدد طلبات معروف — لمعرفة وجود طلبات جديدة وإشعار المستخدم.
  int _lastFriendRequestCount = -1;

  /// جلب طلبات الصداقة — الطلب يظهر عند المستخدم المستقبل، ويمكنه فتح بروفايل المرسل والموافقة أو الرفض.
  Future<void> loadFriendRequests() async {
    isFriendRequestsLoading.value = true;
    try {
      final res = await FriendsApiService.getRequests();
    if (res.isSuccess && res.data != null) {
      final list = res.data!['requests'] ?? res.data!['data'];
      if (list is List && list.isNotEmpty) {
        friendRequests.value = list.map((e) {
          final m = e is Map ? Map.from(e) : {};
          final sender = m['sender'] is Map ? Map.from(m['sender']) : {};
          final profilePic = sender['profile_picture']?.toString();
          final requestId = m['request_id'] ?? m['id'];
          final senderUserId = sender['user_id'] ?? sender['id'];
          return FriendRequestModel(
            id: '${requestId ?? senderUserId}',
            senderUserId: senderUserId?.toString(),
            name: sender['name']?.toString() ?? 'مستخدم',
            mutualCount: m['mutual_friends_count'] ?? 0,
            timeAgo: _formatTimeAgo(m['created_at']),
            avatarPath: profilePic != null && profilePic.isNotEmpty
                ? HomeController.fullImageUrl(profilePic)
                : null,
          );
        }).toList();
      } else {
        friendRequests.value = [];
      }
    } else {
      friendRequests.value = [];
    }
    final countRes = await FriendsApiService.getRequestsCount();
    if (countRes.isSuccess && countRes.data != null) {
      friendRequestCount.value =
          countRes.data!['count'] ?? friendRequests.length;
    }
    // إشعار المستخدم عند وصول طلب صداقة جديد (مع صوت/اهتزاز إن أمكن)
    final newCount = friendRequests.length;
    if (_lastFriendRequestCount >= 0 && newCount > _lastFriendRequestCount) {
      _onNewFriendRequestReceived();
    }
    _lastFriendRequestCount = newCount;
    } finally {
      isFriendRequestsLoading.value = false;
    }
  }

  void _onNewFriendRequestReceived() {
    Get.snackbar(
      'طلب صداقة جديد',
      'لديك طلب صداقة جديد. افتح تبويب الأصدقاء للموافقة أو الرفض.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
    HapticFeedback.heavyImpact();
    _playNewRequestSound();
  }

  void _playNewRequestSound() {
    try {
      // لتفعيل رن الجوال: أضف ملف assets/sounds/notification.mp3
      // ثم استخدم: AudioPlayer().play(AssetSource('sounds/notification.mp3'));
      // أو اعتمد على Push (FCM) من السيرفر مع sound: "default" — انظر docs/API_FRIEND_REQUESTS_AND_NOTIFICATIONS.md
    } catch (_) {}
  }

  final isMyFriendsLoading = false.obs;

  /// جلب قائمة الأصدقاء
  Future<void> loadMyFriends() async {
    isMyFriendsLoading.value = true;
    try {
      final res = await FriendsApiService.getFriends();
      if (res.isSuccess && res.data != null) {
        final list = res.data!['friends'] ?? res.data!['data'];
        if (list is List && list.isNotEmpty) {
          myFriends.value = list.map((e) {
            final m = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
            final user = m['user'] is Map
                ? Map<String, dynamic>.from(m['user'] as Map)
                : m['friend'] is Map
                    ? Map<String, dynamic>.from(m['friend'] as Map)
                    : m;
            final friendId = user['user_id'] ?? user['id'] ?? m['friend_id'] ?? m['user_id'];
            final profilePic = user['profile_picture']?.toString() ?? m['profile_picture']?.toString();
            return FriendRequestModel(
              id: friendId?.toString() ?? '',
              senderUserId: friendId?.toString(),
              name: user['name']?.toString() ?? m['name']?.toString() ?? 'مستخدم',
              mutualCount: int.tryParse('${m['mutual_friends_count'] ?? user['mutual_friends_count'] ?? 0}') ?? 0,
              timeAgo: _formatTimeAgo(m['created_at']),
              avatarPath: profilePic != null && profilePic.isNotEmpty
                  ? HomeController.fullImageUrl(profilePic)
                  : null,
            );
          }).toList();
        } else {
          myFriends.value = [];
        }
      } else {
        myFriends.value = [];
      }
    } catch (_) {
      myFriends.value = [];
    } finally {
      isMyFriendsLoading.value = false;
    }
  }

  /// جلب اقتراحات الأصدقاء
  Future<void> loadFriendSuggestions() async {
    isSuggestionsLoading.value = true;
    try {
      final res = await FriendsApiService.getSuggestions();
    if (res.isSuccess && res.data != null) {
      final list = res.data!['suggestions'] ?? res.data!['data'];
      if (list is List && list.isNotEmpty) {
        suggestionUsers.value = list.map((e) {
          final m = e is Map ? Map.from(e) : {};
          final profilePic = m['profile_picture']?.toString();
          return UserProfileModel(
            id: '${m['user_id'] ?? m['id']}',
            name: m['name']?.toString() ?? 'مستخدم',
            username: m['username']?.toString(),
            job: m['professional_title']?.toString() ?? m['job']?.toString(),
            mutualCount: m['mutual_friends_count'] ?? 0,
            profilePicture: profilePic != null && profilePic.isNotEmpty
                ? fullImageUrl(profilePic)
                : null,
          );
        }).toList();
      } else {
        suggestionUsers.value = [];
      }
    } else {
      suggestionUsers.value = [];
    }
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

  /// جلب الإشعارات
  Future<void> loadNotifications() async {
    isNotificationsLoading.value = true;
    try {
      final res = await NotificationsApiService.getNotifications();
    if (res.isSuccess && res.data != null) {
      final list = res.data!['notifications'] ?? res.data!['data'];
      if (list is List && list.isNotEmpty) {
        notifications.value = list.map((e) {
          final m = e is Map ? Map.from(e) : {};
          final sender = m['sender'] is Map ? Map.from(m['sender']) : {};
          return NotificationModel(
            id: '${m['notification_id'] ?? m['id']}',
            type: _parseNotificationType(m['type']),
            senderName: sender['name']?.toString() ?? 'مستخدم',
            message: m['message']?.toString() ?? '',
            timeAgo: _formatTimeAgo(m['created_at']),
          );
        }).toList();
      }
    }
    final countRes = await NotificationsApiService.getUnreadCount();
    if (countRes.isSuccess && countRes.data != null) {
      notificationCount.value =
          countRes.data!['count'] ?? notifications.length;
    }
    } finally {
      isNotificationsLoading.value = false;
    }
  }

  NotificationType _parseNotificationType(dynamic t) {
    if (t == null) return NotificationType.interaction;
    final s = t.toString().toLowerCase();
    if (s.contains('comment')) return NotificationType.comment;
    if (s.contains('friend')) return NotificationType.friendAcceptance;
    return NotificationType.interaction;
  }

  String _formatTimeAgo(dynamic dt) {
    if (dt == null) return '';
    if (dt is String) {
      try {
        final d = DateTime.tryParse(dt);
        if (d != null) return _timeAgo(d);
      } catch (_) {}
    }
    return dt.toString();
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  /// بناء رابط صورة كامل من مسار الـ API
  static String? fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = ConstData.API_BASE;
    return base.endsWith('/') ? '$base${path.startsWith('/') ? path.substring(1) : path}' : '$base${path.startsWith('/') ? path : '/$path'}';
  }

  /// جلب الملف الشخصي من الـ API
  Future<void> loadMyProfile() async {
    isProfileLoading.value = true;
    try {
      final res = await ProfileApiService.getMyProfile();
    if (res.isSuccess && res.data != null) {
      final d = res.data!;
      myProfile = UserProfileModel(
        id: '${d['user_id'] ?? d['id'] ?? 'me'}',
        name: d['name']?.toString() ?? myProfile.name,
        username: d['username']?.toString(),
        job: d['professional_title'] ?? d['job']?.toString(),
        education: d['education']?.toString(),
        livesIn: d['current_location'] ?? d['lives_in']?.toString(),
        from: d['origin_location'] ?? d['from']?.toString(),
        profilePicture: fullImageUrl(d['profile_picture']?.toString()),
        coverImage: fullImageUrl(d['cover_image']?.toString()),
        bio: d['bio']?.toString(),
        company: d['company']?.toString(),
        postsCount: (d['posts_count'] is int)
            ? d['posts_count'] as int
            : int.tryParse('${d['posts_count']}') ?? 0,
        isProfileLocked: d['is_profile_locked'] == true,
        isOwn: d['is_own'] == true,
      );
      isProfileLocked.value = myProfile.isProfileLocked;
      final profileIsCompany = d['is_company'] == true ||
          d['role']?.toString().toLowerCase() == 'company' ||
          d['user_type']?.toString().toLowerCase() == 'company' ||
          d['type']?.toString().toLowerCase() == 'company';
      final profileIsPersonal = d['is_company'] == false ||
          d['role']?.toString().toLowerCase() == 'customer' ||
          d['user_type']?.toString().toLowerCase() == 'customer' ||
          d['user_type']?.toString().toLowerCase() == 'personal' ||
          d['type']?.toString().toLowerCase() == 'customer' ||
          d['type']?.toString().toLowerCase() == 'personal';
      if (profileIsCompany) {
        isCompany.value = true;
        MyServices.saveStringValue(ConstData.keyIsCompany, '1');
      } else if (profileIsPersonal) {
        isCompany.value = false;
        MyServices.saveStringValue(ConstData.keyIsCompany, '0');
      }
      update();
    }
    } finally {
      isProfileLoading.value = false;
    }
  }

  /// جلب منشورات الملف الشخصي من الـ API
  Future<void> loadMyProfilePosts() async {
    isProfilePostsLoading.value = true;
    try {
      final res = await ProfileApiService.getMyPosts();
    if (res.isSuccess && res.data != null) {
      final list = res.data!['posts'];
      if (list is List && list.isNotEmpty) {
        profilePosts.value = list
            .map((e) => e is Map ? PostModel.fromJson(Map.from(e)) : null)
            .whereType<PostModel>()
            .toList();
      } else {
        profilePosts.value = [];
      }
    } else {
      profilePosts.value = [];
    }
    } finally {
      isProfilePostsLoading.value = false;
    }
  }

  /// جلب ملف مستخدم آخر من الـ API
  Future<void> loadOtherUserProfile(String userId) async {
    final id = int.tryParse(userId);
    if (id == null) return;
    isOtherUserLoading.value = true;
    try {
      final res = await ProfileApiService.getUserProfile(id);
    if (res.isSuccess && res.data != null) {
      final d = res.data!;
      otherUserProfile.value = UserProfileModel(
        id: '${d['user_id'] ?? d['id'] ?? userId}',
        name: d['name']?.toString() ?? 'مستخدم',
        username: d['username']?.toString(),
        job: d['professional_title'] ?? d['job']?.toString(),
        education: d['education']?.toString(),
        livesIn: d['current_location'] ?? d['lives_in']?.toString(),
        from: d['origin_location'] ?? d['from']?.toString(),
        profilePicture: fullImageUrl(d['profile_picture']?.toString()),
        coverImage: fullImageUrl(d['cover_image']?.toString()),
        bio: d['bio']?.toString(),
        company: d['company']?.toString(),
        postsCount: (d['posts_count'] is int)
            ? d['posts_count'] as int
            : int.tryParse('${d['posts_count']}') ?? 0,
        isProfileLocked: d['is_profile_locked'] == true,
        isOwn: d['is_own'] == true,
      );
    } else {
      otherUserProfile.value = null;
    }
    } finally {
      isOtherUserLoading.value = false;
    }
  }

  /// جلب منشورات مستخدم آخر
  Future<void> loadOtherUserPosts(String userId) async {
    final id = int.tryParse(userId);
    if (id == null) return;
    final res = await ProfileApiService.getUserPosts(id);
    if (res.isSuccess && res.data != null) {
      final list = res.data!['posts'];
      if (list is List && list.isNotEmpty) {
        otherUserPosts.value = list
            .map((e) => e is Map ? PostModel.fromJson(Map.from(e)) : null)
            .whereType<PostModel>()
            .toList();
      } else {
        otherUserPosts.value = [];
      }
    } else {
      otherUserPosts.value = [];
    }
  }

  /// مسح بيانات المستخدم الآخر عند الخروج من صفحته
  void clearOtherUserProfile() {
    otherUserProfile.value = null;
    otherUserPosts.clear();
  }

  /// تحديث الملف الشخصي (البيانات النصية) — PUT /profile/me
  Future<bool> updateMyProfile({
    String? name,
    String? username,
    String? bio,
    String? professionalTitle,
    String? company,
    String? education,
    String? currentLocation,
    String? originLocation,
    bool? isProfileLocked,
  }) async {
    final res = await ProfileApiService.updateProfile(
      name: name,
      username: username,
      bio: bio,
      professionalTitle: professionalTitle,
      company: company,
      education: education,
      currentLocation: currentLocation,
      originLocation: originLocation,
      isProfileLocked: isProfileLocked,
    );
    if (!res.isSuccess) {
      Get.snackbar('فشل التحديث', res.message ?? 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    await loadMyProfile();
    return true;
  }

  /// بحث المستخدمين — GET /search/users?q=...
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    isSearchLoading.value = true;
    try {
      final res = await ProfileApiService.searchUsers(query.trim());
      if (res.isSuccess && res.data != null) {
        final list = res.data!['users'] ?? res.data!['data'];
        if (list is List && list.isNotEmpty) {
          searchResults.value = list.map((e) {
            final m = e is Map ? Map.from(e) : {};
            final profilePic = m['profile_picture']?.toString();
            return UserProfileModel(
              id: '${m['user_id'] ?? m['id']}',
              name: m['name']?.toString() ?? 'مستخدم',
              username: m['username']?.toString(),
              job: m['professional_title']?.toString() ?? m['job']?.toString(),
              mutualCount: m['mutual_friends_count'] ?? 0,
              profilePicture: profilePic != null && profilePic.isNotEmpty
                  ? fullImageUrl(profilePic)
                  : null,
            );
          }).toList();
        } else {
          searchResults.value = [];
        }
      } else {
        searchResults.value = [];
      }
    } finally {
      isSearchLoading.value = false;
    }
  }

  void clearSearchResults() {
    searchResults.clear();
  }

  void _addSampleOrders() {
    orders.addAll([
      OrderModel(
        id: 'o1',
        title: 'مكتب هندسي',
        timeAgo: 'منذ ساعتين',
        imageUrl: 'assets/order1.jfif',
      ),
      OrderModel(
        id: 'o2',
        title: 'تصميم أعمدة سكنية داخلية',
        timeAgo: 'منذ 20 د',
        imageUrl: 'assets/order2.jfif',
      ),
      OrderModel(
        id: 'o3',
        title: 'فيلا سكنية حديثة',
        timeAgo: 'منذ 3 ساعات',
        imageUrl: 'assets/order3.jfif',
      ),
      OrderModel(
        id: 'o4',
        title: 'مبنى تجاري متعدد الطوابق',
        timeAgo: 'منذ 5 ساعات',
        imageUrl: 'assets/order4.jfif',
      ),
      OrderModel(
        id: 'o5',
        title: 'تصميم مطعم راقي',
        timeAgo: 'منذ يوم',
        imageUrl: 'assets/order5.jfif',
      ),
      OrderModel(
        id: 'o6',
        title: 'شقة سكنية بمساحة 120 م²',
        timeAgo: 'منذ يومين',
        imageUrl: 'assets/order6.jfif',
      ),
      OrderModel(
        id: 'o7',
        title: 'مستشفى خاص',
        timeAgo: 'منذ 3 أيام',
        imageUrl: 'assets/order7.jfif',
      ),
      OrderModel(
        id: 'o8',
        title: 'مدرسة ابتدائية',
        timeAgo: 'منذ أسبوع',
        imageUrl: 'assets/order8.jfif',
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

  void logout(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    Get.dialog(
      Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirm'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
            TextButton(
              onPressed: () async {
                Get.back();
                await AuthApiService.logout();
                Get.offAllNamed(AppRoutes.authLogin);
                Get.delete<HomeController>(force: true);
              },
              child: Text('logout'.tr),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
