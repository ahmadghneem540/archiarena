/// نموذج طلب صداقة — للعرض في التاب الثالث (الأصدقاء).
class FriendRequestModel {
  FriendRequestModel({
    required this.id,
    required this.name,
    required this.mutualCount,
    required this.timeAgo,
    this.avatarPath,
  });

  final String id;
  final String name;

  /// عدد الأصدقاء المشتركين معي.
  final int mutualCount;

  /// نص مثل "منذ 9 أسابيع" أو "9w".
  final String timeAgo;
  final String? avatarPath;
}
