import 'dart:io';

import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

class HomeApiService {
  HomeApiService._();

  static final _dio = ApiClient.dio;

  /// جلب شروط رفع المشروع
  static Future<ApiResponse<Map<String, dynamic>>> getUploadConditions() async {
    try {
      final res = await _dio.get(ApiEndpoints.homeUploadConditions);
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// جلب قائمة المنشورات
  static Future<ApiResponse<Map<String, dynamic>>> getPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.homePosts(),
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

  /// جلب تفاصيل منشور
  static Future<ApiResponse<Map<String, dynamic>>> getPost(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.homePosts(id));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// إنشاء منشور (رفع مشروع)
  static Future<ApiResponse<Map<String, dynamic>>> createPost({
    required String title,
    required String category,
    required String description,
    String? designDetails,
    String? projectTypes,
    String? area,
    String? planStatus,
    String? suitableFor,
    String? style,
    String? budget,
    String? deadline,
    List<File>? images,
  }) async {
    try {
      final map = <String, dynamic>{
        'title': title,
        'category': category,
        'description': description,
        if (designDetails != null) 'design_details': designDetails,
        if (projectTypes != null) 'project_types': projectTypes,
        if (area != null) 'area': area,
        if (planStatus != null) 'plan_status': planStatus,
        if (suitableFor != null) 'suitable_for': suitableFor,
        if (style != null) 'style': style,
        if (budget != null && budget.isNotEmpty) 'budget': budget,
        if (deadline != null && deadline.isNotEmpty) 'deadline': deadline,
      };

      final List<MultipartFile> imageFiles = [];
      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length && i < 10; i++) {
          imageFiles.add(
            await MultipartFile.fromFile(images[i].path, filename: 'images'),
          );
        }
        map['images'] = imageFiles;
      }

      final formData = FormData.fromMap(map);

      final res = await _dio.post(
        ApiEndpoints.homePosts(),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// إعجاب / إلغاء إعجاب
  static Future<ApiResponse<Map<String, dynamic>>> toggleLike(int postId) async {
    try {
      final res = await _dio.post(ApiEndpoints.homePostLike(postId));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// جلب التعليقات
  static Future<ApiResponse<Map<String, dynamic>>> getComments(
    int postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.homePostComments(postId),
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

  /// إضافة تعليق
  static Future<ApiResponse<Map<String, dynamic>>> addComment(
    int postId, {
    String? body,
    File? image,
    File? audio,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (body != null && body.isNotEmpty) map['body'] = body;
      if (image != null) {
        map['image'] = await MultipartFile.fromFile(image.path);
      }
      if (audio != null) {
        map['audio'] = await MultipartFile.fromFile(audio.path);
      }

      if (map.isEmpty) {
        return ApiResponse(status: 400, message: 'يجب إدخال نص أو صورة أو صوت');
      }

      final formData = FormData.fromMap(map);
      final res = await _dio.post(
        ApiEndpoints.homePostComments(postId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// رد على تعليق
  static Future<ApiResponse<Map<String, dynamic>>> replyComment(
    int commentId, {
    String? body,
    File? image,
    File? audio,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (body != null && body.isNotEmpty) map['body'] = body;
      if (image != null) {
        map['image'] = await MultipartFile.fromFile(image.path);
      }
      if (audio != null) {
        map['audio'] = await MultipartFile.fromFile(audio.path);
      }

      if (map.isEmpty) {
        return ApiResponse(status: 400, message: 'يجب إدخال نص أو صورة أو صوت');
      }

      final formData = FormData.fromMap(map);
      final res = await _dio.post(
        ApiEndpoints.homeCommentReply(commentId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
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
