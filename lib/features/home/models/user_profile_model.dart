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

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? username,
    String? job,
    String? education,
    String? livesIn,
    String? from,
    int? mutualCount,
    String? profilePicture,
    String? coverImage,
    String? bio,
    String? company,
    int? postsCount,
    bool? isProfileLocked,
    bool? isOwn,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      job: job ?? this.job,
      education: education ?? this.education,
      livesIn: livesIn ?? this.livesIn,
      from: from ?? this.from,
      mutualCount: mutualCount ?? this.mutualCount,
      profilePicture: profilePicture ?? this.profilePicture,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      company: company ?? this.company,
      postsCount: postsCount ?? this.postsCount,
      isProfileLocked: isProfileLocked ?? this.isProfileLocked,
      isOwn: isOwn ?? this.isOwn,
    );
  }
}
