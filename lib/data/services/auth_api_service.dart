import 'dart:io';

import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../../core/constant/const_data.dart';
import '../../core/services/services.dart';

class AuthApiService {
  AuthApiService._();

  static final _dio = ApiClient.dio;

  /// تسجيل عميل (فرد)
  static Future<ApiResponse<Map<String, dynamic>>> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? customerBirth,
    String? gender,
    String? descriptionType,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.authRegisterCustomer,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          if (customerBirth != null) 'customer_birth': customerBirth,
          if (gender != null) 'gender': gender,
          if (descriptionType != null) 'description_type': descriptionType,
        },
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تسجيل شركة
  static Future<ApiResponse<Map<String, dynamic>>> registerCompany({
    required String companyName,
    required String email,
    required String phone,
    required String password,
    String? companyFoundation,
    File? licenseFile,
  }) async {
    try {
      dynamic data;
      if (licenseFile != null) {
        data = FormData.fromMap({
          'company_name': companyName,
          'email': email,
          'phone': phone,
          'password': password,
          'company_foundation': companyFoundation ?? '',
          'license_files': await MultipartFile.fromFile(
            licenseFile.path,
            filename: licenseFile.path.split(RegExp(r'[/\\]')).last,
          ),
        });
      } else {
        data = {
          'company_name': companyName,
          'email': email,
          'phone': phone,
          'password': password,
          'company_foundation': companyFoundation ?? '',
          'license_files': '',
        };
      }

      final res = await _dio.post(
        ApiEndpoints.authRegisterCompany,
        data: data,
        options: licenseFile != null
            ? Options(contentType: 'multipart/form-data')
            : null,
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// التحقق من البريد الإلكتروني
  static Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.authVerifyEmail,
        data: {
          'email': email,
          'code': code,
        },
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تسجيل الدخول — identifier يمكن أن يكون البريد أو الهاتف
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.authLogin,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );
      final raw = res.data as Map<String, dynamic>? ?? {};
      final apiRes = ApiResponse.fromJson(
        raw,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );

      if (apiRes.isSuccess) {
        final data = apiRes.data ?? raw;
        final token = _extractToken(data, raw);
        if (token != null && token.isNotEmpty) {
          await MyServices.saveStringValue(ConstData.keyToken, token);
          final user = data['user'] ?? raw['user'];
          if (user != null && user['id'] != null) {
            await MyServices.saveStringValue(
              ConstData.keyUserId,
              user['id'].toString(),
            );
          }
          final apiIsCompany = _extractIsCompany(data, raw, user);
          if (apiIsCompany != null) {
            await MyServices.saveStringValue(
              ConstData.keyIsCompany,
              apiIsCompany ? '1' : '0',
            );
          }
        }
      }
      return apiRes;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// يرجع true للشركة، false للأفراد، null عندما لا يُرجع الـ API القيمة
  static bool? _extractIsCompany(
    Map<String, dynamic>? data,
    Map<String, dynamic>? raw,
    dynamic user,
  ) {
    final u = user is Map ? Map<String, dynamic>.from(user) : null;
    if (u != null) {
      if (u['is_company'] == true) return true;
      if (u['is_company'] == false) return false;
      if (u['user_type']?.toString().toLowerCase() == 'company') return true;
      if (u['user_type']?.toString().toLowerCase() == 'customer') return false;
      if (u['type']?.toString().toLowerCase() == 'company') return true;
      if (u['account_type']?.toString().toLowerCase() == 'company') return true;
      if (u['role']?.toString().toLowerCase() == 'company') return true;
    }
    if (data != null && data['is_company'] == true) return true;
    if (data != null && data['is_company'] == false) return false;
    if (raw != null && raw['is_company'] == true) return true;
    if (raw != null && raw['is_company'] == false) return false;
    return null;
  }

  static String? _extractToken(Map<String, dynamic>? data, Map<String, dynamic>? raw) {
    final fromData = data?['token'] ?? data?['access_token'] ?? data?['accessToken'];
    if (fromData != null && fromData.toString().isNotEmpty) return fromData.toString();
    final fromRaw = raw?['token'] ?? raw?['access_token'] ?? raw?['accessToken'];
    if (fromRaw != null && fromRaw.toString().isNotEmpty) return fromRaw.toString();
    return null;
  }

  static ApiResponse<Map<String, dynamic>> _handleError(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    String? message;
    if (data is Map) {
      message = data['message']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString();
      if (message == null && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        message = errors['email']?.toString();
        if (message == null && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          } else {
            message = first.toString();
          }
        }
      }
    }
    message ??= e.message ?? 'حدث خطأ في الاتصال';
    return ApiResponse(
      status: status,
      message: message,
    );
  }

  /// تسجيل الخروج (مسح التوكن محلياً)
  static Future<void> logout() async {
    await MyServices.saveStringValue(ConstData.keyToken, '');
    await MyServices.saveStringValue(ConstData.keyUserId, '');
    await MyServices.saveStringValue(ConstData.keyIsCompany, '0');
    ApiClient.reset();
  }
}
