/// نموذج الملف الشخصي — للعرض في التاب الرابع وملف المستخدم الآخر.
class UserProfileModel {
  UserProfileModel({
    required this.id,
    required this.name,
    this.username,
    this.job,
    this.education,
    this.livesIn,
    this.from,
    this.mutualCount = 0,
  });

  final String id;
  final String name;
  final String? username;
  final String? job;
  final String? education;
  final String? livesIn;
  final String? from;
  final int mutualCount;
}
