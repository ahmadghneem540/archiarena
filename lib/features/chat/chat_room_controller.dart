import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constant/const_data.dart';
import '../../core/services/chat_socket_service.dart';
import '../../core/services/fcm_service.dart';
import '../../core/services/services.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/chat_api_service.dart';
import '../home/home_controller.dart';
import 'models/chat_message_model.dart';

class ChatRoomController extends GetxController with WidgetsBindingObserver {
  late final int peerUserId;
  late final String peerDisplayName;
  String? peerAvatar;

  final messages = <ChatMessageModel>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final isStarting = true.obs;

  /// يجب أن يكون reactive حتى يعيد Obx بناء حقل الإدخال بعد `await _startConversation`.
  final Rxn<int> conversationId = Rxn<int>();

  /// active | pending_outgoing | pending_incoming | blocked | unknown
  final messagingState = 'unknown'.obs;

  String? myUserId;

  /// اسم المستخدم الحالي للعرض فوق فقاعات «رسائلي» (إن وُجد في الملف الشخصي المحمّل).
  String myProfileName = '';

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _fallbackPollTimer;
  final Set<String> _seenMessageIds = {};
  bool _pollSeeded = false;
  void Function(Map<String, dynamic>)? _realtimeHandler;
  void Function(Map<String, dynamic>)? _fcmChatListener;
  bool _observerRegistered = false;

  static const int _messagesPageSize = 100;
  static const int _maxMessagePages = 50;

  bool get canSendMessage {
    if (conversationId.value == null) return false;
    final s = messagingState.value;
    if (s.contains('blocked')) return false;
    if (s == 'pending_outgoing') return false;
    if (s == 'pending_incoming') return false;
    return true;
  }

  String? get statusBannerKey {
    final s = messagingState.value;
    if (s.contains('blocked')) return 'chat_status_blocked';
    if (s == 'pending_outgoing') return 'chat_status_pending_outgoing';
    if (s == 'pending_incoming') return 'chat_status_pending_incoming';
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final m = Map<String, dynamic>.from(args);
      peerUserId = int.tryParse('${m['peerId']}') ?? 0;
      peerDisplayName = m['peerName']?.toString() ?? '';
      peerAvatar = m['peerAvatar']?.toString();
    } else {
      peerUserId = 0;
      peerDisplayName = '';
    }
    if (peerUserId <= 0) {
      isLoading.value = false;
      isStarting.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('error'.tr, 'chat_invalid_peer'.tr);
        Get.back();
      });
      return;
    }
    _bootstrap();
  }

  @override
  void onReady() {
    super.onReady();
    if (peerUserId > 0) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && conversationId.value != null) {
      _syncConversationAndMessages();
    }
  }

  Future<void> _bootstrap() async {
    myUserId = await MyServices.getStringValue(ConstData.keyUserId);
    if (myUserId == null || myUserId!.trim().isEmpty) {
      if (Get.isRegistered<HomeController>()) {
        final id = Get.find<HomeController>().myProfile.id.trim();
        if (id.isNotEmpty) myUserId = id;
      }
    }
    if (Get.isRegistered<HomeController>()) {
      final n = Get.find<HomeController>().myProfile.name.trim();
      if (n.isNotEmpty) myProfileName = n;
    }
    await _startConversation(quiet: false);
    if (conversationId.value != null) {
      await loadMessages(
        fetchAllPages: true,
        scrollAfter: true,
        scrollForced: true,
      );
      _realtimeHandler = _onRealtimeMessage;
      await ChatSocketService.instance.ensureConnected();
      ChatSocketService.instance.subscribe(
        conversationId.value!,
        _realtimeHandler!,
      );
      _startFallbackPolling();
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (isClosed) return;
        _syncConversationAndMessages();
      });
    }
    if (peerUserId > 0) {
      _fcmChatListener = _onFcmChatData;
      FcmService.addChatDataListener(_fcmChatListener!);
    }
    isLoading.value = false;
    isStarting.value = false;
  }

  /// تحديث حالة المحادثة من السيرفر ثم الرسائل — يفعّل الحقل فور الموافقة على المراسلة دون إعادة فتح الشاشة.
  Future<void> _syncConversationAndMessages() async {
    if (peerUserId <= 0) return;
    await _startConversation(quiet: true);
    if (conversationId.value != null) {
      await loadMessages(silent: true, scrollAfter: true, scrollForced: false);
    }
  }

  Future<void> _startConversation({bool quiet = false}) async {
    final res = await ChatApiService.startConversation(peerUserId);
    if (!res.isSuccess || res.data == null) {
      if (!quiet) {
        Get.snackbar(
          'failure'.tr,
          res.message ?? 'chat_start_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }
    final d = res.data!;
    final cid = _intOf(d['conversation_id'] ?? d['id']);
    conversationId.value = cid;
    var state = d['messaging_state']?.toString() ??
        d['state']?.toString() ??
        'unknown';
    if (state == 'unknown' && d['can_send'] == true) state = 'active';
    if (state == 'unknown' && d['pending_outgoing'] == true) {
      state = 'pending_outgoing';
    }
    if (state == 'unknown' && d['pending_incoming'] == true) {
      state = 'pending_incoming';
    }
    messagingState.value = state;
    messagingState.refresh();
    conversationId.refresh();
  }

  int? _intOf(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// مزامنة دورية: حالة المحادثة (للانتقال من انتظار الموافقة إلى نشط) + آخر الرسائل.
  void _startFallbackPolling() {
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _syncConversationAndMessages();
    });
  }

  /// عند وصول إشعار FCM أثناء فتح الشاشة — تحديث فوري حتى لو تعطّل Socket على الاستضافة المشتركة.
  void _onFcmChatData(Map<String, dynamic> data) {
    if (isClosed) return;
    final type = data['type']?.toString() ?? '';
    if (type != 'chat_message' && type != 'new_chat_message') return;
    final cid = int.tryParse(
      '${data['conversation_id'] ?? data['conversationId'] ?? ''}',
    );
    final peer = int.tryParse('${data['peer_id'] ?? data['peerId'] ?? ''}');
    final myCid = conversationId.value;
    var matches = false;
    if (myCid != null && cid != null && cid == myCid) {
      matches = true;
    } else if (peer != null && peer == peerUserId) {
      matches = true;
    }
    if (!matches) return;
    unawaited(_syncConversationAndMessages());
  }

  void _onRealtimeMessage(Map<String, dynamic> raw) {
    final uid = myUserId;
    if (uid == null) return;
    final msg = ChatMessageModel.fromJson(
      ChatMessageModel.normalizeMap(raw),
      currentUserId: uid,
      peerUserId: peerUserId,
    );
    if (msg == null) return;
    if (_seenMessageIds.contains(msg.id)) return;
    _seenMessageIds.add(msg.id);
    final list = List<ChatMessageModel>.from(messages);
    list.add(msg);
    list.sort((a, b) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });
    messages.assignAll(list);
    if (!msg.isMine) {
      HapticFeedback.mediumImpact();
    }
    _scrollToBottom(force: false, animated: false);
  }

  /// استخراج قائمة الرسائل من أي شكل شائع لاستجابة الـ API.
  List<dynamic>? _rawMessageListFromData(Map<String, dynamic>? d) {
    if (d == null) return null;
    const keys = [
      'messages',
      'list',
      'data',
      'items',
      'rows',
      'results',
      'records',
      'messageList',
    ];
    for (final k in keys) {
      final v = d[k];
      if (v is List) return v;
    }
    return null;
  }

  /// دمج رسائل الشاشة مع ما يعيده السيرفر — لا يُفقد محتوى إذا تأخر الـ GET أو رجع فارغاً بعد الإرسال.
  List<ChatMessageModel> _mergeMessageLists(
    List<ChatMessageModel> current,
    List<ChatMessageModel> fromServer,
  ) {
    final map = <String, ChatMessageModel>{};
    for (final m in current) {
      map[m.id] = m;
    }
    for (final m in fromServer) {
      map[m.id] = m;
    }
    final out = map.values.toList();
    out.sort((a, b) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });
    return out;
  }

  List<ChatMessageModel> _parseMessageList(List<dynamic> raw, String uid) {
    final parsed = <ChatMessageModel>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final msg = ChatMessageModel.fromJson(
        ChatMessageModel.normalizeMap(Map<String, dynamic>.from(e)),
        currentUserId: uid,
        peerUserId: peerUserId,
      );
      if (msg != null) parsed.add(msg);
    }
    parsed.sort((a, b) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });
    return parsed;
  }

  /// [fetchAllPages] عند الدخول: جلب كل الصفحات حتى يُستوعب التاريخ كاملاً (حد أمان في الكود).
  /// سحب للتحديث أو إعادة فتح المحادثة — يعيد جلب كامل الصفحات.
  Future<void> refreshMessages() async {
    await loadMessages(
      fetchAllPages: true,
      silent: true,
      scrollAfter: false,
    );
  }

  static int? _intMeta(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// أصغر `id` رقمي بين الرسائل — لطلب دفعة أقدم عبر `before_id`.
  static int? _minNumericMessageId(Iterable<ChatMessageModel> items) {
    int? minId;
    for (final m in items) {
      final n = int.tryParse(m.id);
      if (n != null && (minId == null || n < minId)) {
        minId = n;
      }
    }
    return minId;
  }

  Future<void> loadMessages({
    bool silent = false,
    bool fetchAllPages = false,
    /// بعد الدمج: تمرير للأسفل فقط إذا طُلب.
    bool scrollAfter = true,
    /// إجبار التمرير (فتح المحادثة، إلخ). إن كان false يُستخدم قرب الأسفل فقط.
    bool scrollForced = false,
  }) async {
    final cid = conversationId.value;
    if (cid == null || myUserId == null) return;
    if (!silent) isLoading.value = true;
    try {
      final uid = myUserId!;

      if (fetchAllPages) {
        List<ChatMessageModel> parsed;
        final byId = <String, ChatMessageModel>{};

        // 1) ترقيم صفحات (page / limit) + دعم meta.last_page من Laravel
        var page = 1;
        while (page <= _maxMessagePages) {
          final res = await ChatApiService.getMessages(
            cid,
            page: page,
            limit: _messagesPageSize,
          );
          if (!res.isSuccess || res.data == null) break;
          final d = res.data!;
          final list = _rawMessageListFromData(d);
          if (list == null || list.isEmpty) break;
          final chunk = _parseMessageList(list, uid);
          for (final m in chunk) {
            byId[m.id] = m;
          }
          final lastPage = _intMeta(d['last_page']);
          final currentPage = _intMeta(d['current_page']);
          if (lastPage != null &&
              currentPage != null &&
              currentPage >= lastPage) {
            break;
          }
          if (chunk.length < _messagesPageSize && lastPage == null) {
            break;
          }
          page++;
        }

        // 2) رسائل أقدم عبر before_id (حسب مواصفات الـ API)
        for (var step = 0; step < _maxMessagePages; step++) {
          final oldestId = _minNumericMessageId(byId.values);
          if (oldestId == null) break;
          final countBefore = byId.length;
          final res = await ChatApiService.getMessages(
            cid,
            page: 1,
            limit: _messagesPageSize,
            beforeId: oldestId,
          );
          if (!res.isSuccess || res.data == null) break;
          final list = _rawMessageListFromData(res.data!);
          if (list == null || list.isEmpty) break;
          final chunk = _parseMessageList(list, uid);
          for (final m in chunk) {
            byId[m.id] = m;
          }
          if (byId.length == countBefore) break;
        }

        parsed = byId.values.toList()
          ..sort((a, b) {
            final ta = a.createdAt;
            final tb = b.createdAt;
            if (ta == null && tb == null) return 0;
            if (ta == null) return -1;
            if (tb == null) return 1;
            return ta.compareTo(tb);
          });
        _seenMessageIds
          ..clear()
          ..addAll(parsed.map((m) => m.id));
        _pollSeeded = true;
        messages.assignAll(parsed);
      } else {
        final res = await ChatApiService.getMessages(
          cid,
          limit: _messagesPageSize,
        );
        if (res.isSuccess && res.data != null) {
          final list = _rawMessageListFromData(res.data!);
          if (list != null) {
            final parsed = _parseMessageList(list, uid);
            if (silent) {
              // لا تُفرغ القائمة إذا رجع السيرفر [] مؤقتاً (بعد الإرسال أو تأخر التخزين).
              if (parsed.isEmpty) {
                return;
              }
              if (!_pollSeeded) {
                for (final m in parsed) {
                  _seenMessageIds.add(m.id);
                }
                _pollSeeded = true;
              } else {
                var newFromOther = false;
                for (final m in parsed) {
                  if (_seenMessageIds.contains(m.id)) continue;
                  _seenMessageIds.add(m.id);
                  if (!m.isMine) newFromOther = true;
                }
                if (newFromOther) {
                  HapticFeedback.mediumImpact();
                }
              }
              final merged = _mergeMessageLists(List<ChatMessageModel>.from(messages), parsed);
              for (final m in merged) {
                _seenMessageIds.add(m.id);
              }
              messages.assignAll(merged);
            } else {
              messages.assignAll(parsed);
              for (final m in parsed) {
                _seenMessageIds.add(m.id);
              }
              _pollSeeded = true;
            }
          }
        }
      }
    } finally {
      if (!silent) isLoading.value = false;
      if (scrollAfter) {
        _scrollToBottom(
          force: scrollForced || !silent,
          animated: scrollForced || !silent,
        );
      }
    }
  }

  static const double _nearBottomThreshold = 160;

  bool _isNearBottom() {
    if (!scrollController.hasClients) return true;
    final p = scrollController.position;
    return p.maxScrollExtent - p.pixels <= _nearBottomThreshold;
  }

  /// [force]: true = دائماً للأسفل (فتح الشاشة، إرسال). false = فقط إن كان المستخدم قرب آخر المحادثة.
  void _scrollToBottom({bool force = true, bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (!force && !_isNearBottom()) return;
      final max = scrollController.position.maxScrollExtent;
      if (max < 0) return;
      final target = max;
      if (animated) {
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(target);
      }
    });
  }

  /// يُرجع true إذا وُضعت رسالة في القائمة (جديدة أو مكررة مسبقاً).
  bool _appendMessageFromPayload(Map<String, dynamic>? d) {
    if (d == null || myUserId == null) return false;
    Map<String, dynamic> msgMap =
        ChatMessageModel.normalizeMap(Map<String, dynamic>.from(d));
    var msg = ChatMessageModel.fromJson(
      msgMap,
      currentUserId: myUserId!,
      peerUserId: peerUserId,
    );
    if (msg == null && d['raw'] is Map) {
      msgMap = ChatMessageModel.normalizeMap(
        Map<String, dynamic>.from(d['raw'] as Map),
      );
      msg = ChatMessageModel.fromJson(
        msgMap,
        currentUserId: myUserId!,
        peerUserId: peerUserId,
      );
    }
    if (msg == null) return false;
    if (_seenMessageIds.contains(msg.id)) return true;
    _seenMessageIds.add(msg.id);
    final list = List<ChatMessageModel>.from(messages);
    list.add(msg);
    list.sort((a, b) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });
    messages.assignAll(list);
    _scrollToBottom(force: true, animated: true);
    return true;
  }

  /// عندما لا يعيد الـ API جسم الرسالة بعد الإرسال — تظهر فوراً ثم تندمج مع الاستجابة لاحقاً.
  void _appendOptimisticSentMessage(String body) {
    if (myUserId == null || body.isEmpty) return;
    final id =
        'local_${DateTime.now().microsecondsSinceEpoch}_${body.hashCode}';
    if (_seenMessageIds.contains(id)) return;
    _seenMessageIds.add(id);
    final msg = ChatMessageModel(
      id: id,
      body: body,
      senderId: myUserId!,
      createdAt: DateTime.now(),
      isMine: true,
    );
    final list = List<ChatMessageModel>.from(messages)..add(msg);
    list.sort((a, b) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });
    messages.assignAll(list);
    _scrollToBottom(force: true, animated: true);
  }

  Future<void> send() async {
    final text = textController.text.trim();
    if (text.isEmpty || !canSendMessage) return;
    final cid = conversationId.value;
    if (cid == null) return;
    isSending.value = true;
    try {
      final res = await ChatApiService.sendMessage(cid, text);
      if (res.isSuccess) {
        textController.clear();
        final appended = _appendMessageFromPayload(res.data);
        if (!appended) {
          _appendOptimisticSentMessage(text);
        }
        unawaited(
          loadMessages(
            silent: true,
            scrollAfter: true,
            scrollForced: false,
          ),
        );
      } else {
        Get.snackbar(
          'failure'.tr,
          res.message ?? 'chat_send_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSending.value = false;
    }
  }

  Future<void> confirmUnblock() async {
    final ok = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('chat_unblock_confirm_title'.tr),
          content: Text('chat_unblock_confirm_body'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('chat_unblock'.tr),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final res = await ChatApiService.unblockUser(peerUserId);
    if (res.isSuccess) {
      await _startConversation(quiet: false);
      if (conversationId.value != null) {
        await loadMessages(fetchAllPages: true);
      }
      Get.snackbar('success'.tr, 'chat_unblocked_ok'.tr);
    } else {
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openIncomingRequestsTab() {
    Get.back();
    Get.toNamed(
      AppRoutes.chatInbox,
      arguments: {'openRequestsTab': true},
    );
  }

  Future<void> confirmBlock() async {
    final ok = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('chat_block_confirm_title'.tr),
          content: Text('chat_block_confirm_body'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'chat_block'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final res = await ChatApiService.blockUser(peerUserId);
    if (res.isSuccess) {
      messagingState.value = 'blocked';
      Get.snackbar('success'.tr, 'chat_blocked_ok'.tr);
      Get.back();
    } else {
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    if (_observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _observerRegistered = false;
    }
    _fallbackPollTimer?.cancel();
    if (_fcmChatListener != null) {
      FcmService.removeChatDataListener(_fcmChatListener!);
      _fcmChatListener = null;
    }
    final cid = conversationId.value;
    final h = _realtimeHandler;
    if (cid != null && h != null) {
      ChatSocketService.instance.unsubscribe(cid, h);
    }
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
