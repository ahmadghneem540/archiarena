import 'package:dio/dio.dart';
import '../constant/const_data.dart';
import '../services/services.dart';

/// عميل HTTP موحد لجميع طلبات الـ API
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

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await MyServices.getStringValue(ConstData.keyToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await MyServices.saveStringValue(ConstData.keyToken, '');
            // يمكن إضافة إعادة توجيه لتسجيل الدخول هنا
          }
          return handler.next(error);
        },
      ),
    );

    return client;
  }

  /// إعادة تهيئة العميل (مثلاً بعد تغيير التوكن)
  static void reset() {
    _dio = null;
  }
}
