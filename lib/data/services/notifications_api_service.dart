import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

class NotificationsApiService {
  NotificationsApiService._();

  static final _dio = ApiClient.dio;

  /// عدد الإشعارات غير المقروءة
  static Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.notificationsUnreadCount);
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// قائمة الإشعارات
  static Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
    String status = 'all', // new | read | all
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': limit, 'status': status},
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تعليم إشعار كمقروء
  static Future<ApiResponse<Map<String, dynamic>>> markAsRead(
    int notificationId,
  ) async {
    try {
      final res =
          await _dio.post(ApiEndpoints.notificationRead(notificationId));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تعليم كل الإشعارات كمقروءة
  static Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    try {
      final res = await _dio.post(ApiEndpoints.notificationsReadAll);
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// حذف إشعار
  static Future<ApiResponse<Map<String, dynamic>>> deleteNotification(
    int notificationId,
  ) async {
    try {
      final res =
          await _dio.delete(ApiEndpoints.notificationDelete(notificationId));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponse<Map<String, dynamic>> _handleError(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    String? message;
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else {
      message = e.message ?? 'حدث خطأ في الاتصال';
    }
    return ApiResponse(status: status, message: message);
  }
}
