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
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logError(error);
          if (error.response?.statusCode == 401) {
            await MyServices.saveStringValue(ConstData.keyToken, '');
          }
          return handler.next(error);
        },
      ),
    );

    return client;
  }

  static void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    final uri = options.uri.toString();
    final method = options.method;
    debugPrint('┌─────────────── API REQUEST ───────────────');
    debugPrint('│ $method $uri');
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
