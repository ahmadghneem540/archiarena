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

  /// تحديث الملف الشخصي
  static Future<ApiResponse<Map<String, dynamic>>> updateProfile({
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
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
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
