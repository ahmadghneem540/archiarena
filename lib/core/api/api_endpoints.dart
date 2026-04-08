/// ثوابت مسارات الـ API
class ApiEndpoints {
  ApiEndpoints._();

  static const String base = '';

  // ========== Auth ==========
  static const String authRegisterCustomer = '/auth/register_customer';
  static const String authRegisterCompany = '/auth/register_company';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authChangePassword = '/auth/change-password';

  // ========== OTP ==========
  static const String verifyOtp = '/verify/otp';

  // ========== Home / Posts ==========
  static const String homeUploadConditions = '/home/upload/conditions';
  static String homePosts([int? id]) =>
      id != null ? '/home/posts/$id' : '/home/posts';
  static String homePostLike(int id) => '/home/posts/$id/like';
  static String homePostComments(int postId) => '/home/posts/$postId/comments';
  static String homeCommentReply(int commentId) =>
      '/home/comments/$commentId/reply';

  // ========== Home / Orders ==========
  /// قسم الطلبات — GET
  static const String homeOrders = '/home/orders';
  /// قائمة العروض على طلب — GET
  static String homeOrderProposals(int orderId) =>
      '/home/orders/$orderId/proposals';
  /// تقديم عرض — POST (formData: message, image)
  static String homeOrderSubmitProposal(int orderId) =>
      '/home/orders/$orderId/proposals';
  /// قبول عرض (ورفض الباقي) — POST
  static String homeOrderAcceptProposal(int orderId, int proposalId) =>
      '/home/orders/$orderId/proposals/$proposalId/accept';

  // ========== Home / Works (الأعمال) ==========
  /// جلب أعمال المستخدم — GET
  static const String homeWorks = '/home/works';
  /// إضافة منشور إلى الأعمال — POST
  static const String homeWorksAdd = '/home/works';
  /// حذف منشور من الأعمال — DELETE
  static String homeWorksDelete(int postId) => '/home/works/$postId';

  // ========== Dashboard / Orders ==========
  /// قائمة المشاريع المرفوعة — GET
  static const String dashboardPosts = '/dashboard/posts';
  /// رفع مشروع إلى الطلبات — للمستخدمين العاديين والشركات (نفس المسار للجميع)
  static const String companyCreatePost = '/home/posts';

  // ========== Friends ==========
  static const String friendsRequestsCount = '/friends/requests/count';
  static const String friendsRequests = '/friends/requests';
  static String friendsRequestConfirm(int id) =>
      '/friends/requests/$id/confirm';
  static String friendsRequestDelete(int id) => '/friends/requests/$id';
  static const String friendsRequest = '/friends/request';
  static const String friendsSuggestions = '/friends/suggestions';
  static const String friends = '/friends';

  // ========== Profile ==========
  static const String profileMe = '/profile/me';
  static String profileUser(int userId) => '/profile/$userId';
  static const String profileMePicture = '/profile/me/picture';
  static const String profileMeCover = '/profile/me/cover';
  static const String profileMePosts = '/profile/me/posts';
  static const String profileMeVisibility = '/profile/me/visibility';
  static String profileUserPosts(int userId) => '/profile/$userId/posts';

  // ========== Search ==========
  static const String searchUsers = '/search/users';

  // ========== Notifications ==========
  static const String notificationsUnreadCount =
      '/notifications/unread-count';
  static const String notifications = '/notifications';
  /// تسجيل توكن FCM لإرسال الإشعارات (مستخدمون وشركات)
  static const String registerFcmToken = '/profile/me/fcm-token';
  static String notificationRead(int id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationDelete(int id) => '/notifications/$id';

  // ========== General ==========
  static const String health = '/health';
}
