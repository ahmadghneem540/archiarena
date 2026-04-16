import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../firebase_options.dart';
import '../../data/services/notifications_api_service.dart';
import '../routes/app_routes.dart';

/// اسم ملف النغمة في android/app/src/main/res/raw/ (بدون امتداد). لتفعيل النغمة المميزة أضف الملف ثم أزل التعليق عن السطرين sound: في القناة وفي AndroidNotificationDetails.
const String _kNotificationSoundName = 'notification_sound';

/// خدمة إشعارات FCM — نغمة مميزة، فتح التطبيق عند النقر، للمستخدمين والشركات
class FcmService {
  FcmService._();

  /// مستمعون لبيانات الدردشة الواردة مع الإشعار (وضع التطبيق مفتوحاً) — لتحديث الواجهة فوراً
  /// دون الاعتماد على Socket.IO على الاستضافة المشتركة.
  static final List<void Function(Map<String, dynamic>)> _chatDataListeners = [];

  static void addChatDataListener(
    void Function(Map<String, dynamic>) listener,
  ) {
    if (!_chatDataListeners.contains(listener)) {
      _chatDataListeners.add(listener);
    }
  }

  static void removeChatDataListener(
    void Function(Map<String, dynamic>) listener,
  ) {
    _chatDataListeners.remove(listener);
  }

  static void _notifyChatDataListeners(Map<String, dynamic> data) {
    final copy = List<void Function(Map<String, dynamic>)>.from(
      _chatDataListeners,
    );
    for (final fn in copy) {
      try {
        fn(data);
      } catch (e, st) {
        debugPrint('[FCM] chat data listener error: $e\n$st');
      }
    }
  }

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// قناة الطلبات والعروض
  static AndroidNotificationChannel get _channel => const AndroidNotificationChannel(
        'archarena_orders',
        'Orders & proposals',
        description: 'Order and proposal notifications',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_kNotificationSoundName),
      );

  /// قناة مخصّصة للدردشة — نفس النغمة مع اهتزاز ووضوح عالٍ عند وصول رسالة.
  static AndroidNotificationChannel get _channelChat =>
      const AndroidNotificationChannel(
        'archarena_chat',
        'Messages',
        description: 'Chat message alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(_kNotificationSoundName),
      );

  /// تهيئة FCM وطلب الإذن — [Firebase.initializeApp] يُستدعى مرة واحدة في [main] مع [DefaultFirebaseOptions].
  /// استدعاء ثانٍ هنا يسبب duplicate-app ويمنع تسجيل المستمعين فلا تصل أي إشعارات.
  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _requestAndroidPostNotificationsPermission();
    await _ensureAndroidChannels(_localNotifications);
    _listenToMessages();
    _listenToMessageOpenedApp();
    _listenToTokenRefresh();
    await _handleInitialMessage();
    await _logToken();
  }

  static Future<void> _requestAndroidPostNotificationsPermission() async {
    if (!Platform.isAndroid) return;
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        if (res.payload != null && res.payload!.isNotEmpty) {
          try {
            final data = Map<String, dynamic>.from(
              jsonDecode(res.payload!) as Map);
            _navigateFromNotification(data);
          } catch (_) {}
        }
      },
    );
  }

  static Future<void> _ensureAndroidChannels(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    if (!Platform.isAndroid) return;
    final android = plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    await android?.createNotificationChannel(_channelChat);
  }

  /// عنوان/نص افتراضي حسب نوع الإشعار (عند قبول عرض، عرض جديد، إلخ)
  static void _applyNotificationContent(
    Map<String, dynamic> data,
    String type,
  ) {
    // يمكن توسيع النصوص حسب type من الباكند
    if (type == 'proposal_accepted') {
      data['title'] ??= 'proposal_accepted_title'.tr;
      data['body'] ??= 'proposal_accepted_body'.tr;
    } else if (type == 'new_proposal') {
      data['title'] ??= 'new_proposal_title'.tr;
      data['body'] ??= 'new_proposal_body'.tr;
    } else if (type == 'chat_message' || type == 'new_chat_message') {
      data['title'] ??=
          data['sender_name']?.toString().trim().isNotEmpty == true
              ? data['sender_name'].toString()
              : data['title']?.toString() ?? 'chat_push_title'.tr;
      data['body'] ??= data['message']?.toString() ??
          data['body_text']?.toString() ??
          data['preview']?.toString() ??
          data['snippet']?.toString() ??
          'chat_push_body'.tr;
    } else if (type == 'chat_request' ||
        type == 'new_chat_request' ||
        type == 'chat_message_request') {
      data['title'] ??= 'chat_request_push_title'.tr;
      data['body'] ??= 'chat_request_push_body'.tr;
    } else if (type.contains('friend_request') ||
        type == 'new_friend_request' ||
        type == 'friend_request_received' ||
        type == 'friend_invite') {
      data['title'] ??=
          data['sender_name']?.toString().trim().isNotEmpty == true
              ? '${'new_friend_request'.tr} (${data['sender_name']})'
              : 'new_friend_request'.tr;
      data['body'] ??= data['message']?.toString() ??
          data['body_text']?.toString() ??
          'new_friend_request_body'.tr;
    }
  }

  /// نصوص بدون Get (لمعالج الخلفية — isolate منفصل)
  static void _applyNotificationContentPlain(
    Map<String, dynamic> data,
    String type,
  ) {
    if (type == 'proposal_accepted') {
      data['title'] ??= 'تم قبول العرض';
      data['body'] ??= 'تم قبول عرضك على الطلب.';
    } else if (type == 'new_proposal') {
      data['title'] ??= 'عرض جديد';
      data['body'] ??= 'ورد عرض جديد على طلبك.';
    } else if (type == 'chat_message' || type == 'new_chat_message') {
      data['title'] ??=
          data['sender_name']?.toString().trim().isNotEmpty == true
              ? data['sender_name'].toString()
              : data['title']?.toString() ?? 'رسالة جديدة';
      data['body'] ??= data['message']?.toString() ??
          data['body_text']?.toString() ??
          data['preview']?.toString() ??
          data['snippet']?.toString() ??
          'لديك رسالة جديدة في المحادثات';
    } else if (type == 'chat_request' ||
        type == 'new_chat_request' ||
        type == 'chat_message_request') {
      data['title'] ??= 'طلب مراسلة جديد';
      data['body'] ??= 'يريد أحدهم مراسلتك. افتح الطلبات للموافقة.';
    } else if (type.contains('friend_request') ||
        type == 'new_friend_request' ||
        type == 'friend_request_received' ||
        type == 'friend_invite') {
      data['title'] ??=
          data['sender_name']?.toString().trim().isNotEmpty == true
              ? 'طلب صداقة (${data['sender_name']})'
              : 'طلب صداقة جديد';
      data['body'] ??= data['message']?.toString() ??
          data['body_text']?.toString() ??
          'لديك طلب صداقة جديد.';
    }
  }

  /// عند إغلاق التطبيق أو وضعه في الخلفية: رسائل **data-only** لا يعرضها النظام تلقائياً — نعرضها هنا مع صوت/اهتزاز.
  /// إذا أرسل السيرفر حقل [notification] مع الرسالة، يعرضها FCM/النظام عادةً مع صوت القناة (لا نكرر هنا لتفادي الإشعار المزدوج).
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      if (kIsWeb) return;
      if (message.notification != null) {
        return;
      }
      final data = Map<String, dynamic>.from(message.data);
      if (data.isEmpty) return;

      final type = data['type']?.toString() ?? '';
      _applyNotificationContentPlain(data, type);
      final title = (data['title'] ?? '').toString().trim();
      final bodyRaw = (data['body'] ?? '').toString().trim();
      if (title.isEmpty) return;

      final isChat = type == 'chat_message' ||
          type == 'new_chat_message' ||
          type == 'chat_request' ||
          type == 'new_chat_request' ||
          type == 'chat_message_request';

      final bg = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await bg.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      await _ensureAndroidChannels(bg);

      await _showWithPlugin(
        bg,
        title: title,
        body: bodyRaw.isNotEmpty ? bodyRaw : 'إشعار',
        payload: jsonEncode(data),
        chatStyle: isChat,
        useGetForChannelLabels: false,
      );
    } catch (e, st) {
      debugPrint('[FCM] handleBackgroundMessage: $e\n$st');
    }
  }

  static void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = Map<String, dynamic>.from(message.data);
      final type = data['type']?.toString() ?? '';
      _applyNotificationContent(data, type);
      final title = notification?.title ?? data['title'] ?? 'notification_default'.tr;
      final body = notification?.body ?? data['body'] ?? '';
      final isChat = type == 'chat_message' ||
          type == 'new_chat_message' ||
          type == 'chat_request' ||
          type == 'new_chat_request' ||
          type == 'chat_message_request';
      final isFriendPush = type.contains('friend_request') ||
          type == 'new_friend_request' ||
          type == 'friend_request_received' ||
          type == 'friend_invite';
      _showLocalNotification(
        title: title,
        body: body.isNotEmpty ? body : 'notification_default'.tr,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
        chatStyle: isChat,
      );
      if (isChat) {
        _notifyChatDataListeners(data);
      }
      if (isFriendPush) {
        _notifyChatDataListeners({
          ...data,
          'type': 'friend_request_push',
        });
      }
    });
  }

  static void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      if (token.isEmpty) return;
      try {
        await NotificationsApiService.registerFcmToken(token);
        debugPrint('[FCM] Token refresh registered with server');
      } catch (e, st) {
        debugPrint('[FCM] onTokenRefresh register failed: $e\n$st');
      }
    });
  }

  static void _listenToMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateFromNotification(message.data);
    });
  }

  static Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _navigateFromNotification(message.data);
    }
  }

  /// الانتقال لصفحة الطلبات (أو تفاصيل طلب إن وُجد order_id)
  static void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    if (type == 'chat_message' || type == 'new_chat_message') {
      final peerId = data['peer_id']?.toString();
      Get.offAllNamed(
        AppRoutes.home,
        arguments: {
          'openChatAfterLoad': true,
          if (peerId != null && peerId.isNotEmpty) 'openChatPeerId': peerId,
          'openChatPeerName': data['peer_name']?.toString() ?? '',
          'openChatPeerAvatar': data['peer_avatar']?.toString(),
        },
      );
      return;
    }
    if (type == 'chat_request' ||
        type == 'new_chat_request' ||
        type == 'chat_message_request') {
      Get.offAllNamed(
        AppRoutes.home,
        arguments: {
          'openChatRequestsAfterLoad': true,
        },
      );
      return;
    }
    if (type.contains('friend_request') ||
        type == 'new_friend_request' ||
        type == 'friend_request_received' ||
        type == 'friend_invite') {
      Get.offAllNamed(
        AppRoutes.home,
        arguments: {'openGroupsTabAfterLoad': true},
      );
      return;
    }

    final orderId = data['order_id']?.toString();
    final orderTitle = data['order_title']?.toString() ?? 'order'.tr;
    Get.offAllNamed(
      AppRoutes.home,
      arguments: {
        'openOrdersTab': true,
        if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
        'orderTitle': orderTitle,
      },
    );
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    bool chatStyle = false,
  }) async {
    await _showWithPlugin(
      _localNotifications,
      title: title,
      body: body,
      payload: payload,
      chatStyle: chatStyle,
      useGetForChannelLabels: true,
    );
  }

  static Future<void> _showWithPlugin(
    FlutterLocalNotificationsPlugin plugin, {
    required String title,
    required String body,
    String? payload,
    bool chatStyle = false,
    bool useGetForChannelLabels = true,
  }) async {
    final channelName = chatStyle
        ? 'Messages'
        : (useGetForChannelLabels ? 'fcm_channel_name'.tr : 'archarena');
    final channelDesc = chatStyle
        ? 'Chat alerts'
        : (useGetForChannelLabels
            ? 'fcm_channel_description'.tr
            : 'Notifications');
    final android = AndroidNotificationDetails(
      chatStyle ? 'archarena_chat' : 'archarena_orders',
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.message,
      styleInformation: chatStyle && body.length > 60
          ? BigTextStyleInformation(body)
          : null,
      sound: RawResourceAndroidNotificationSound(_kNotificationSoundName),
    );
    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );
    final details = NotificationDetails(android: android, iOS: ios);
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> _logToken() async {
    final token = await _messaging.getToken();
    debugPrint('[FCM] Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
  }

  /// إرسال التوكن للسيرفر بعد تسجيل الدخول (يُستدعى من [HomeController] أيضاً).
  static Future<void> registerTokenWithServerIfLoggedIn() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      final res = await NotificationsApiService.registerFcmToken(token);
      if (kDebugMode) {
        debugPrint(
          '[FCM] registerFcmToken status=${res.status} ok=${res.status >= 200 && res.status < 300}',
        );
      }
    } catch (e, st) {
      debugPrint('[FCM] registerTokenWithServerIfLoggedIn: $e\n$st');
    }
  }

  /// الحصول على توكن الجهاز لإرساله للسيرفر (لإرسال الإشعارات لاحقاً)
  static Future<String?> getToken() async {
    return _messaging.getToken();
  }

  /// وضع التطوير فقط: التحقق من ربط Firebase (التوكن)، القنوات المحلية، وتسجيل التوكن على الـ API.
  /// أرسل نفس التوكن من **Firebase Console → Cloud Messaging → Send test message** لاختبار FCM من السيرفر.
  static Future<String> runDebugSelfTest() async {
    final buf = StringBuffer();
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return 'FCM token غير متوفر. تحقق من google-services.json واتصال Google Play Services.';
      }
      final showLen = token.length > 40 ? 40 : token.length;
      buf.writeln('Token (بداية): ${token.substring(0, showLen)}...');
      buf.writeln('طول التوكن: ${token.length}');

      await _showLocalNotification(
        title: 'اختبار إشعار archarena',
        body: 'قناة عامة — إن سمعت النغمة فالمسار صحيح.',
        chatStyle: false,
      );
      buf.writeln('تم طلب إشعار محلي (قناة archarena_orders).');

      await _showLocalNotification(
        title: 'رسالة تجريبية',
        body: 'قناة دردشة — نص أطول للتأكد من العرض والصوت على قناة المحادثات.',
        chatStyle: true,
      );
      buf.writeln('تم طلب إشعار محلي (قناة archarena_chat).');

      final res = await NotificationsApiService.registerFcmToken(token);
      buf.writeln(
        'تسجيل السيرفر: HTTP/حالة=${res.status} ${res.message != null ? "— ${res.message}" : ""}',
      );
      buf.writeln(
        '\nلاختبار FCM من Firebase: الصق التوكن في "Send test message" في وحدة التحكم.',
      );
    } catch (e, st) {
      buf.writeln('خطأ: $e');
      buf.writeln('$st');
    }
    return buf.toString();
  }
}

/// يُسجَّل في [main] — يجب أن يبقى دالة top-level مع [pragma vm:entry-point].
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.handleBackgroundMessage(message);
}
