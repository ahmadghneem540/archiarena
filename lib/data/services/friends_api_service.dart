import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

class FriendsApiService {
  FriendsApiService._();

  static final _dio = ApiClient.dio;

  /// عدد طلبات الصداقة المعلقة — الاستجابة data: { count }
  static Future<ApiResponse<Map<String, dynamic>>> getRequestsCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.friendsRequestsCount);
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is Map) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: Map<String, dynamic>.from(data),
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

  /// قائمة طلبات الصداقة — كل عنصر: id، request_id، sender مع profile_picture
  static Future<ApiResponse<Map<String, dynamic>>> getRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.friendsRequests,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'requests': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'requests': data, 'data': data},
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

  /// قبول طلب صداقة — معالجة مصفوفة النتائج إن وُجدت
  static Future<ApiResponse<Map<String, dynamic>>> confirmRequest(
    int requestId,
  ) async {
    try {
      final res =
          await _dio.post(ApiEndpoints.friendsRequestConfirm(requestId));
      return _normalizeConfirmDeleteResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// رفض / حذف طلب صداقة — معالجة مصفوفة النتائج
  static Future<ApiResponse<Map<String, dynamic>>> deleteRequest(
    int requestId,
  ) async {
    try {
      final res = await _dio.delete(ApiEndpoints.friendsRequestDelete(requestId));
      return _normalizeConfirmDeleteResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponse<Map<String, dynamic>> _normalizeConfirmDeleteResponse(
    dynamic raw,
  ) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return ApiResponse(
          status: raw['status'] as int? ?? 200,
          data: <String, dynamic>{'results': data},
          message: raw['message'] as String?,
        );
      }
      return ApiResponse.fromJson(
        raw,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    }
    return ApiResponse(status: 200, data: <String, dynamic>{});
  }

  /// إرسال طلب صداقة
  static Future<ApiResponse<Map<String, dynamic>>> sendRequest(int userId) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.friendsRequest,
        data: {'user_id': userId},
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// اقتراحات أصدقاء — كل عنصر: id، user_id، job (من professional_title)، mutual_friends_count، profile_picture
  static Future<ApiResponse<Map<String, dynamic>>> getSuggestions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.friendsSuggestions,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'suggestions': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'suggestions': data, 'data': data},
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

  /// قائمة الأصدقاء
  static Future<ApiResponse<Map<String, dynamic>>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.friends,
        queryParameters: {'page': page, 'limit': limit},
      );
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
