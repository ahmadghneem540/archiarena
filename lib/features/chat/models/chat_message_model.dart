class ChatMessageModel {
  ChatMessageModel({
    required this.id,
    required this.body,
    required this.senderId,
    required this.createdAt,
    this.isMine = false,
    this.senderName,
  });

  final String id;
  final String body;
  final String senderId;
  final DateTime? createdAt;
  final bool isMine;
  /// اسم للعرض فوق الفقاعة — من الـ API إن وُجد.
  final String? senderName;

  /// دمج الحقول الشائعة من الـ API (بما فيها كائن `message` المتداخل).
  static Map<String, dynamic> normalizeMap(Map<String, dynamic> m) {
    final out = Map<String, dynamic>.from(m);
    final inner = m['message'];
    if (inner is Map) {
      final im = Map<String, dynamic>.from(inner);
      for (final e in im.entries) {
        out.putIfAbsent(e.key, () => e.value);
      }
    }
    return out;
  }

  static ChatMessageModel? fromJson(
    Map<String, dynamic> m, {
    required String currentUserId,
    int? peerUserId,
  }) {
    final x = normalizeMap(m);
    var id = '${x['id'] ?? x['message_id'] ?? x['uuid'] ?? ''}'.trim();
    final sender = _senderString(x);
    final body = _bodyString(x);
    final rawTime =
        x['created_at'] ?? x['createdAt'] ?? x['sent_at'] ?? x['updated_at'];
    DateTime? at;
    if (rawTime != null) {
      at = DateTime.tryParse(rawTime.toString());
    }
    if (id.isEmpty) {
      if (body.isEmpty) return null;
      id = 'gen_${body.hashCode}_${sender.hashCode}_${at?.millisecondsSinceEpoch ?? 0}';
    }
    final isMine = _resolveIsMine(x, sender, currentUserId, peerUserId);
    return ChatMessageModel(
      id: id,
      body: body,
      senderId: sender,
      createdAt: at,
      isMine: isMine,
      senderName: _senderDisplayName(x),
    );
  }

  /// تحديد هل الرسالة من المستخدم الحالي (يمين) أم من الطرف المقابل (يسار).
  static bool _resolveIsMine(
    Map<String, dynamic> x,
    String sender,
    String currentUserId,
    int? peerUserId,
  ) {
    if (x['outgoing'] == true ||
        x['is_outgoing'] == true ||
        x['from_me'] == true ||
        x['is_from_me'] == true) {
      return true;
    }
    if (x['incoming'] == true || x['is_incoming'] == true) {
      return false;
    }
    final ex = x['is_mine'] ?? x['mine'] ?? x['isMine'];
    if (ex == false ||
        ex == 0 ||
        ex == '0' ||
        ex.toString().toLowerCase() == 'false') {
      return false;
    }
    if (_truthy(ex)) return true;

    if (sender.isNotEmpty) {
      if (_sameUser(sender, currentUserId) ||
          sender == 'me' ||
          sender == 'self') {
        return true;
      }
      if (peerUserId != null && _sameUser(sender, '$peerUserId')) {
        return false;
      }
      return false;
    }

    if (peerUserId != null && _recipientMatchesPeer(x, peerUserId)) {
      return true;
    }
    if (_recipientMatchesMe(x, currentUserId)) {
      return false;
    }
    return false;
  }

  static bool _recipientMatchesPeer(Map<String, dynamic> x, int peerId) {
    final r = x['recipient_id'] ??
        x['receiver_id'] ??
        x['to_user_id'] ??
        x['to_id'] ??
        x['receiver_user_id'];
    if (r == null) return false;
    return _sameUser('$r', '$peerId') || int.tryParse('$r') == peerId;
  }

  static bool _recipientMatchesMe(Map<String, dynamic> x, String myId) {
    final r = x['recipient_id'] ??
        x['receiver_id'] ??
        x['to_user_id'] ??
        x['to_id'];
    if (r == null) return false;
    return _sameUser('$r', myId);
  }

  static bool _truthy(dynamic v) {
    if (v == true) return true;
    if (v == 1 || v == '1') return true;
    return false;
  }

  static String _bodyString(Map<String, dynamic> x) {
    final direct = x['body'] ?? x['content'] ?? x['text'] ?? x['body_text'];
    if (direct != null && direct is! Map) {
      return direct.toString().trim();
    }
    final msg = x['message'];
    if (msg is String) return msg.trim();
    if (msg is Map) {
      final mm = Map<String, dynamic>.from(msg);
      final inner = mm['body'] ?? mm['text'] ?? mm['content'] ?? mm['message'];
      if (inner != null && inner is! Map) return inner.toString().trim();
    }
    return '';
  }

  /// معرف المرسل — نفضّل حقول المرسل الصريحة ثم الكائنات المتداخلة، و`user_id` الجذر في النهاية.
  static String _senderString(Map<String, dynamic> x) {
    final direct = x['sender_id'] ??
        x['senderId'] ??
        x['from_user_id'] ??
        x['fromUserId'] ??
        x['author_id'];
    if (direct != null && '$direct'.trim().isNotEmpty) {
      return '$direct'.trim();
    }
    final sender = x['sender'];
    if (sender is Map) {
      final sm = Map<String, dynamic>.from(sender);
      final id = sm['id'] ?? sm['user_id'] ?? sm['userId'];
      if (id != null && '$id'.trim().isNotEmpty) return '$id'.trim();
    }
    final from = x['from'];
    if (from is Map) {
      final fm = Map<String, dynamic>.from(from);
      final id = fm['id'] ?? fm['user_id'];
      if (id != null && '$id'.trim().isNotEmpty) return '$id'.trim();
    }
    final fromUser = x['from_user'] ?? x['fromUser'];
    if (fromUser is Map) {
      final fm = Map<String, dynamic>.from(fromUser);
      final id = fm['id'] ?? fm['user_id'] ?? fm['userId'];
      if (id != null && '$id'.trim().isNotEmpty) return '$id'.trim();
    }
    // كثير من الـ APIs يضع صاحب الرسالة في `user` { id }
    final user = x['user'];
    if (user is Map) {
      final um = Map<String, dynamic>.from(user);
      final id = um['id'] ?? um['user_id'] ?? um['userId'];
      if (id != null && '$id'.trim().isNotEmpty) return '$id'.trim();
    }
    final fallback = x['created_by'] ??
        x['from_id'] ??
        x['sender_user_id'] ??
        x['user_id'] ??
        x['author_id'];
    if (fallback != null && '$fallback'.trim().isNotEmpty) {
      return '$fallback'.trim();
    }
    return '';
  }

  static String? _senderDisplayName(Map<String, dynamic> x) {
    final flat = x['sender_name'] ??
        x['senderName'] ??
        x['author_name'] ??
        x['from_name'];
    if (flat != null && '$flat'.trim().isNotEmpty) return '$flat'.trim();
    final sender = x['sender'];
    if (sender is Map) {
      final sm = Map<String, dynamic>.from(sender);
      final n = sm['name'] ?? sm['username'] ?? sm['full_name'] ?? sm['display_name'];
      if (n != null && '$n'.trim().isNotEmpty) return '$n'.trim();
    }
    final from = x['from'];
    if (from is Map) {
      final fm = Map<String, dynamic>.from(from);
      final n = fm['name'] ?? fm['username'] ?? fm['full_name'];
      if (n != null && '$n'.trim().isNotEmpty) return '$n'.trim();
    }
    final user = x['user'];
    if (user is Map) {
      final um = Map<String, dynamic>.from(user);
      final n = um['name'] ?? um['username'] ?? um['full_name'];
      if (n != null && '$n'.trim().isNotEmpty) return '$n'.trim();
    }
    return null;
  }

  static bool _sameUser(String a, String b) {
    final sa = a.trim();
    final sb = b.trim();
    if (sa.isEmpty || sb.isEmpty) return false;
    if (sa == sb) return true;
    final ia = int.tryParse(sa);
    final ib = int.tryParse(sb);
    if (ia != null && ib != null) return ia == ib;
    return false;
  }

  /// تمييز «رسائلي» في الواجهة حتى لو كان الـ API يُرجع `is_mine` خاطئاً — يعتمد على [senderId].
  bool isFromMeForUi(String? currentUserId, int peerUserId) {
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return isMine;
    }
    final me = currentUserId.trim();
    if (senderId.isNotEmpty) {
      if (_sameUser(senderId, '$peerUserId')) return false;
      if (_sameUser(senderId, me)) return true;
      return isMine;
    }
    return isMine;
  }
}
