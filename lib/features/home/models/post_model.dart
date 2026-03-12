/// عنصر صورة أو مخطط من الـ API
class PostImageItem {
  PostImageItem({this.id, required this.url, this.order});
  final int? id;
  final String url;
  final int? order;
  static PostImageItem? fromJson(dynamic json) {
    if (json is Map) {
      final m = Map<String, dynamic>.from(json);
      final url = m['url']?.toString();
      if (url == null || url.isEmpty) return null;
      return PostImageItem(
        id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
        url: url,
        order: m['order'] is int ? m['order'] as int : int.tryParse('${m['order']}'),
      );
    }
    return null;
  }
}

/// عنصر مخطط (خطة)
class PostPlanItem {
  PostPlanItem({this.id, required this.url, this.title});
  final int? id;
  final String url;
  final String? title;
  static PostPlanItem? fromJson(dynamic json) {
    if (json is Map) {
      final m = Map<String, dynamic>.from(json);
      final url = m['url']?.toString();
      if (url == null || url.isEmpty) return null;
      return PostPlanItem(
        id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
        url: url,
        title: m['title']?.toString(),
      );
    }
    return null;
  }
}

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
    this.projectTimer,
    this.designDetails,
    this.projectTypes,
    this.area,
    this.planStatus,
    this.suitableFor,
    this.style,
    this.images = const [],
    this.plans = const [],
    this.blueprints = const [],
    this.attachments = const [],
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
  final String? projectTimer;
  final String? designDetails;
  final String? projectTypes;
  final String? area;
  final String? planStatus;
  final String? suitableFor;
  final String? style;
  final List<PostImageItem> images;
  final List<PostPlanItem> plans;
  final List<PostPlanItem> blueprints;
  final List<PostImageItem> attachments;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? json['user'];
    final id = json['post_id'] ?? json['id'];
    final imagesRaw = json['images'];
    final plansRaw = json['plans'];
    final blueprintsRaw = json['blueprints'];
    final attachmentsRaw = json['attachments'];
    return PostModel(
      id: id is int ? id : int.tryParse('${id}') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      authorName: author is Map
          ? (author['name'] ?? author['username'])?.toString()
          : null,
      authorAvatar: author is Map
          ? (author['profile_picture'] ?? author['avatar_url'])?.toString()
          : null,
      imageUrl: _extractImageUrl(json),
      likesCount: json['like_count'] ?? json['likes_count'] ?? json['likesCount'] ?? 0,
      commentsCount: json['comment_count'] ?? json['comments_count'] ?? json['commentsCount'] ?? 0,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      createdAt: json['created_at'] ?? json['createdAt']?.toString(),
      budget: json['budget']?.toString() ?? json['cost']?.toString(),
      deadline: json['deadline']?.toString() ?? json['deadline_at']?.toString() ?? json['ends_at']?.toString(),
      projectTimer: json['project_timer']?.toString(),
      designDetails: json['design_details']?.toString(),
      projectTypes: json['project_types']?.toString(),
      area: json['area']?.toString(),
      planStatus: json['plan_status']?.toString(),
      suitableFor: json['suitable_for']?.toString(),
      style: json['style']?.toString(),
      images: _parseImageList(imagesRaw),
      plans: _parsePlanList(plansRaw),
      blueprints: _parsePlanList(blueprintsRaw),
      attachments: _parseImageList(attachmentsRaw is List ? attachmentsRaw : null),
    );
  }

  static List<PostImageItem> _parseImageList(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => PostImageItem.fromJson(e))
        .whereType<PostImageItem>()
        .toList();
  }

  static List<PostPlanItem> _parsePlanList(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => PostPlanItem.fromJson(e))
        .whereType<PostPlanItem>()
        .toList();
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
    return json['main_image_url']?.toString() ??
        json['image_url']?.toString() ??
        json['imageUrl']?.toString();
  }
}
