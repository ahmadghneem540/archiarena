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

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Channel is created at init (before runApp), so use fixed name; per-notification strings use .tr in _showLocalNotification.
  static AndroidNotificationChannel get _channel => const AndroidNotificationChannel(
        'archiarena_orders',
        'Orders & proposals',
        description: 'Order and proposal notifications',
        importance: Importance.high,
        playSound: true,
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
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
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
      _showLocalNotification(
        title: title,
        body: body,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
      );
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
  }) async {
    final android = AndroidNotificationDetails(
      'archiarena_orders',
      'fcm_channel_name'.tr,
      channelDescription: 'fcm_channel_description'.tr,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_kNotificationSoundName),
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // نغمة مميزة iOS: بعد إضافة notification_sound.aiff في Xcode أزل التعليق: sound: 'notification_sound.aiff',
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
