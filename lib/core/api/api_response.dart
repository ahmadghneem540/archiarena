/// نموذج الاستجابة العامة من الـ API
class ApiResponse<T> {
  final int status;
  final T? data;
  final String? message;

  ApiResponse({
    required this.status,
    this.data,
    this.message,
  });

  bool get isSuccess => status >= 200 && status < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    final status = json['status'] as int? ?? 0;
    final data = json['data'];
    final message = json['message'] as String?;

    T? parsedData;
    if (data != null && fromJsonT != null) {
      parsedData = fromJsonT(data);
    } else if (data != null) {
      parsedData = data as T?;
    }

    return ApiResponse<T>(
      status: status,
      data: parsedData,
      message: message,
    );
  }
}
