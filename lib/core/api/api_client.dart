import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constant/const_data.dart';
import '../services/services.dart';

class ApiClient {
  ApiClient._();

  static Dio? _dio;
  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final options = BaseOptions(
      baseUrl: ConstData.API_BASE,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final client = Dio(options);

    // طباعة كل الطلبات والاستجابات في الكونسول
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await MyServices.getStringValue(ConstData.keyToken);
          final storageHasToken = token != null && token.isNotEmpty;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final headerHasAuth = (options.headers['Authorization']?.toString().isNotEmpty ?? false);
          _logRequest(
            options,
            storageHasToken: storageHasToken,
            headerHasAuth: headerHasAuth,
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logError(error);
          return handler.next(error);
        },
      ),
    );

    return client;
  }

  static void _logRequest(
    RequestOptions options, {
    bool storageHasToken = false,
    bool headerHasAuth = false,
  }) {
    if (!kDebugMode) return;
    final uri = options.uri.toString();
    final method = options.method;
    debugPrint('┌─────────────── API REQUEST ───────────────');
    debugPrint('│ $method $uri');
    debugPrint(
      '│ Authorization: ${headerHasAuth ? 'Bearer ***' : '(غير مرسل)'} | storageToken: ${storageHasToken ? 'موجود' : 'غير موجود'}',
    );
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      if (options.data is Map || options.data is List) {
        debugPrint('│ Body: ${options.data}');
      } else {
        debugPrint('│ Body: [${options.data.runtimeType}]');
      }
    }
    debugPrint('└──────────────────────────────────────────');
  }

  static void _logResponse(Response response) {
    if (!kDebugMode) return;
    final status = response.statusCode ?? 0;
    final uri = response.requestOptions.uri.toString();
    debugPrint('┌─────────────── API RESPONSE ──────────────');
    debugPrint('│ $status ${response.requestOptions.method} $uri');
    try {
      final data = response.data;
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        debugPrint('│ ${encoder.convert(data)}');
      } else {
        debugPrint('│ $data');
      }
    } catch (_) {
      debugPrint('│ ${response.data}');
    }
    debugPrint('└──────────────────────────────────────────');
  }

  static void _logError(DioException error) {
    if (!kDebugMode) return;
    final uri = error.requestOptions.uri.toString();
    final status = error.response?.statusCode ?? '—';
    debugPrint('┌─────────────── API ERROR ──────────────────');
    debugPrint('│ $status ${error.requestOptions.method} $uri');
    debugPrint('│ Message: ${error.message}');
    if (error.response?.data != null) {
      try {
        final data = error.response!.data;
        if (data is Map || data is List) {
          const encoder = JsonEncoder.withIndent('  ');
          debugPrint('│ Body: ${encoder.convert(data)}');
        } else {
          debugPrint('│ Body: $data');
        }
      } catch (_) {
        debugPrint('│ Body: ${error.response?.data}');
      }
    }
    debugPrint('└──────────────────────────────────────────');
  }

  /// إعادة تهيئة العميل (مثلاً بعد تغيير التوكن)
  static void reset() {
    _dio = null;
  }
}
