import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

class FriendsApiService {
  FriendsApiService._();

  static final _dio = ApiClient.dio;

  /// عدد طلبات الصداقة المعلقة
  static Future<ApiResponse<Map<String, dynamic>>> getRequestsCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.friendsRequestsCount);
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// قائمة طلبات الصداقة الواردة
  static Future<ApiResponse<Map<String, dynamic>>> getRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.friendsRequests,
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

  /// قبول طلب صداقة
  static Future<ApiResponse<Map<String, dynamic>>> confirmRequest(
    int requestId,
  ) async {
    try {
      final res =
          await _dio.post(ApiEndpoints.friendsRequestConfirm(requestId));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// رفض / حذف طلب صداقة
  static Future<ApiResponse<Map<String, dynamic>>> deleteRequest(
    int requestId,
  ) async {
    try {
      final res = await _dio.delete(ApiEndpoints.friendsRequestDelete(requestId));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
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

  /// اقتراحات أصدقاء
  static Future<ApiResponse<Map<String, dynamic>>> getSuggestions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.friendsSuggestions,
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
