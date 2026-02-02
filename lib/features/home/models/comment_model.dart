/// نموذج التعليق — يدعم التعليق النصي والصوتي والردود المتداخلة.
class CommentModel {
  CommentModel({
    required this.id,
    required this.authorName,
    required this.createdAt,
    this.parentId,
    this.text,
    this.audioPath,
    this.audioDurationSeconds,
    List<CommentModel>? replies,
  }) : replies = replies ?? [];

  final String id;
  final String authorName;
  final String? parentId;
  final String? text;
  final String? audioPath;

  /// مدة التعليق الصوتي بالثواني (للعرض والتحكم).
  final int? audioDurationSeconds;
  final String createdAt;
  final List<CommentModel> replies;

  bool get isAudio => audioPath != null && audioPath!.isNotEmpty;

  CommentModel copyWith({
    String? id,
    String? authorName,
    String? parentId,
    String? text,
    String? audioPath,
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
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}
