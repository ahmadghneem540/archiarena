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
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'notifications': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'notifications': data, 'data': data},
            message: raw['message'] as String?,
          );
        }
        return ApiResponse.fromJson(
          raw,
          fromJsonT: (d) => d as Map<String, dynamic>,
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
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

  /// تسجيل توكن FCM للسيرفر (مستخدمون وشركات) — لاستقبال الإشعارات عند قبول العرض أو وصول عرض جديد
  static Future<ApiResponse<Map<String, dynamic>>> registerFcmToken(
    String fcmToken,
  ) async {
    Future<ApiResponse<Map<String, dynamic>>> postPath(String path) async {
      final res = await _dio.post(
        path,
        data: {'fcm_token': fcmToken},
      );
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        return ApiResponse(
          status: raw['status'] as int? ?? res.statusCode ?? 200,
          data: raw['data'] ?? raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(status: res.statusCode ?? 200, data: {}, message: null);
    }

    try {
      return await postPath(ApiEndpoints.registerFcmToken);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          return await postPath(ApiEndpoints.registerFcmTokenApiPrefix);
        } on DioException catch (e2) {
          return _handleError(e2);
        }
      }
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
