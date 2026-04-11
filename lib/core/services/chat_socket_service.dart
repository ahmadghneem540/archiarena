import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constant/const_data.dart';
import 'services.dart';

/// عميل Socket.IO واحد للتطبيق — الانضمام لغرف المحادثة واستقبال `chat:message`.
class ChatSocketService {
  ChatSocketService._();
  static final ChatSocketService instance = ChatSocketService._();

  io.Socket? _socket;

  /// conversationId -> callbacks
  final Map<int, List<void Function(Map<String, dynamic>)>> _byConversation = {};

  /// غرف ما زال يجب الإبقاء عليها بعد إعادة الاتصال
  final Set<int> _roomsToJoin = {};

  bool get isConnected => _socket?.connected == true;

  /// جذر الموقع فقط: `https://host` بدون منفذ ظاهر للـ 443/80 (يتجنّب `:0`)، أو `https://host:8443` إن وُجد منفذ صريح في [CHAT_SOCKET_URL].
  /// لا يُدمَج `/api` — Socket.IO على الجذر كما REST، مع مسار المحرك الافتراضي `/socket.io`.
  static String _socketUri() {
    final base = ConstData.CHAT_SOCKET_URL.trim();
    final ns = ConstData.CHAT_SOCKET_NAMESPACE.trim();
    final u = Uri.tryParse(base);
    if (u == null ||
        !u.hasScheme ||
        u.host.isEmpty ||
        (u.scheme != 'http' && u.scheme != 'https')) {
      return base;
    }

    final Uri originUri;
    final port = u.port;
    final hasBadOrMissingPort = !u.hasPort || port == 0;
    if (!hasBadOrMissingPort) {
      originUri = Uri(scheme: u.scheme, host: u.host, port: port);
    } else {
      // بدون منفذ في السلسلة (أو تصحيح :0) — الافتراضي 443/80 ولا يظهر :0
      originUri = Uri(scheme: u.scheme, host: u.host);
    }

    var origin = originUri.toString();
    if (origin.endsWith('/')) {
      origin = origin.substring(0, origin.length - 1);
    }

    if (ns.isEmpty || ns == '/') {
      return origin;
    }
    final pathNs = ns.startsWith('/') ? ns : '/$ns';
    return '$origin$pathNs';
  }

  /// يضمن وجود اتصال مع التوكن الحالي (يُستدعى عند فتح محادثة).
  Future<void> ensureConnected() async {
    final token = await MyServices.getStringValue(ConstData.keyToken);
    if (token == null || token.isEmpty) {
      debugPrint('[ChatSocket] لا يوجد توكن — تخطي الاتصال');
      return;
    }

    if (_socket != null) {
      if (_socket!.connected) {
        _rejoinRooms();
        return;
      }
      _socket!.connect();
      return;
    }

    final uri = _socketUri();
    debugPrint('[ChatSocket] اتصال بـ $uri (path محرك: ${ConstData.CHAT_SOCKET_IO_PATH})');

    _socket = io.io(
      uri,
      io.OptionBuilder()
          .setPath(ConstData.CHAT_SOCKET_IO_PATH)
          .setTransports(['polling', 'websocket'])
          .setTimeout(60000)
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          // مصادقة Socket.IO + ترويسة Bearer لسيرفرات تقرأ Authorization فقط
          .setAuth({'token': token})
          .setExtraHeaders(<String, dynamic>{
            'Authorization': 'Bearer $token',
          })
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[ChatSocket] متصل');
      _rejoinRooms();
    });

    _socket!.onDisconnect((_) {
      debugPrint('[ChatSocket] انقطع');
    });

    _socket!.onConnectError((dynamic e) {
      debugPrint('[ChatSocket] خطأ اتصال: $e');
    });

    // بعد تهيئة الـ socket — يُستقبل فور اتمام الجلسة
    _socket!.on('chat:message', _onChatMessage);
  }

  void _onChatMessage(dynamic data) {
    if (data is! Map) return;
    final envelope = Map<String, dynamic>.from(data);
    final cidRaw = envelope['conversation_id'] ?? envelope['conversationId'];
    final conversationId = cidRaw is int
        ? cidRaw
        : int.tryParse(cidRaw?.toString() ?? '');
    if (conversationId == null) return;

    Map<String, dynamic> messageMap;
    final inner = envelope['message'];
    if (inner is Map) {
      messageMap = Map<String, dynamic>.from(inner);
    } else {
      messageMap = envelope;
    }

    final cbs = _byConversation[conversationId];
    if (cbs == null || cbs.isEmpty) return;
    for (final cb in List<void Function(Map<String, dynamic>)>.from(cbs)) {
      try {
        cb(messageMap);
      } catch (e, st) {
        debugPrint('[ChatSocket] خطأ في مستمع: $e\n$st');
      }
    }
  }

  void _emitJoin(int conversationId) {
    _socket?.emit('chat:join', {'conversation_id': conversationId});
  }

  void _emitLeave(int conversationId) {
    _socket?.emit('chat:leave', {'conversation_id': conversationId});
  }

  void _rejoinRooms() {
    for (final id in _roomsToJoin) {
      _emitJoin(id);
    }
  }

  /// الاشتراك برسائل محادثة معيّنة (يُرسل للسيرفر `chat:join`).
  void subscribe(
    int conversationId,
    void Function(Map<String, dynamic> message) onMessage,
  ) {
    _byConversation.putIfAbsent(conversationId, () => []).add(onMessage);
    _roomsToJoin.add(conversationId);
    if (isConnected) {
      _emitJoin(conversationId);
    } else {
      ensureConnected();
    }
  }

  void unsubscribe(
    int conversationId,
    void Function(Map<String, dynamic> message) onMessage,
  ) {
    final list = _byConversation[conversationId];
    if (list == null) return;
    list.remove(onMessage);
    if (list.isEmpty) {
      _byConversation.remove(conversationId);
      _roomsToJoin.remove(conversationId);
      if (isConnected) {
        _emitLeave(conversationId);
      }
    }
  }

  /// عند تسجيل الخروج أو انتهاء الجلسة
  void disconnect() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _byConversation.clear();
    _roomsToJoin.clear();
  }
}
