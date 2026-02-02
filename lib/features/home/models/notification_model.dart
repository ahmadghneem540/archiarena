/// نوع الإشعار — تفاعل، تعليق، أو قبول صداقة.
enum NotificationType { interaction, comment, friendAcceptance }

/// نموذج إشعار — للعرض في التاب الخامس (الإشعارات).
class NotificationModel {
  NotificationModel({
    required this.id,
    required this.type,
    required this.senderName,
    required this.message,
    required this.timeAgo,
  });

  final String id;
  final NotificationType type;
  final String senderName;
  final String message;
  final String timeAgo;
}
