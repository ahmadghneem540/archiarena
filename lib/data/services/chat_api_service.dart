import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

class ChatApiService {
  ChatApiService._();

  static final _dio = ApiClient.dio;

  /// POST /chat/conversations/start — يُنشئ محادثة أو يعيد الحالة الحالية
  static Future<ApiResponse<Map<String, dynamic>>> startConversation(
    int userId,
  ) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.chatConversationStart,
        data: {'user_id': userId},
      );
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getConversations({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.chatConversations,
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseListEnvelope(res.data, key: 'conversations');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getMessages(
    int conversationId, {
    int page = 1,
    int limit = 50,
    int? beforeId,
  }) async {
    try {
      final q = <String, dynamic>{'page': page, 'limit': limit};
      if (beforeId != null) q['before_id'] = beforeId;
      final res = await _dio.get(
        ApiEndpoints.chatConversationMessages(conversationId),
        queryParameters: q,
      );
      return _parseListEnvelope(res.data, key: 'messages');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> sendMessage(
    int conversationId,
    String body,
  ) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.chatSendMessage(conversationId),
        data: {'body': body.trim()},
      );
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getIncomingRequests({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.chatRequestsIncoming,
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseListEnvelope(res.data, key: 'requests');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getIncomingRequestsCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.chatRequestsIncomingCount);
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      // إن لم يُنفَّذ المسار على السيرفر نُرجع فشلاً هادئاً
      if (e.response?.statusCode == 404) {
        return ApiResponse(status: 404, data: {'count': 0});
      }
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> acceptRequest(
    int requestId,
  ) async {
    try {
      final res = await _dio.post(ApiEndpoints.chatRequestAccept(requestId));
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> rejectRequest(
    int requestId,
  ) async {
    try {
      final res = await _dio.post(ApiEndpoints.chatRequestReject(requestId));
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> blockUser(int userId) async {
    try {
      final res = await _dio.post(ApiEndpoints.chatBlockUser(userId));
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> unblockUser(int userId) async {
    try {
      final res = await _dio.post(ApiEndpoints.chatUnblockUser(userId));
      return _asMapResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponse<Map<String, dynamic>> _asMapResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final status = raw['status'] as int? ?? 200;
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return ApiResponse(
          status: status,
          data: data,
          message: raw['message'] as String?,
        );
      }
      return ApiResponse(
        status: status,
        data: <String, dynamic>{'raw': data},
        message: raw['message'] as String?,
      );
    }
    return ApiResponse(status: 200, data: <String, dynamic>{});
  }

  static ApiResponse<Map<String, dynamic>> _parseListEnvelope(
    dynamic raw, {
    required String key,
  }) {
    if (raw is List) {
      return ApiResponse(
        status: 200,
        data: {key: raw, 'list': raw},
      );
    }
    if (raw is Map<String, dynamic>) {
      final status = raw['status'] as int? ?? 200;
      final data = raw['data'];
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        final inner = data[key] ??
            data['messages'] ??
            data['data'] ??
            data['items'] ??
            data['rows'] ??
            data['results'] ??
            data['records'] ??
            data['messageList'] ??
            data['list'];
        if (inner is List) list = inner;
      } else {
        final alt = raw[key];
        if (alt is List) list = alt;
      }
      if (list.isEmpty) {
        final top = raw[key];
        if (top is List) list = top;
      }
      // ترقيم Laravel الشائع داخل data: current_page, last_page, data: [...]
      final pageMeta = <String, dynamic>{};
      if (data is Map) {
        final dm = Map<String, dynamic>.from(data);
        for (final k in [
          'current_page',
          'last_page',
          'total',
          'per_page',
          'from',
          'to',
        ]) {
          if (dm[k] != null) pageMeta[k] = dm[k];
        }
      }
      return ApiResponse(
        status: status,
        data: {
          key: list,
          'list': list,
          ...pageMeta,
          if (raw['pagination'] is Map)
            'pagination': Map<String, dynamic>.from(raw['pagination'] as Map),
          if (raw['meta'] is Map)
            'meta': Map<String, dynamic>.from(raw['meta'] as Map),
        },
        message: raw['message'] as String?,
      );
    }
    return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
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
