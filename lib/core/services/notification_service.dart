// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//   final _firestore = FirebaseFirestore.instance;
//   Function(RemoteMessage)? onNotificationTapped;
//
//   Future<void> initNotification() async {
//     /// 1- permission
//     if (Platform.isIOS) {
//       await _firebaseMessaging.requestPermission();
//     } else {
//       await _firebaseMessaging.requestPermission();
//     }
//
//     ///2- image app
//     const AndroidInitializationSettings androidIdInit =
//     AndroidInitializationSettings('app_logo');
//     const DarwinInitializationSettings iosIdInit = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const InitializationSettings initSetting = InitializationSettings(
//       android: androidIdInit,
//       iOS: iosIdInit,
//     );
//     await _flutterLocalNotificationsPlugin.initialize(
//       initSetting,
//       onDidReceiveNotificationResponse: (details) {
//         if (details.payload != null && details.payload!.isNotEmpty) {
//           final data = Map<String, dynamic>.from(jsonDecode(details.payload!));
//           final RemoteMessage mockMsg = RemoteMessage(
//               data: data,
//               notification: RemoteNotification(
//                   title: data['title'] as String?,
//                   body: data['body'] as String?
//               )
//           );
//           onNotificationTapped?.call(mockMsg);
//         }
//       },
//     );
//
//     ///3- foreground + background
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       "import_channel",
//       "channel1",
//     );
//
//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//     >()
//         ?.createNotificationChannel(channel);
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       await showNotification(message);
//     });
//   }
//
//   Future<void> showLocalNotification(RemoteMessage msg) async {
//     final notification = msg.notification;
//     if (notification != null) {
//       final payloadJson = jsonEncode(msg.data);
//       AndroidNotificationDetails androidDetails =
//       const AndroidNotificationDetails(
//         "import_channel", "channel1",
//         color: Color.fromARGB(1, 255, 255, 255),
//         importance: Importance.max,
//         priority: Priority.max ,
//         category: AndroidNotificationCategory.social ,
//       );
//
//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//       NotificationDetails platformDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );
//
//       await _flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         platformDetails,
//         payload: payloadJson,
//       );
//     }
//   }
//
//   ///4- show notifications in app
//   Future<void> showNotification(RemoteMessage msg) async {
//     final notification = msg.notification;
//     if (notification != null) {
//       const largeIcon = DrawableResourceAndroidBitmap('app_logo');
//       AndroidNotificationDetails androidDetails =
//       const AndroidNotificationDetails("import_channel",
//         "channel1",
//         importance: Importance.max,
//         priority: Priority.high,
//         category: AndroidNotificationCategory.social,
//         color: Color(0xFFFFFFFF),
//         colorized: true,
//         largeIcon: largeIcon,
//         icon: 'app_logo',
//         styleInformation: DefaultStyleInformation(true, true),
//       );
//
//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//       NotificationDetails platformDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );
//       final payloadJson = jsonEncode(msg.data);
//       await _flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         platformDetails,
//         payload: payloadJson,
//       );
//     }
//   }
//
//   /// 5- getToken
//   Future<String?> getToken() async {
//     return await _firebaseMessaging.getToken();
//   }
//   Future<String?> getDeviceToken(String userId) async {
//     try {
//       final doc = await FirebaseFirestore.instance.collection(AppCollections.user).doc(userId).get();
//       return doc.data()?['deviceToken'] as String?;
//     } catch (_) {
//       return null;
//     }
//   }
//
//   ///6- NotificationModel from RemoteMessage
//   NotificationModel fromRemoteMessage(RemoteMessage msg) {
//     final currentUserId = AccountSwitcherController.to.currentUid.value;
//     final data = msg.data;
//
//     // Extract required fields, prioritizing notification for title/body
//     final title = msg.notification?.title ?? data['title'] ?? "No Title";
//     final body = msg.notification?.body ?? data['body'] ?? "No Body";
//     final type = data['type'] as String? ?? 'general';
//     final senderId = data['senderId'] as String? ?? '';
//     final receiverId = data['receiverId'] as String? ?? currentUserId ?? '';
//     final targetId = data['targetId'] as String? ?? '';
//     final id = msg.messageId ?? const Uuid().v4();
//
//     // Extract optional rich data
//     final senderName = data['senderName'] as String?;
//     final senderImage = data['senderImage'] as String?;
//     final thumbnailUrl = data['thumbnailUrl'] as String?;
//     final actionIcon = data['actionIcon'] as String?;
//
//     return NotificationModel(
//       id: id,
//       title: title,
//       body: body,
//       type: type,
//       senderId: senderId,
//       receiverId: receiverId,
//       targetId: targetId,
//       data: data,
//       time: DateTime.now(),
//       isRead: false,
//       senderName: senderName,
//       senderImage: senderImage,
//       thumbnailUrl: thumbnailUrl,
//       actionIcon: actionIcon,
//     );
//   }
//
//   ///7- save the data notification in database
//   Future<void> saveToFirestore(RemoteMessage msg) async {
//     final notification = fromRemoteMessage(msg);
//
//     // Save using the richer model data
//     await _firestore.collection(AppCollections.notifications).add({
//       'title': notification.title,
//       'body': notification.body,
//       'time': notification.time.toIso8601String(), // Store as string for flexibility
//       'isRead': false,
//       'data': msg.data,
//       'receiverId': notification.receiverId,
//       'type': notification.type,
//       'senderId': notification.senderId,
//       'targetId': notification.targetId,
//       'senderName': notification.senderName,
//       'senderImage': notification.senderImage,
//       'thumbnailUrl': notification.thumbnailUrl,
//       'actionIcon': notification.actionIcon,
//     });
//   }
//
//   ///8- getNotifications
//   Stream<List<NotificationModel>> getNotifications() {
//     final currentUserId = AccountSwitcherController.to.currentUid.value;
//     if (currentUserId == null || currentUserId.isEmpty) {
//       return Stream.value([]);
//     }
//     return _firestore
//         .collection(AppCollections.notifications)
//         .where('receiverId', isEqualTo: currentUserId).orderBy('time', descending: true)
//         .snapshots()
//         .map(
//       // Use the correct fromFirestore factory
//           (snapshot) => snapshot.docs
//           .map((doc) => NotificationModel.fromFirestore(doc))
//           .toList(),
//     );
//   }
//
//   ///9- update the msg stutes
//   Future<void> markRead(String id) async {
//     await _firestore.collection(AppCollections.notifications).doc(id).update({
//       'isRead': true,
//     });
//   }
//
//   ///10- delete notification
//
//   Future<void> deleteNotification(String id) async {
//     await _firestore.collection(AppCollections.notifications).doc(id).delete();
//   }
//
//   ///11- send notification from mobile to mobile
//   Future<void> sendNotification({
//     required String deviceToken,
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     final url = Uri.parse(
//       "https://us-central1-relic-707e7.cloudfunctions.net/sendNotification",
//     );
//     final payload = {
//       "token": deviceToken,
//       "title": title,
//       "body": body,
//       if (data != null) "data": data,
//     };
//     await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(payload),
//     );
//   }
// }