import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
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
        'archiarena_orders',
        'Orders & proposals',
        description: 'Order and proposal notifications',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_kNotificationSoundName),
      );

  /// قناة مخصّصة للدردشة — نفس النغمة مع اهتزاز ووضوح عالٍ عند وصول رسالة.
  static AndroidNotificationChannel get _channelChat =>
      const AndroidNotificationChannel(
        'archiarena_chat',
        'Messages',
        description: 'Chat message alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(_kNotificationSoundName),
      );

  /// تهيئة Firebase و FCM وطلب الإذن
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('[FCM] Firebase.initializeApp error: $e');
      return;
    }

    await _requestPermission();
    await _initLocalNotifications();
    await _createNotificationChannel();
    _listenToMessages();
    _listenToMessageOpenedApp();
    await _handleInitialMessage();
    await _logToken();
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

  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_channel);
      await android?.createNotificationChannel(_channelChat);
    }
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
      _showLocalNotification(
        title: title,
        body: body.isNotEmpty ? body : 'notification_default'.tr,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
        chatStyle: isChat,
      );
      if (isChat) {
        _notifyChatDataListeners(data);
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
    final android = AndroidNotificationDetails(
      chatStyle ? 'archiarena_chat' : 'archiarena_orders',
      chatStyle ? 'Messages' : 'fcm_channel_name'.tr,
      channelDescription:
          chatStyle ? 'Chat alerts' : 'fcm_channel_description'.tr,
      importance: Importance.high,
      priority: Priority.high,
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
    await _localNotifications.show(
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
    // يمكن إرسال التوكن للسيرفر هنا عند الربط مع الباكند
  }

  /// الحصول على توكن الجهاز لإرساله للسيرفر (لإرسال الإشعارات لاحقاً)
  static Future<String?> getToken() async {
    return _messaging.getToken();
  }
}
