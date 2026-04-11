/// عنصر صورة أو مخطط من الـ API
class PostImageItem {
  PostImageItem({
    this.id,
    required this.url,
    this.order,
    this.mimeType,
  });
  final int? id;
  final String url;
  final int? order;
  /// إن وُجد (مثل application/pdf) يُستخدم لتمييز المرفقات عن الصور.
  final String? mimeType;
  static PostImageItem? fromJson(dynamic json) {
    if (json is Map) {
      final m = Map<String, dynamic>.from(json);
      final url = m['url']?.toString();
      if (url == null || url.isEmpty) return null;
      return PostImageItem(
        id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
        url: url,
        order: m['order'] is int ? m['order'] as int : int.tryParse('${m['order']}'),
        mimeType: m['mime_type']?.toString() ??
            m['mimeType']?.toString() ??
            m['content_type']?.toString() ??
            m['type']?.toString(),
      );
    }
    return null;
  }

  bool get isPdfAttachment =>
      (mimeType != null && mimeType!.toLowerCase().contains('pdf')) ||
      isLikelyPdfUrl(url);
}

/// عنصر مخطط (خطة)
class PostPlanItem {
  PostPlanItem({this.id, required this.url, this.title});
  final int? id;
  final String url;
  final String? title;

  bool get looksLikePdf => isLikelyPdfUrl(url);

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
    this.orderId,
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
    this.timerEndsAt,
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
    this.planFileUrl,
  });

  final int id;
  /// معرف الطلب المرتبط (للطلبات/المشاريع من الشركات). يُستخدم عند تقديم عرض.
  final int? orderId;
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
  /// نهاية مؤقت الصفقة — من الـ API (`timer_ends_at`) أو محسوبة من `created_at` + `timer_days`/`timer_hours`.
  final DateTime? timerEndsAt;
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
  /// رابط ملف المخطط PDF المرفوع مع المنشور (إن رجعه الـ API).
  final String? planFileUrl;

  /// هل يُعرض صف مؤقت الصفقة (تاريخ انتهاء أو نص من السيرفر).
  bool get hasDealTimer =>
      timerEndsAt != null ||
      (projectTimer != null && projectTimer!.isNotEmpty);

  /// انتهى مؤقت الصفقة — يعتمد على [timerEndsAt] فقط (من الـ API أو المحسوب).
  bool get isDealExpired {
    final end = timerEndsAt;
    if (end == null) return false;
    return DateTime.now().toUtc().isAfter(end.toUtc());
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? json['user'];
    final id = json['post_id'] ?? json['id'];
    final imagesRaw = json['images'];
    final plansRaw = json['plans'];
    final blueprintsRaw = json['blueprints'];
    final attachmentsRaw = json['attachments'];
    final orderIdRaw = json['order_id'] ?? json['orderId'];
    final timerEndsAt = _parseTimerEndsAt(json);
    return PostModel(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      orderId: orderIdRaw != null ? int.tryParse('$orderIdRaw') : null,
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
      timerEndsAt: timerEndsAt,
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
      planFileUrl: _parsePlanFileUrl(json),
    );
  }

  static String? _parsePlanFileUrl(Map<String, dynamic> json) {
    const keys = [
      'plan_file_url',
      'plan_file',
      'plan_pdf',
      'plan_pdf_url',
      'planFileUrl',
      'plan_file_path',
      'document_url',
      'plan_document_url',
      'pdf_url',
      'file_url',
    ];
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is Map) {
        final u = v['url'] ?? v['path'];
        if (u != null && '$u'.trim().isNotEmpty) return '$u'.trim();
      }
    }
    for (final nestedKey in ['plan', 'document', 'plan_document']) {
      final nested = json[nestedKey];
      if (nested is Map) {
        final u = nested['url'] ?? nested['file_url'] ?? nested['pdf_url'] ?? nested['path'];
        if (u != null && '$u'.trim().isNotEmpty) return '$u'.trim();
      }
    }
    return null;
  }

  /// دمج استجابة تفاصيل المنشور مع نسخة الخلاصة حتى لا تُفقد روابط PDF إن لم يعِد الـ API نفس الحقول في GET /posts/:id.
  factory PostModel.mergeDetailWithFeed(PostModel detail, PostModel feed) {
    String? coalesce(String? a, String? b) {
      final x = a?.trim();
      if (x != null && x.isNotEmpty) return x;
      final y = b?.trim();
      if (y != null && y.isNotEmpty) return y;
      return null;
    }

    return PostModel(
      id: detail.id,
      orderId: detail.orderId ?? feed.orderId,
      title: detail.title.isNotEmpty ? detail.title : feed.title,
      description: coalesce(detail.description, feed.description),
      category: coalesce(detail.category, feed.category),
      authorName: coalesce(detail.authorName, feed.authorName),
      authorAvatar: coalesce(detail.authorAvatar, feed.authorAvatar),
      imageUrl: coalesce(detail.imageUrl, feed.imageUrl),
      likesCount: detail.likesCount,
      commentsCount: detail.commentsCount,
      isLiked: detail.isLiked,
      createdAt: coalesce(detail.createdAt, feed.createdAt),
      budget: coalesce(detail.budget, feed.budget),
      deadline: coalesce(detail.deadline, feed.deadline),
      projectTimer: coalesce(detail.projectTimer, feed.projectTimer),
      timerEndsAt: detail.timerEndsAt ?? feed.timerEndsAt,
      designDetails: coalesce(detail.designDetails, feed.designDetails),
      projectTypes: coalesce(detail.projectTypes, feed.projectTypes),
      area: coalesce(detail.area, feed.area),
      planStatus: coalesce(detail.planStatus, feed.planStatus),
      suitableFor: coalesce(detail.suitableFor, feed.suitableFor),
      style: coalesce(detail.style, feed.style),
      images: detail.images.isNotEmpty ? detail.images : feed.images,
      plans: _mergePlanListsByUrl(detail.plans, feed.plans),
      blueprints: _mergePlanListsByUrl(detail.blueprints, feed.blueprints),
      attachments: _mergeImageListsByUrl(detail.attachments, feed.attachments),
      planFileUrl: coalesce(detail.planFileUrl, feed.planFileUrl),
    );
  }

  static List<PostImageItem> _mergeImageListsByUrl(
    List<PostImageItem> a,
    List<PostImageItem> b,
  ) {
    final seen = <String>{};
    final out = <PostImageItem>[];
    for (final x in [...a, ...b]) {
      final u = x.url.trim();
      if (u.isEmpty) continue;
      if (seen.add(u)) out.add(x);
    }
    return out;
  }

  static List<PostPlanItem> _mergePlanListsByUrl(
    List<PostPlanItem> a,
    List<PostPlanItem> b,
  ) {
    final seen = <String>{};
    final out = <PostPlanItem>[];
    for (final x in [...a, ...b]) {
      final u = x.url.trim();
      if (u.isEmpty) continue;
      if (seen.add(u)) out.add(x);
    }
    return out;
  }

  /// هل يوجد ملف PDF يمكن تنزيله.
  bool get hasDownloadablePlanPdf =>
      (planFileUrl != null && planFileUrl!.isNotEmpty) ||
      attachments.any((e) => e.isPdfAttachment) ||
      plans.any((e) => e.looksLikePdf) ||
      blueprints.any((e) => e.looksLikePdf);

  /// إظهار زر «تحميل المخطط…»: PDF أو أي عنصر في plans/blueprints له رابط (مثل صورة JPG للمعاينة).
  bool get shouldShowDownloadPlanButton =>
      hasDownloadablePlanPdf ||
      plans.any((e) => e.url.trim().isNotEmpty) ||
      blueprints.any((e) => e.url.trim().isNotEmpty);

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

  static DateTime? _parseTimerEndsAt(Map<String, dynamic> json) {
    final direct = json['timer_ends_at'] ??
        json['deal_ends_at'] ??
        json['project_timer_ends_at'] ??
        json['timer_end_at'] ??
        json['deal_end_at'];
    if (direct != null) {
      final s = direct.toString().trim();
      if (s.isNotEmpty) {
        final d = DateTime.tryParse(s);
        if (d != null) return d;
      }
    }
    final createdAtStr =
        json['created_at']?.toString() ?? json['createdAt']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
    if (createdAt == null) return null;
    final hasTimer = json['timer_days'] != null ||
        json['timer_hours'] != null ||
        json['timer_minutes'] != null;
    if (!hasTimer) return null;
    final days = int.tryParse('${json['timer_days'] ?? 0}') ?? 0;
    final hours = int.tryParse('${json['timer_hours'] ?? 0}') ?? 0;
    final minutes = int.tryParse('${json['timer_minutes'] ?? 0}') ?? 0;
    if (days == 0 && hours == 0 && minutes == 0) return null;
    return createdAt.add(Duration(days: days, hours: hours, minutes: minutes));
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

  PostModel copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      orderId: orderId,
      title: title,
      description: description,
      category: category,
      authorName: authorName,
      authorAvatar: authorAvatar,
      imageUrl: imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      budget: budget,
      deadline: deadline,
      projectTimer: projectTimer,
      timerEndsAt: timerEndsAt,
      designDetails: designDetails,
      projectTypes: projectTypes,
      area: area,
      planStatus: planStatus,
      suitableFor: suitableFor,
      style: style,
      images: images,
      plans: plans,
      blueprints: blueprints,
      attachments: attachments,
      planFileUrl: planFileUrl,
    );
  }
}

/// رابط يُفترض أنه PDF (امتداد .pdf أو استعلام يحتوي pdf).
bool isLikelyPdfUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final u = url.split('?').first.toLowerCase();
  if (u.endsWith('.pdf')) return true;
  final q = url.toLowerCase();
  return q.contains('.pdf?') || q.contains('format=pdf') || q.contains('type=pdf');
}
