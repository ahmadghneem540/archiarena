class ChatRequestModel {
  ChatRequestModel({
    required this.requestId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.createdAt,
  });

  final int requestId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime? createdAt;

  static ChatRequestModel? fromJson(Map<String, dynamic> m) {
    final rid = _intOf(m['id'] ?? m['request_id']);
    if (rid == null) return null;

    Map<String, dynamic> sender = {};
    if (m['sender'] is Map) {
      sender = Map<String, dynamic>.from(m['sender'] as Map);
    } else if (m['user'] is Map) {
      sender = Map<String, dynamic>.from(m['user'] as Map);
    }

    final sid =
        '${sender['user_id'] ?? sender['id'] ?? m['sender_id'] ?? ''}';
    if (sid.isEmpty) return null;

    DateTime? at;
    final raw = m['created_at'];
    if (raw != null) at = DateTime.tryParse(raw.toString());

    return ChatRequestModel(
      requestId: rid,
      senderId: sid,
      senderName:
          sender['name']?.toString() ?? sender['username']?.toString() ?? '',
      senderAvatar: sender['profile_picture']?.toString(),
      createdAt: at,
    );
  }

  static int? _intOf(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
