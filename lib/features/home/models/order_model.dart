/// نموذج الطلب/المشروع المرفوع
class OrderModel {
  OrderModel({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String timeAgo;
  final String imageUrl;
}
