class ChatThreadModel {
  ChatThreadModel({
    required this.conversationId,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    this.lastMessageBody,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final int conversationId;
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  final String? lastMessageBody;
  final DateTime? lastMessageAt;
  final int unreadCount;

  static ChatThreadModel? fromJson(Map<String, dynamic> m) {
    final cid = _intOf(m['conversation_id'] ?? m['id']);
    if (cid == null) return null;

    Map<String, dynamic> peer = {};
    if (m['peer'] is Map) {
      peer = Map<String, dynamic>.from(m['peer'] as Map);
    } else if (m['user'] is Map) {
      peer = Map<String, dynamic>.from(m['user'] as Map);
    } else if (m['other_user'] is Map) {
      peer = Map<String, dynamic>.from(m['other_user'] as Map);
    }

    final peerId =
        '${peer['user_id'] ?? peer['id'] ?? m['peer_id'] ?? m['user_id'] ?? ''}';
    if (peerId.isEmpty) return null;

    final last = m['last_message'] is Map
        ? Map<String, dynamic>.from(m['last_message'] as Map)
        : <String, dynamic>{};

    DateTime? lastAt;
    final rawLast = last['created_at'] ?? m['last_message_at'];
    if (rawLast != null) {
      lastAt = DateTime.tryParse(rawLast.toString());
    }

    return ChatThreadModel(
      conversationId: cid,
      peerId: peerId,
      peerName: peer['name']?.toString() ??
          peer['username']?.toString() ??
          '',
      peerAvatar: peer['profile_picture']?.toString(),
      lastMessageBody:
          last['body']?.toString() ?? last['message']?.toString(),
      lastMessageAt: lastAt,
      unreadCount: _intOf(m['unread_count'] ?? last['unread_count']) ?? 0,
    );
  }

  static int? _intOf(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
