import '../../core/enum/notification_type.dart';

class NotificationModel {
  final String title;
  final String time;
  final String description;
  final NotificationType? type;
  final String? iconPath;

  NotificationModel({
    required this.title,
    required this.time,
    required this.description,
     this.type,
     this.iconPath
  });
}
