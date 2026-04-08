import 'dart:io';

import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

class ProfileApiService {
  ProfileApiService._();

  static final _dio = ApiClient.dio;

  /// ملفي الشخصي
  static Future<ApiResponse<Map<String, dynamic>>> getMyProfile() async {
    try {
      final res = await _dio.get(ApiEndpoints.profileMe);
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// ملف مستخدم آخر
  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile(
    int userId,
  ) async {
    try {
      final res = await _dio.get(ApiEndpoints.profileUser(userId));
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// منشورات ملفي الشخصي
  static Future<ApiResponse<Map<String, dynamic>>> getMyPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.profileMePosts,
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseProfilePostsResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// منشورات مستخدم آخر
  static Future<ApiResponse<Map<String, dynamic>>> getUserPosts(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.profileUserPosts(userId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseProfilePostsResponse(res.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponse<Map<String, dynamic>> _parseProfilePostsResponse(
    dynamic raw,
  ) {
    if (raw is! Map<String, dynamic>) {
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
    }
    final data = raw['data'];
    final list = data is List ? data : <dynamic>[];
    final pagination = raw['pagination'] is Map
        ? Map<String, dynamic>.from(raw['pagination'] as Map)
        : <String, dynamic>{};
    return ApiResponse(
      status: raw['status'] as int? ?? 200,
      data: {'posts': list, 'pagination': pagination},
      message: raw['message'] as String?,
    );
  }

  /// تحديث الملف الشخصي — PUT /profile/me
  static Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? professionalTitle,
    String? company,
    String? education,
    String? currentLocation,
    String? originLocation,
    bool? isProfileLocked,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (name != null) map['name'] = name;
      if (username != null) map['username'] = username;
      if (bio != null) map['bio'] = bio;
      if (professionalTitle != null) {
        map['professional_title'] = professionalTitle;
      }
      if (company != null) map['company'] = company;
      if (education != null) map['education'] = education;
      if (currentLocation != null) map['current_location'] = currentLocation;
      if (originLocation != null) map['origin_location'] = originLocation;
      if (isProfileLocked != null) map['is_profile_locked'] = isProfileLocked;

      final res = await _dio.put(ApiEndpoints.profileMe, data: map);
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        return ApiResponse(
          status: res.statusCode ?? 200,
          data: raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(
        status: res.statusCode ?? 200,
        data: <String, dynamic>{'data': raw},
        message: null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تحديث صورة الملف الشخصي
  static Future<ApiResponse<Map<String, dynamic>>> updateProfilePicture(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(file.path),
      });
      final res = await _dio.put(
        ApiEndpoints.profileMePicture,
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

  /// تحديث صورة الغلاف
  static Future<ApiResponse<Map<String, dynamic>>> updateCoverImage(
    File file,
  ) async {
    try {
      final formData = FormData.fromMap({
        'cover_image': await MultipartFile.fromFile(file.path),
      });
      final res = await _dio.put(
        ApiEndpoints.profileMeCover,
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

  /// إنشاء منشور للملف الشخصي — POST /profile/me/posts (يظهر في الملف فقط)
  static Future<ApiResponse<Map<String, dynamic>>> createProfilePost({
    required String title,
    List<File>? images,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
      });

      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length && i < 10; i++) {
          final f = images[i];
          final name = f.path.split(RegExp(r'[/\\]')).last;

          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(f.path, filename: name),
            ),
          );
        }
      }

      final res = await _dio.post(
        ApiEndpoints.profileMePosts,
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

  /// قفل/فتح الملف — PUT /profile/me/visibility
  static Future<ApiResponse<Map<String, dynamic>>> updateVisibility({
    required bool isProfileLocked,
  }) async {
    try {
      final res = await _dio.put(
        ApiEndpoints.profileMeVisibility,
        data: {'is_profile_locked': isProfileLocked},
      );
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        return ApiResponse(
          status: res.statusCode ?? 200,
          data: raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(
        status: res.statusCode ?? 200,
        data: <String, dynamic>{'data': raw},
        message: null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// بحث المستخدمين — GET /search/users?q=...
  static Future<ApiResponse<Map<String, dynamic>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      return ApiResponse(
        status: 200,
        data: {'users': [], 'data': []},
        message: null,
      );
    }
    try {
      final res = await _dio.get(
        ApiEndpoints.searchUsers,
        queryParameters: {'q': query.trim(), 'page': page, 'limit': limit},
      );
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'users': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final list = raw['users'] ?? raw['data'];
        if (list is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? res.statusCode ?? 200,
            data: {'users': list, 'data': list},
            message: raw['message']?.toString(),
          );
        }
        return ApiResponse(
          status: res.statusCode ?? 200,
          data: raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
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
