import 'package:get/get.dart';

/// نموذج صورة المشروع مع حالة القبول/الرفض
class ProjectImageModel {
  ProjectImageModel({
    required this.id,
    required this.imageUrl,
    required this.authorName,
    required this.timeAgo,
    bool isAccepted = false,
    bool isRejected = false,
  })  : isAccepted = isAccepted.obs,
        isRejected = isRejected.obs;

  final String id;
  final String imageUrl;
  final String authorName;
  final String timeAgo;
  final RxBool isAccepted;
  final RxBool isRejected;
}
