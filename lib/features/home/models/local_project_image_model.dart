import 'package:hive/hive.dart';

part 'local_project_image_model.g.dart';

@HiveType(typeId: 1)
class LocalProjectImageModel extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String orderId;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  String authorName;

  @HiveField(4)
  String timeAgo;

  @HiveField(5)
  bool isAccepted;

  @HiveField(6)
  bool isRejected;

  @HiveField(7)
  String localPath;

  LocalProjectImageModel({
    required this.id,
    required this.orderId,
    required this.imageUrl,
    required this.authorName,
    required this.timeAgo,
    required this.isAccepted,
    required this.isRejected,
    required this.localPath,
  });
}