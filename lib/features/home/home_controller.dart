import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/api/api_response.dart';
import '../../core/constant/const_data.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/download_helper.dart';
import '../../core/services/chat_socket_service.dart';
import '../../core/services/fcm_service.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/friends_api_service.dart';
import '../../data/services/home_api_service.dart';
import '../../data/services/notifications_api_service.dart';
import '../../data/services/chat_api_service.dart';
import '../../data/services/profile_api_service.dart';
import '../chat/chat_inbox_view.dart';
import '../chat/models/chat_thread_model.dart';
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
import 'widgets/upload_project.dart';

enum HomeTab { home, work, orders, groups, profile, notifications, menu }

class HomeController extends GetxController {
  final Rx<HomeTab> currentTab = HomeTab.home.obs;
  final showUploadPage = false.obs;
  // نوع المستخدم: true للشركات، false للأشخاص
  final RxBool isCompany = false.obs; // يمكن تغييرها حسب نوع المستخدم المسجل
  // المنشورات من الـ API
  final posts = <PostModel>[].obs;

  /// منشورات الصفحة الرئيسية (آخر الأخبار)
  List<PostModel> get mainFeedPosts => posts;

  /// منشورات تبويب الأعمال — من GET /home/works
  final worksPosts = <PostModel>[].obs;
  final isWorksLoading = false.obs;

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
  final notificationCount = 0.obs;

  /// عدد طلبات الصداقة المعلقة — للشارة الحمراء على أيقونة الأصدقاء
  final friendRequestCount = 0.obs;

  /// عدد طلبات المراسلة المعلقة — للشارة في القائمة (الرسائل)
  final chatPendingRequestCount = 0.obs;

  /// مجموع الرسائل غير المقروءة عبر المحادثات — للشارة على أيقونة الرسائل في الرأس
  final chatUnreadMessageCount = 0.obs;
  // شروط رفع المشروع من الـ API
  final uploadConditions = <String>[].obs;

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
  final isOrdersLoading = false.obs;
  // العروض على طلب معين (مفتاح: orderId)
  final Map<String, RxList<ProjectImageModel>> orderImages = {};
  final isOrderProposalsLoading = false.obs;
  final isDownloadingOrders = false.obs;
  final isDownloadingOrderImages = false.obs;
  // ====== خفّة الأداء: منع إعادة التحميل المتكرر ======
  DateTime? _postsFetchedAt;
  DateTime? _worksFetchedAt;
  DateTime? _ordersFetchedAt;
  DateTime? _friendsFetchedAt;
  DateTime? _friendRequestsFetchedAt;
  DateTime? _notificationsFetchedAt;
  DateTime? _profilePostsFetchedAt;
  DateTime? _profileFetchedAt;

  static const Duration _defaultCacheTtl = Duration(seconds: 45);

  /// فتح صفحة رفع المشروع. إن وُجد post (من صفحة الأعمال) يُفتح نموذج تقديم عرض على ذلك المشروع.
  void openUploadPage({PostModel? post}) {
    if (post != null) {
      UploadProjectPage.showProposalSheet(post, this);
      return;
    }
    showUploadPage.value = true;
  }

  void closeUploadPage() {
    showUploadPage.value = false;
  }

  bool _isFresh(DateTime? t, [Duration ttl = _defaultCacheTtl]) {
    if (t == null) return false;
    return DateTime.now().difference(t) < ttl;
  }

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
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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
            .map(
              (e) => e is Map
                  ? CommentModel.fromJson(
                      Map.from(e),
                      formatTime: _formatTimeAgo,
                    )
                  : null,
            )
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
        Get.snackbar(
          'error'.tr,
          'invalid_comment_id'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      res = await HomeApiService.replyComment(commentId, body: text);
    }
    if (!res.isSuccess) {
      Get.snackbar(
        'comment_add_failed'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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

  /// إضافة تعليق بصورة أو رد بصورة — يستدعي الـ API مع ملف الصورة
  Future<bool> addImageComment(
    int postId,
    String imagePath, [
    String? parentId,
  ]) async {
    final list = getCommentsListForPost(postId);
    ApiResponse<Map<String, dynamic>> res;
    final imageFile = File(imagePath);
    if (parentId == null || parentId.isEmpty) {
      res = await HomeApiService.addComment(postId, image: imageFile);
    } else {
      final commentId = int.tryParse(parentId);
      if (commentId == null) {
        Get.snackbar(
          'error'.tr,
          'invalid_comment_id'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      res = await HomeApiService.replyComment(commentId, image: imageFile);
    }
    if (!res.isSuccess) {
      Get.snackbar(
        'comment_add_failed'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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
        Get.snackbar(
          'error'.tr,
          'invalid_comment_id'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      res = await HomeApiService.replyComment(commentId, audioPath: audioPath);
    }
    if (!res.isSuccess) {
      Get.snackbar(
        'comment_voice_failed'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    final comment = _parseCommentFromResponse(
      res.data,
      audioDurationSeconds: durationSeconds,
    );
    if (comment != null) {
      list.add(comment);
      _updateCommentCount(postId);
      return true;
    }
    return true;
  }

  CommentModel? _parseCommentFromResponse(
    Map<String, dynamic>? data, {
    int? audioDurationSeconds,
  }) {
    if (data == null) return null;
    // استخراج الخريطة الفعلية للتعليق من الاستجابة المتداخلة
    var raw = data['comment'] ?? data['data'] ?? data;
    if (raw is Map && (raw.containsKey('comment') || raw.containsKey('data'))) {
      raw = raw['comment'] ?? raw['data'] ?? raw;
    }

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
      return;
    }
    if (postId == 2) {
      post2Comments.value = _totalCount(post2CommentsList);
      return;
    }
    final count = _totalCount(getCommentsListForPost(postId));
    _applyCommentCountToPostLists(postId, count);
  }

  void _applyCommentCountToPostLists(int postId, int commentsCount) {
    void patch(RxList<PostModel> list) {
      final i = list.indexWhere((p) => p.id == postId);
      if (i < 0) return;
      list[i] = list[i].copyWith(commentsCount: commentsCount);
    }

    patch(posts);
    patch(otherUserPosts);
    patch(profilePosts);
    patch(worksPosts);
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

  Future<void> togglePostLike(
    int postId, {
    String? refreshPostsForUserId,
  }) async {
    final res = await HomeApiService.toggleLike(postId);
    if (res.isSuccess) {
      loadPosts();
      if (refreshPostsForUserId != null) {
        await loadOtherUserPosts(refreshPostsForUserId);
      }
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
        Get.snackbar(
          'failure'.tr,
          res.message ?? 'error_occurred'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
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

  /// تحميل ملفات المخطط: PDF أو صور (JPG/…) حسب امتداد الرابط؛ ثم فتح أول ملف.
  /// يُفضَّل `plan_file` من الـ API ثم المرفقات PDF ثم عناصر `plans`/`blueprints`.
  Future<List<String>> downloadPostPlans(PostModel post) async {
    final paths = <String>[];
    Future<void> addPdf(String? rawUrl, String basePathNoExt) async {
      final resolved = fullImageUrl(rawUrl) ?? rawUrl;
      if (resolved == null || resolved.isEmpty) return;
      final path = await DownloadHelper.downloadPdfFile(resolved, basePathNoExt);
      if (path != null) paths.add(path);
    }

    Future<void> addPlanByUrl(String? rawUrl, String basePathNoExt) async {
      final resolved = fullImageUrl(rawUrl) ?? rawUrl;
      if (resolved == null || resolved.isEmpty) return;
      final String path;
      if (isLikelyPdfUrl(resolved)) {
        final p = await DownloadHelper.downloadPdfFile(resolved, basePathNoExt);
        if (p == null) return;
        path = p;
      } else {
        final p = await DownloadHelper.downloadImage(resolved, basePathNoExt);
        if (p == null) return;
        path = p;
      }
      paths.add(path);
    }

    if (post.planFileUrl != null && post.planFileUrl!.trim().isNotEmpty) {
      await addPlanByUrl(post.planFileUrl, 'plans/${post.id}/plan_file');
    }
    for (var i = 0; i < post.attachments.length; i++) {
      final a = post.attachments[i];
      if (a.isPdfAttachment) {
        await addPdf(a.url, 'plans/${post.id}/attachment_$i');
      }
    }
    for (var i = 0; i < post.plans.length; i++) {
      final p = post.plans[i];
      await addPlanByUrl(p.url, 'plans/${post.id}/plan_$i');
    }
    for (var i = 0; i < post.blueprints.length; i++) {
      final p = post.blueprints[i];
      await addPlanByUrl(p.url, 'plans/${post.id}/blueprint_$i');
    }
    return paths;
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
    openPostDetailsSheet(
      posts.isNotEmpty ? posts.first : PostModel(id: 0, title: ''),
    );
  }

  void openOrderDetails(String orderId, String orderTitle) {
    if (!orderImages.containsKey(orderId)) {
      orderImages[orderId] = <ProjectImageModel>[].obs;
    }
    Get.to(
      () => OrderDetailsView(
        controller: this,
        orderId: orderId,
        orderTitle: orderTitle,
      ),
    );
    loadOrderProposals(orderId);
  }

  RxList<ProjectImageModel> getOrderImages(String orderId) {
    if (!orderImages.containsKey(orderId)) {
      orderImages[orderId] = <ProjectImageModel>[].obs;
    }
    return orderImages[orderId]!;
  }

  /// جلب العروض على طلب من الـ API — GET /home/orders/:orderId/proposals
  /// الباكند يُرجع 403 إذا المستخدم ليس صاحب الطلب
  Future<void> loadOrderProposals(String orderId) async {
    final oid = int.tryParse(orderId);
    if (oid == null) return;
    isOrderProposalsLoading.value = true;
    try {
      final res = await HomeApiService.getOrderProposals(oid);
      if (res.status == 403) {
        Get.snackbar(
          'alert'.tr,
          res.message ?? 'orders_company_only'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      final list = <ProjectImageModel>[];
      if (res.isSuccess && res.data != null) {
        final rawList = res.data!['proposals'] ?? res.data!['data'];
        if (rawList is List && rawList.isNotEmpty) {
          for (final e in rawList) {
            if (e is! Map) continue;
            final m = Map<String, dynamic>.from(e);
            final id = '${m['proposal_id'] ?? m['id']}';
            final status = (m['status']?.toString() ?? '').toLowerCase();
            final imageUrl =
                fullImageUrl(
                  m['image_url']?.toString() ?? m['imageUrl']?.toString(),
                ) ??
                '';
            list.add(
              ProjectImageModel(
                id: id,
                imageUrl: imageUrl,
                authorName: m['name']?.toString() ?? '—',
                timeAgo: _formatTimeAgo(m['created_at']),
                isAccepted: status == 'accepted',
                isRejected: status == 'rejected',
              ),
            );
          }
        }
      }
      if (orderImages.containsKey(orderId)) {
        orderImages[orderId]!.assignAll(list);
      }
    } finally {
      isOrderProposalsLoading.value = false;
    }
  }

  /// قبول عرض (ورفض الباقي) — POST /home/orders/:orderId/proposals/:proposalId/accept
  Future<void> acceptImage(String orderId, String imageId) async {
    final oid = int.tryParse(orderId);
    final pid = int.tryParse(imageId);
    if (oid == null || pid == null) return;
    final res = await HomeApiService.acceptProposal(oid, pid);
    if (res.isSuccess) {
      await loadOrderProposals(orderId);
      Get.snackbar(
        'success'.tr,
        res.message ?? 'accept_offer_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// تحميل كل صور العروض الخاصة بطلب واحد محلياً
  Future<void> downloadAllImages(String orderId) async {
    final images = orderImages[orderId];
    if (images == null || images.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'no_images_to_download'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isDownloadingOrderImages.value = true;
    try {
      int count = 0;
      for (var i = 0; i < images.length; i++) {
        final img = images[i];
        if (img.imageUrl.isEmpty) continue;
        final path = await DownloadHelper.downloadImage(
          img.imageUrl,
          'orders/$orderId/proposal_$i',
        );
        if (path != null) count++;
      }
      if (count > 0) {
        Get.snackbar(
          'success'.tr,
          'downloaded_images'.trParams({'count': count.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.onPrimary,
        );
      } else {
        Get.snackbar(
          'alert'.tr,
          'no_images_downloaded'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isDownloadingOrderImages.value = false;
    }
  }

  /// تحميل كل الطلبات وصورها الرئيسية محلياً
  Future<void> downloadAllOrdersAndImages() async {
    if (orders.isEmpty) {
      Get.snackbar(
        'alert'.tr,
        'no_orders_to_download'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isDownloadingOrders.value = true;
    try {
      int count = 0;
      for (final order in orders) {
        final url = order.imageUrl;
        if (url == null || url.isEmpty) continue;
        final path = await DownloadHelper.downloadImage(
          url,
          'orders/${order.id}/main',
        );
        if (path != null) count++;
      }
      if (count > 0) {
        Get.snackbar(
          'success'.tr,
          'downloaded_orders'.trParams({'count': count.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.onPrimary,
        );
      } else {
        Get.snackbar(
          'alert'.tr,
          'no_images_downloaded'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isDownloadingOrders.value = false;
    }
  }

  void selectTab(HomeTab tab) {
    currentTab.value = tab;
    switch (tab) {
      case HomeTab.home:
        loadPosts();
        loadChatUnreadMessageCount();
        break;
      case HomeTab.work:
        loadWorks();
        break;
      case HomeTab.orders:
        if (isCompany.value) loadOrders();
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
        loadChatPendingRequestCount();
        loadChatUnreadMessageCount();
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
      if (arguments['openOrdersTab'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          selectTab(HomeTab.orders);
          final oid = arguments['orderId']?.toString();
          if (oid != null && oid.isNotEmpty) {
            openOrderDetails(
              oid,
              arguments['orderTitle']?.toString() ?? 'order'.tr,
            );
          }
        });
      }
      if (arguments['openChatAfterLoad'] == true) {
        final pid = arguments['openChatPeerId']?.toString();
        if (pid != null && pid.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            openChatWithUser(
              peerId: pid,
              peerName: arguments['openChatPeerName']?.toString() ?? '',
              peerAvatar: arguments['openChatPeerAvatar']?.toString(),
            );
          });
        }
      }
      if (arguments['openChatRequestsAfterLoad'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openChatInbox(openRequestsTab: true);
        });
      }
    } else {
      _loadIsCompanyFromStorage();
    }

    loadMyProfile();
    _addSampleComments();
    loadPosts();
    // باقي البيانات (الأعمال/الطلبات/الأصدقاء/الإشعارات/منشورات البروفايل) تُحمّل عند فتح تبويبها فقط عبر selectTab()
    _registerFcmTokenLater();
    _loadChatPendingCountLater();
    FcmService.addChatDataListener(_onFcmChatDataForHome);
  }

  void _onFcmChatDataForHome(Map<String, dynamic> data) {
    if (isClosed) return;
    final type = data['type']?.toString() ?? '';
    if (type == 'chat_request' ||
        type == 'new_chat_request' ||
        type == 'chat_message_request') {
      loadChatPendingRequestCount();
    }
    if (type == 'chat_message' || type == 'new_chat_message') {
      loadChatUnreadMessageCount();
    }
  }

  @override
  void onClose() {
    FcmService.removeChatDataListener(_onFcmChatDataForHome);
    super.onClose();
  }

  void _loadChatPendingCountLater() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (isClosed) return;
        loadChatPendingRequestCount();
        loadChatUnreadMessageCount();
      });
    });
  }

  /// تحديث عدد طلبات المراسلة الواردة (للشارة في القائمة)
  Future<void> loadChatPendingRequestCount() async {
    final prev = chatPendingRequestCount.value;
    try {
      final countRes = await ChatApiService.getIncomingRequestsCount();
      if (countRes.isSuccess &&
          countRes.data != null &&
          countRes.status != 404) {
        final raw = countRes.data!['count'] ??
            countRes.data!['pending_count'] ??
            countRes.data!['total'];
        final n = raw is int ? raw : int.tryParse('$raw');
        if (n != null) {
          _maybeShowChatRequestSnackbar(prev, n);
          chatPendingRequestCount.value = n;
          return;
        }
      }
      final listRes = await ChatApiService.getIncomingRequests(limit: 100);
      if (listRes.isSuccess && listRes.data != null) {
        final list = listRes.data!['requests'] ?? listRes.data!['list'];
        final n = list is List ? list.length : 0;
        _maybeShowChatRequestSnackbar(prev, n);
        chatPendingRequestCount.value = n;
      }
    } catch (_) {}
  }

  /// تحديث مجموع الرسائل غير المقروءة (من قائمة المحادثات)
  Future<void> loadChatUnreadMessageCount() async {
    try {
      var total = 0;
      var page = 1;
      const limit = 50;
      while (page <= 40) {
        final res = await ChatApiService.getConversations(page: page, limit: limit);
        if (!res.isSuccess || res.data == null) break;
        final list = res.data!['conversations'] ?? res.data!['list'];
        if (list is! List || list.isEmpty) break;
        for (final e in list) {
          if (e is! Map) continue;
          final t = ChatThreadModel.fromJson(Map<String, dynamic>.from(e));
          if (t != null) total += t.unreadCount;
        }
        final lastPage = res.data!['last_page'];
        final current = res.data!['current_page'];
        if (lastPage is int && current is int && current >= lastPage) break;
        if (list.length < limit) break;
        page++;
      }
      chatUnreadMessageCount.value = total;
    } catch (_) {}
  }

  void _maybeShowChatRequestSnackbar(int prev, int n) {
    if (isClosed || n <= 0 || n <= prev) return;
    Get.snackbar(
      'chat_request_snackbar_title'.tr,
      'chat_request_snackbar_body'.tr,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 6),
      mainButton: TextButton(
        onPressed: () => openChatInbox(openRequestsTab: true),
        child: Text('chat_open_requests'.tr),
      ),
    );
  }

  /// تحديث توكن FCM على السيرفر عند فتح التطبيق (مستخدمون وشركات) لاستقبال إشعار قبول العرض أو العرض الجديد
  Future<void> _registerFcmTokenIfAvailable() async {
    try {
      final token = await FcmService.getToken();
      if (token != null && token.isNotEmpty) {
        await NotificationsApiService.registerFcmToken(token);
      }
    } catch (_) {}
  }

  void _registerFcmTokenLater() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (isClosed) return;
        _registerFcmTokenIfAvailable();
      });
    });
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
        uploadConditions.value = conditions.map((e) => e.toString()).toList();
      }
    }
  }

  /// جلب المنشورات من الـ API
  Future<void> loadPosts({bool force = false}) async {
    if (!force && posts.isNotEmpty && _isFresh(_postsFetchedAt)) return;
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
      _postsFetchedAt = DateTime.now();
    } finally {
      isPostsLoading.value = false;
    }
  }

  /// جلب أعمال المستخدم من GET /home/works
  Future<void> loadWorks({bool force = false}) async {
    if (!force && worksPosts.isNotEmpty && _isFresh(_worksFetchedAt)) return;
    isWorksLoading.value = true;
    try {
      final res = await HomeApiService.getWorks(page: 1, limit: 20);
      if (res.isSuccess && res.data != null) {
        final list = res.data!['data'] ?? res.data!['posts'];
        if (list is List && list.isNotEmpty) {
          worksPosts.value = list
              .map((e) => e is Map ? PostModel.fromJson(Map.from(e)) : null)
              .whereType<PostModel>()
              .toList();
        } else {
          worksPosts.value = [];
        }
      } else {
        worksPosts.value = [];
      }
    } finally {
      isWorksLoading.value = false;
    }
    _worksFetchedAt = DateTime.now();
  }

  /// إضافة منشور إلى الأعمال — POST /home/works ثم تحديث القائمة
  Future<bool> addPostToWorks(int postId) async {
    final res = await HomeApiService.addPostToWorks(postId);
    if (res.isSuccess) {
      await loadWorks(force: true);
      return true;
    }
    return false;
  }

  /// هل المنشور موجود في قائمة الأعمال المحمّلة (GET /home/works).
  bool isPostInWorks(int postId) =>
      worksPosts.any((p) => p.id == postId);

  /// حذف منشور من الأعمال — DELETE /home/works/:postId
  Future<bool> removePostFromWorks(int postId) async {
    final res = await HomeApiService.deletePostFromWorks(postId);
    if (res.isSuccess) {
      await loadWorks(force: true);
      return true;
    }
    return false;
  }

  /// آخر عدد طلبات معروف — لمعرفة وجود طلبات جديدة وإشعار المستخدم.
  int _lastFriendRequestCount = -1;

  /// جلب طلبات الصداقة — الطلب يظهر عند المستخدم المستقبل، ويمكنه فتح بروفايل المرسل والموافقة أو الرفض.
  Future<void> loadFriendRequests({bool force = false}) async {
    if (!force &&
        friendRequests.isNotEmpty &&
        _isFresh(_friendRequestsFetchedAt)) {
      return;
    }
    isFriendRequestsLoading.value = true;
    try {
      final res = await FriendsApiService.getRequests();
      if (res.isSuccess && res.data != null) {
        final list = res.data!['requests'] ?? res.data!['data'];
        if (list is List && list.isNotEmpty) {
          friendRequests.value = list.map((e) {
            final m = e is Map ? Map.from(e) : {};
            final sender = m['sender'] is Map ? Map.from(m['sender']) : {};
            final profilePic = sender['profile_picture']?.toString() ??
                sender['avatar_url']?.toString() ??
                sender['avatarUrl']?.toString() ??
                sender['image_url']?.toString() ??
                sender['imageUrl']?.toString();
            final requestId = m['request_id'] ?? m['id'];
            final senderUserId = sender['user_id'] ?? sender['id'];
            return FriendRequestModel(
              id: '${requestId ?? senderUserId}',
              senderUserId: senderUserId?.toString(),
              name: sender['name']?.toString() ?? 'user_default'.tr,
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
    _friendRequestsFetchedAt = DateTime.now();
  }

  void _onNewFriendRequestReceived() {
    Get.snackbar(
      'new_friend_request'.tr,
      'new_friend_request_body'.tr,
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
  Future<void> loadMyFriends({bool force = false}) async {
    if (!force && myFriends.isNotEmpty && _isFresh(_friendsFetchedAt)) return;
    isMyFriendsLoading.value = true;
    try {
      final res = await FriendsApiService.getFriends();
      if (res.isSuccess && res.data != null) {
        final list = res.data!['friends'] ?? res.data!['data'];
        if (list is List && list.isNotEmpty) {
          myFriends.value = list.map((e) {
            final m = e is Map
                ? Map<String, dynamic>.from(e)
                : <String, dynamic>{};
            final user = m['user'] is Map
                ? Map<String, dynamic>.from(m['user'] as Map)
                : m['friend'] is Map
                ? Map<String, dynamic>.from(m['friend'] as Map)
                : m;
            final friendId =
                user['user_id'] ?? user['id'] ?? m['friend_id'] ?? m['user_id'];
            final profilePic =
                user['profile_picture']?.toString() ??
                user['avatar_url']?.toString() ??
                user['avatarUrl']?.toString() ??
                user['image_url']?.toString() ??
                user['imageUrl']?.toString() ??
                m['profile_picture']?.toString() ??
                m['avatar_url']?.toString() ??
                m['avatarUrl']?.toString() ??
                m['image_url']?.toString() ??
                m['imageUrl']?.toString();
            return FriendRequestModel(
              id: friendId?.toString() ?? '',
              senderUserId: friendId?.toString(),
              name:
                  user['name']?.toString() ??
                  m['name']?.toString() ??
                  'user_default'.tr,
              mutualCount:
                  int.tryParse(
                    '${m['mutual_friends_count'] ?? user['mutual_friends_count'] ?? 0}',
                  ) ??
                  0,
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
    _friendsFetchedAt = DateTime.now();
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
            final profilePic = m['profile_picture']?.toString() ??
                m['avatar_url']?.toString() ??
                m['avatarUrl']?.toString() ??
                m['image_url']?.toString() ??
                m['imageUrl']?.toString();
            return UserProfileModel(
              id: '${m['user_id'] ?? m['id']}',
              name: m['name']?.toString() ?? 'user_default'.tr,
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
  Future<void> loadNotifications({bool force = false}) async {
    if (!force && notifications.isNotEmpty && _isFresh(_notificationsFetchedAt)) {
      return;
    }
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
              senderName: sender['name']?.toString() ?? 'user_default'.tr,
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
    _notificationsFetchedAt = DateTime.now();
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
    final s = path.toString().trim();
    if (s.startsWith('http')) return s;
    final base = ConstData.API_BASE;
    // تنظيف المسار من السلاشات المتكررة في البداية
    var cleanPath = s;
    while (cleanPath.startsWith('/') && cleanPath.length > 1) {
      cleanPath = cleanPath.substring(1);
    }
    if (cleanPath == '/') cleanPath = '';

    return base.endsWith('/') ? '$base$cleanPath' : '$base/$cleanPath';
  }

  /// جلب الملف الشخصي من الـ API
  Future<void> loadMyProfile({bool force = false}) async {
    if (!force && _isFresh(_profileFetchedAt, const Duration(seconds: 60))) {
      return;
    }
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
          profilePicture: fullImageUrl(
            d['profile_picture']?.toString() ??
                d['avatar_url']?.toString() ??
                d['avatarUrl']?.toString() ??
                d['image_url']?.toString() ??
                d['imageUrl']?.toString(),
          ),
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
        final profileIsCompany =
            d['is_company'] == true ||
            d['role']?.toString().toLowerCase() == 'company' ||
            d['user_type']?.toString().toLowerCase() == 'company' ||
            d['type']?.toString().toLowerCase() == 'company';
        final profileIsPersonal =
            d['is_company'] == false ||
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
    _profileFetchedAt = DateTime.now();
  }

  /// جلب منشورات الملف الشخصي من الـ API
  Future<void> loadMyProfilePosts({bool force = false}) async {
    if (!force && profilePosts.isNotEmpty && _isFresh(_profilePostsFetchedAt)) {
      return;
    }
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
    _profilePostsFetchedAt = DateTime.now();
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
          name: d['name']?.toString() ?? 'user_default'.tr,
          username: d['username']?.toString(),
          job: d['professional_title'] ?? d['job']?.toString(),
          education: d['education']?.toString(),
          livesIn: d['current_location'] ?? d['lives_in']?.toString(),
          from: d['origin_location'] ?? d['from']?.toString(),
          profilePicture: fullImageUrl(
            d['profile_picture']?.toString() ??
                d['avatar_url']?.toString() ??
                d['avatarUrl']?.toString() ??
                d['image_url']?.toString() ??
                d['imageUrl']?.toString(),
          ),
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
      Get.snackbar(
        'update_failed'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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
            final profilePic = m['profile_picture']?.toString() ??
                m['avatar_url']?.toString() ??
                m['avatarUrl']?.toString() ??
                m['image_url']?.toString() ??
                m['imageUrl']?.toString();
            return UserProfileModel(
              id: '${m['user_id'] ?? m['id']}',
              name: m['name']?.toString() ?? 'user_default'.tr,
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

  /// جلب الطلبات/المشاريع المرفوعة من الـ API (لوحة التحكم)
  /// الباكند يُرجع 403 إذا المستخدم ليس شركة
  Future<void> loadOrders() async {
    if (orders.isNotEmpty && _isFresh(_ordersFetchedAt)) return;
    isOrdersLoading.value = true;
    try {
      // ملاحظة: في بيئة السيرفر الحالية، /dashboard/posts يرجّع 401 "توكن غير صالح (لوحة التحكم)"
      // بينما نفس التوكن يعمل مع باقي الـ endpoints. لذلك نعتمد على /home/orders.
      final res = await HomeApiService.getHomeOrders();
      if (res.status == 403) {
        orders.value = [];
        Get.snackbar(
          'alert'.tr,
          res.message ?? 'orders_company_only'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (res.isSuccess && res.data != null) {
        final rawList = res.data!['orders'] ?? res.data!['data'];
        if (rawList is List && rawList.isNotEmpty) {
          final now = DateTime.now();
          final list = <OrderModel>[];
          for (final e in rawList) {
            if (e is! Map) continue;
            final m = Map<String, dynamic>.from(e);
            // حساب نهاية المؤقت (إن وُجدت)
            DateTime? endAt;
            final createdAtStr = m['created_at']?.toString();
            final createdAt = createdAtStr != null
                ? DateTime.tryParse(createdAtStr)
                : null;
            final deadlineStr =
                m['deadline']?.toString() ??
                m['end_at']?.toString() ??
                m['ends_at']?.toString();
            if (deadlineStr != null && deadlineStr.isNotEmpty) {
              endAt = DateTime.tryParse(deadlineStr);
            } else if (createdAt != null &&
                (m['timer_days'] != null ||
                    m['timer_hours'] != null ||
                    m['timer_minutes'] != null)) {
              final days = int.tryParse('${m['timer_days'] ?? 0}') ?? 0;
              final hours = int.tryParse('${m['timer_hours'] ?? 0}') ?? 0;
              final minutes = int.tryParse('${m['timer_minutes'] ?? 0}') ?? 0;
              endAt = createdAt.add(
                Duration(days: days, hours: hours, minutes: minutes),
              );
            }
            // إخفاء الطلبات المنتهية
            if (endAt != null && endAt.isBefore(now)) continue;

            final order = OrderModel.fromJson(m, formatTime: _formatTimeAgo);
            final img = order.imageUrl;
            final fullImg = fullImageUrl(img);
            list.add(
              OrderModel(
                id: order.id,
                title: order.title,
                timeAgo: order.timeAgo,
                imageUrl: fullImg,
              ),
            );
          }
          orders.value = list;
          return;
        }
      }

      // fallback: السيرفر يعيد قائمة فارغة من /home/orders لكن منشورات الشركة موجودة في /profile/me/posts وبداخلها order_id
      if (profilePosts.isEmpty) {
        await loadMyProfilePosts();
      }
      final fallback = <OrderModel>[];
      for (final p in profilePosts) {
        final oid = p.orderId;
        if (oid == null) continue;
        final createdAt = p.createdAt;
        final img = fullImageUrl(p.imageUrl) ?? p.imageUrl;
        fallback.add(
          OrderModel(
            id: oid.toString(),
            title: p.title,
            timeAgo: _formatTimeAgo(createdAt),
            imageUrl: img,
          ),
        );
      }
      orders.value = fallback;
    } finally {
      isOrdersLoading.value = false;
    }
    _ordersFetchedAt = DateTime.now();
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
                ChatSocketService.instance.disconnect();
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
