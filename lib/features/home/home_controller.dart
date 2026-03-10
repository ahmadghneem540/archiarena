import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // شروط رفع المشروع من الـ API
  final uploadConditions = <String>[].obs;

  // المنشورات من الـ API
  final posts = <PostModel>[].obs;

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
  UserProfileModel myProfile = UserProfileModel(
    id: 'me',
    name: 'المستخدم',
    username: 'uid0526',
    job: '',
    education: '',
    livesIn: '',
    from: '',
  );
  final suggestionUsers = <UserProfileModel>[].obs;

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

    myProfile = UserProfileModel(
      id: 'me',
      name: 'المستخدم',
      username: 'uid0526',
      job: 'مؤسس ومدير تنفيذي في شركة زيرو لقص الليزر',
      education: 'دراسة هندسة عمارة في جامعة دمشق',
      livesIn: 'سوريا',
      from: 'درعا، داعل',
    );
    loadMyProfile();
    _addSampleComments();
    loadUploadConditions();
    loadPosts();
    loadFriendRequests();
    loadFriendSuggestions();
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
  }

  /// جلب طلبات الصداقة
  Future<void> loadFriendRequests() async {
    final res = await FriendsApiService.getRequests();
    if (res.isSuccess && res.data != null) {
      final list = res.data!['requests'] ?? res.data!['data'];
      if (list is List && list.isNotEmpty) {
        friendRequests.value = list.map((e) {
          final m = e is Map ? Map.from(e) : {};
          final sender = m['sender'] is Map ? Map.from(m['sender']) : {};
          return FriendRequestModel(
            id: '${m['request_id'] ?? m['id'] ?? sender['user_id']}',
            name: sender['name']?.toString() ?? 'مستخدم',
            mutualCount: m['mutual_friends_count'] ?? 0,
            timeAgo: _formatTimeAgo(m['created_at']),
          );
        }).toList();
      }
    }
    if (friendRequests.isEmpty) _addSampleFriendRequests();
    final countRes = await FriendsApiService.getRequestsCount();
    if (countRes.isSuccess && countRes.data != null) {
      notificationCount.value =
          countRes.data!['count'] ?? friendRequests.length;
    }
  }

  /// جلب اقتراحات الأصدقاء
  Future<void> loadFriendSuggestions() async {
    final res = await FriendsApiService.getSuggestions();
    if (res.isSuccess && res.data != null) {
      final list = res.data!['suggestions'] ?? res.data!['data'];
      if (list is List && list.isNotEmpty) {
        suggestionUsers.value = list.map((e) {
          final m = e is Map ? Map.from(e) : {};
          return UserProfileModel(
            id: '${m['user_id'] ?? m['id']}',
            name: m['name']?.toString() ?? 'مستخدم',
            username: m['username']?.toString(),
            job: m['job']?.toString(),
            mutualCount: m['mutual_friends_count'] ?? 0,
          );
        }).toList();
      }
    }
    if (suggestionUsers.isEmpty) _addSuggestionUsers();
  }

  /// جلب الإشعارات
  Future<void> loadNotifications() async {
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
    if (notifications.isEmpty) _addSampleNotifications();
    final countRes = await NotificationsApiService.getUnreadCount();
    if (countRes.isSuccess && countRes.data != null) {
      notificationCount.value =
          countRes.data!['count'] ?? notifications.length;
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

  /// جلب الملف الشخصي من الـ API
  Future<void> loadMyProfile() async {
    final res = await ProfileApiService.getMyProfile();
    if (res.isSuccess && res.data != null) {
      final d = res.data!;
      myProfile = UserProfileModel(
        id: '${d['id'] ?? 'me'}',
        name: d['name']?.toString() ?? myProfile.name,
        username: d['username']?.toString(),
        job: d['professional_title'] ?? d['job']?.toString(),
        education: d['education']?.toString(),
        livesIn: d['current_location'] ?? d['lives_in']?.toString(),
        from: d['origin_location'] ?? d['from']?.toString(),
      );
      final profileIsCompany = d['is_company'] == true ||
          d['user_type']?.toString().toLowerCase() == 'company' ||
          d['type']?.toString().toLowerCase() == 'company';
      final profileIsPersonal = d['is_company'] == false ||
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
