/// ثوابت مسارات الـ API
class ApiEndpoints {
  ApiEndpoints._();

  static const String base = '';

  // ========== Auth ==========
  static const String authRegisterCustomer = '/auth/register_customer';
  static const String authRegisterCompany = '/auth/register_company';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authLogin = '/auth/login';

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

  // ========== Notifications ==========
  static const String notificationsUnreadCount =
      '/notifications/unread-count';
  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationDelete(int id) => '/notifications/$id';

  // ========== General ==========
  static const String health = '/health';
}
