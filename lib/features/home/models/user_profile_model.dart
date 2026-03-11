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
    this.profilePicture,
    this.coverImage,
    this.bio,
    this.company,
    this.postsCount = 0,
    this.isProfileLocked = false,
    this.isOwn = false,
  });

  final String id;
  final String name;
  final String? username;
  final String? job;
  final String? education;
  final String? livesIn;
  final String? from;
  final int mutualCount;
  /// رابط صورة البروفايل (قد يكون مساراً نسبياً أو رابطاً كاملاً)
  final String? profilePicture;
  /// رابط صورة الغلاف
  final String? coverImage;
  final String? bio;
  final String? company;
  final int postsCount;
  final bool isProfileLocked;
  final bool isOwn;
}
