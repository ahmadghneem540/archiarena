/// نموذج التعليق — يدعم التعليق النصي والصوتي والصورة والردود.
class CommentModel {
  CommentModel({
    required this.id,
    required this.authorName,
    required this.createdAt,
    this.parentId,
    this.text,
    this.audioPath,
    this.imageUrl,
    this.audioDurationSeconds,
    this.authorAvatar,
    List<CommentModel>? replies,
  }) : replies = replies ?? [];

  final String id;
  final String authorName;
  final String? parentId;
  final String? text;
  final String? audioPath;
  final String? imageUrl;
  final String? authorAvatar;
  final int? audioDurationSeconds;
  final String createdAt;
  final List<CommentModel> replies;

  bool get isAudio => audioPath != null && audioPath!.isNotEmpty;

  /// من استجابة الـ API: id/comment_id، author: { user_id, name, profile_picture }، body/text، image_url، audio_url، parent_id، replies
  factory CommentModel.fromJson(Map<String, dynamic> json, {String Function(dynamic)? formatTime}) {
    final author = json['author'] is Map ? Map<String, dynamic>.from(json['author'] as Map) : null;
    final id = json['comment_id'] ?? json['id'];
    final rawReplies = json['replies'];
    final repliesList = rawReplies is List
        ? (rawReplies)
            .map((e) => e is Map ? CommentModel.fromJson(Map.from(e), formatTime: formatTime) : null)
            .whereType<CommentModel>()
            .toList()
        : <CommentModel>[];
    final createdAtRaw = json['created_at'];
    final createdAtStr = formatTime != null && createdAtRaw != null
        ? formatTime(createdAtRaw)
        : (createdAtRaw?.toString() ?? '');
    return CommentModel(
      id: id?.toString() ?? '',
      authorName: author?['name']?.toString() ?? 'مستخدم',
      authorAvatar: author?['profile_picture']?.toString(),
      parentId: json['parent_id']?.toString(),
      text: json['body']?.toString() ?? json['text']?.toString(),
      imageUrl: json['image_url']?.toString(),
      audioPath: json['audio_url']?.toString(),
      createdAt: createdAtStr,
      replies: repliesList,
    );
  }

  CommentModel copyWith({
    String? id,
    String? authorName,
    String? parentId,
    String? text,
    String? audioPath,
    String? imageUrl,
    int? audioDurationSeconds,
    String? createdAt,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      parentId: parentId ?? this.parentId,
      text: text ?? this.text,
      audioPath: audioPath ?? this.audioPath,
      imageUrl: imageUrl ?? this.imageUrl,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}
