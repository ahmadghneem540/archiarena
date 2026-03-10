/// نموذج المنشور من الـ API
class PostModel {
  PostModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.authorName,
    this.authorAvatar,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.createdAt,
    this.budget,
    this.deadline,
  });

  final int id;
  final String title;
  final String? description;
  final String? category;
  final String? authorName;
  final String? authorAvatar;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String? createdAt;
  final String? budget;
  final String? deadline;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? json['user'];
    return PostModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      authorName: author is Map
          ? (author['name'] ?? author['username'])?.toString()
          : null,
      authorAvatar: author is Map ? author['avatar_url']?.toString() : null,
      imageUrl: _extractImageUrl(json),
      likesCount: json['likes_count'] ?? json['likesCount'] ?? 0,
      commentsCount: json['comments_count'] ?? json['commentsCount'] ?? 0,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      createdAt: json['created_at'] ?? json['createdAt']?.toString(),
      budget: json['budget']?.toString(),
      deadline: json['deadline']?.toString(),
    );
  }

  static String? _extractImageUrl(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) return first;
      if (first is Map) {
        return first['url'] ?? first['image_url'] ?? first['path']?.toString();
      }
      return first?.toString();
    }
    return json['image_url'] ?? json['imageUrl']?.toString();
  }
}
