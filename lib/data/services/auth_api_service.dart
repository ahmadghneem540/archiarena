import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../../core/constant/const_data.dart';
import '../../core/services/services.dart';

/// نتيجة تسجيل الدخول مع نص الاستجابة الكامل لقراءة حالة التحقق من البريد
class AuthLoginOutcome {
  AuthLoginOutcome({required this.response, required this.rawJson});

  final ApiResponse<Map<String, dynamic>> response;
  final Map<String, dynamic> rawJson;
}

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
    } on dio.DioException catch (e) {
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
        data = dio.FormData.fromMap({
          'company_name': companyName,
          'email': email,
          'phone': phone,
          'password': password,
          'company_foundation': companyFoundation ?? '',
          'license_files': await dio.MultipartFile.fromFile(
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
            ? dio.Options(contentType: 'multipart/form-data')
            : null,
      );
      final raw = res.data as Map<String, dynamic>? ?? {};
      final apiRes = ApiResponse.fromJson(
        raw,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
      // لا نخزّن التوكن هنا — يُستخرج بعد التحقق من البريد مثل تسجيل الفرد
      if (apiRes.isSuccess) {
        await MyServices.saveStringValue(ConstData.keyIsCompany, '1');
      }
      return apiRes;
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  /// التحقق من البريد الإلكتروني
  /// إذا رجع الـ API توكناً يتم تخزينه (تسجيل تلقائي بعد التحقق)
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
      final raw = res.data as Map<String, dynamic>? ?? {};
      final apiRes = ApiResponse.fromJson(
        raw,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
      if (apiRes.isSuccess) {
        final responseData = apiRes.data ?? raw;
        final token = _extractToken(responseData, raw);
        if (token != null && token.isNotEmpty) {
          await MyServices.saveStringValue(ConstData.keyToken, token);
          final user = responseData['user'] ?? raw['user'];
          if (user != null && user['id'] != null) {
            await MyServices.saveStringValue(
              ConstData.keyUserId,
              user['id'].toString(),
            );
          }
          final apiIsCompany = _extractIsCompany(responseData, raw, user);
          if (apiIsCompany != null) {
            await MyServices.saveStringValue(
              ConstData.keyIsCompany,
              apiIsCompany ? '1' : '0',
            );
          }
        }
      }
      return apiRes;
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تسجيل الدخول — identifier يمكن أن يكون البريد أو الهاتف
  static Future<AuthLoginOutcome> login({
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
      if (kDebugMode) {
        debugPrint('┌──────────── AUTH LOGIN RESPONSE ────────────');
        try {
          const encoder = JsonEncoder.withIndent('  ');
          debugPrint(encoder.convert(raw));
        } catch (_) {
          debugPrint(raw.toString());
        }
        debugPrint('└────────────────────────────────────────────');
      }
      final apiRes = ApiResponse.fromJson(
        raw,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );

      if (apiRes.isSuccess) {
        final data = apiRes.data ?? raw;
        final mustVerify = requiresEmailVerificationBeforeAccess(raw, apiRes.data);
        if (!mustVerify) {
          final token = _extractToken(data, raw);
          if (kDebugMode) {
            final masked = (token == null || token.isEmpty)
                ? '(null/empty)'
                : '${token.substring(0, token.length >= 8 ? 8 : token.length)}*** (len=${token.length})';
            debugPrint('AUTH LOGIN token extracted: $masked');
          }
          if (token != null && token.isNotEmpty) {
            await MyServices.saveStringValue(ConstData.keyToken, token);
            if (kDebugMode) {
              final saved = await MyServices.getStringValue(ConstData.keyToken);
              debugPrint(
                'AUTH LOGIN token saved? ${saved != null && saved.isNotEmpty} (len=${saved?.length ?? 0})',
              );
            }
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
        } else {
          final user = data['user'] ?? raw['user'];
          final apiIsCompany = _extractIsCompany(data, raw, user);
          if (apiIsCompany != null) {
            await MyServices.saveStringValue(
              ConstData.keyIsCompany,
              apiIsCompany ? '1' : '0',
            );
          }
        }
      }
      return AuthLoginOutcome(response: apiRes, rawJson: raw);
    } on dio.DioException catch (e) {
      Map<String, dynamic> rawErr = {};
      final d = e.response?.data;
      if (d is Map) {
        rawErr = Map<String, dynamic>.from(d);
      }
      return AuthLoginOutcome(response: _handleError(e), rawJson: rawErr);
    }
  }

  /// يقرأ من استجابة تسجيل الدخول إن كان الحساب شركة (للتوجيه لصفحة التحقق)
  static bool? readIsCompanyFromLoginPayload(Map<String, dynamic> raw) {
    Map<String, dynamic>? data;
    if (raw['data'] is Map) {
      data = Map<String, dynamic>.from(raw['data'] as Map);
    }
    final user = raw['user'] ?? data?['user'];
    return _extractIsCompany(data, raw, user);
  }

  /// البريد المستخدم في شاشة التحقق عند تسجيل الدخول بالهاتف
  static String? emailForVerificationAfterLogin(
    String identifier,
    Map<String, dynamic> rawJson,
    Map<String, dynamic>? innerData,
  ) {
    final id = identifier.trim();
    if (id.contains('@')) return id;
    Map<String, dynamic>? data = innerData;
    if (data == null && rawJson['data'] is Map) {
      data = Map<String, dynamic>.from(rawJson['data'] as Map);
    }
    dynamic user = rawJson['user'];
    if (user == null && data != null) user = data['user'];
    if (user is Map) {
      final e = user['email']?.toString();
      if (e != null && e.isNotEmpty) return e;
    }
    return null;
  }

  /// true إذا كان يجب إجبار المستخدم على إدخال رمز البريد قبل استخدام التطبيق
  static bool requiresEmailVerificationBeforeAccess(
    Map<String, dynamic> rawJson,
    Map<String, dynamic>? innerData,
  ) {
    if (rawJson['requires_email_verification'] == true) return true;
    if (rawJson['must_verify_email'] == true) return true;

    Map<String, dynamic>? data = innerData;
    if (data == null && rawJson['data'] is Map) {
      data = Map<String, dynamic>.from(rawJson['data'] as Map);
    }
    if (data != null) {
      if (data['requires_email_verification'] == true) return true;
      if (data['must_verify_email'] == true) return true;
      if (data['email_verified'] == false) return true;
    }

    dynamic user = rawJson['user'];
    if (user == null && data != null) user = data['user'];
    if (user is Map) {
      final u = Map<String, dynamic>.from(user);
      if (u['email_verified'] == false) return true;
      if (u['is_email_verified'] == false) return true;
      if (u['must_verify_email'] == true) return true;
      if (u.containsKey('email_verified_at')) {
        final ev = u['email_verified_at'];
        if (ev == null) return true;
        if (ev is String && ev.trim().isEmpty) return true;
      }
      if (u['email_verified'] == true) return false;
      if (u['is_email_verified'] == true) return false;
    }

    return false;
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

  static ApiResponse<Map<String, dynamic>> _handleError(dio.DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    String? message;
    // رسالة واضحة عند انتهاء مهلة الاتصال (على الموبايل أو شبكة بطيئة)
    if (e.type == dio.DioExceptionType.receiveTimeout ||
        e.type == dio.DioExceptionType.connectionTimeout ||
        e.type == dio.DioExceptionType.sendTimeout) {
      message = 'error_connection_timeout'.tr;
    }
    if (message == null && data is Map) {
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
    // رسالة واضحة لأخطاء الخادم (503, 502, 500) بدل التفاصيل التقنية
    if (message == null && status >= 500 && status < 600) {
      message = 'error_server_unavailable'.tr;
    }
    message ??= e.message ?? 'حدث خطأ في الاتصال';
    return ApiResponse(
      status: status,
      message: message,
    );
  }

  /// طلب إرسال رمز إعادة تعيين كلمة المرور (نسيان كلمة المرور - الخطوة 1)
  static Future<ApiResponse<Map<String, dynamic>>> requestForgotPassword({
    String? email,
    String? phone,
  }) async {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      return ApiResponse(status: 400, message: 'يرجى إدخال البريد أو رقم الهاتف');
    }
    try {
      final data = <String, dynamic>{};
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;

      final res = await _dio.post(
        ApiEndpoints.authForgotPassword,
        data: data,
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  /// إعادة تعيين كلمة المرور (نسيان كلمة المرور - الخطوة 2)
  static Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    String? email,
    String? phone,
    required String code,
    required String newPassword,
  }) async {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      return ApiResponse(status: 400, message: 'يرجى إدخال البريد أو رقم الهاتف');
    }
    try {
      final data = <String, dynamic>{
        'code': code,
        'new_password': newPassword,
      };
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;

      final res = await _dio.post(
        ApiEndpoints.authResetPassword,
        data: data,
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تغيير كلمة المرور (للمستخدم المسجّل دخوله)
  static Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.authChangePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      debugPrint('[ChangePassword] DioException: ${e.type}');
      debugPrint('[ChangePassword] Status: ${e.response?.statusCode}');
      debugPrint('[ChangePassword] Response: ${e.response?.data}');
      debugPrint('[ChangePassword] Message: ${e.message}');
      return _handleError(e);
    }
  }

  /// تسجيل الخروج (استدعاء API ثم مسح التوكن محلياً)
  static Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.authLogout);
    } on dio.DioException catch (_) {
      // حتى لو فشل الطلب (شبكة أو 401) نكمل مسح البيانات محلياً
    }
    await MyServices.saveStringValue(ConstData.keyToken, '');
    await MyServices.saveStringValue(ConstData.keyUserId, '');
    await MyServices.saveStringValue(ConstData.keyIsCompany, '0');
    ApiClient.reset();
  }

  /// حذف الحساب
  static Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    try {
      final res = await _dio.delete(ApiEndpoints.authDeleteAccount);
      final raw = res.data as Map<String, dynamic>? ?? {};
      return ApiResponse.fromJson(
        raw,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }
}
