/// نموذج الطلب/المشروع المرفوع من الـ API
class OrderModel {
  OrderModel({
    required this.id,
    required this.title,
    required this.timeAgo,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String timeAgo;
  final String? imageUrl;

  /// تحويل من JSON عام:
  /// يتوقع الحقول: id/post_id، title، created_at، main_image_url/image_url
  factory OrderModel.fromJson(
    Map<String, dynamic> json, {
    required String Function(dynamic) formatTime,
  }) {
    final id = json['id'] ?? json['post_id'];
    final createdAtRaw = json['created_at'];
    return OrderModel(
      id: id?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      timeAgo: formatTime(createdAtRaw),
      imageUrl: json['main_image_url']?.toString() ??
          json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString(),
    );
  }
}
