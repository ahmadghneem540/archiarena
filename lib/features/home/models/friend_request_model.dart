/// نموذج طلب صداقة — للعرض في التاب الثالث (الأصدقاء).
class FriendRequestModel {
  FriendRequestModel({
    required this.id,
    required this.name,
    required this.mutualCount,
    required this.timeAgo,
    this.avatarPath,
    this.senderUserId,
  });

  /// معرف الطلب (request_id) — يُستخدم في قبول/رفض الطلب عبر الـ API.
  final String id;

  /// معرف المستخدم المرسل — يُستخدم للدخول إلى بروفايله.
  final String? senderUserId;

  final String name;

  /// عدد الأصدقاء المشتركين معي.
  final int mutualCount;

  /// نص مثل "منذ 9 أسابيع" أو "9w".
  final String timeAgo;
  final String? avatarPath;
}
