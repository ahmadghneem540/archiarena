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
      final raw = res.data;
      // إذا كان الـ API يرجع قائمة مباشرة
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'posts': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        // إذا كان الحقل data داخل الـ Map هو قائمة (المنشورات)
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'posts': data, 'data': data},
            message: raw['message'] as String?,
          );
        }
        return ApiResponse.fromJson(
          raw,
          fromJsonT: (d) => d as Map<String, dynamic>,
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getDashboardPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.dashboardPosts,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'orders': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'orders': data, 'data': data},
            message: raw['message'] as String?,
          );
        }
        return ApiResponse.fromJson(
          raw,
          fromJsonT: (d) => d as Map<String, dynamic>,
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// رفع مشروع إلى قسم الطلبات — POST /home/company/posts
  /// يُستخدم من زر "رفع المشروع" للمستخدمين العاديين والشركات (نفس المسار للجميع).
  /// يظهر في واجهة الطلبات. الحقول المطلوبة: title, category, description. الصور اختيارية.
  /// الباكند يجب أن يقبل الطلب من أي حساب (شخصي أو شركة) مرتبط بالتوكن.
  static Future<ApiResponse<Map<String, dynamic>>> createCompanyPost({
    required String title,
    required String category,
    required String description,
    String? area,
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
        if (area != null && area.isNotEmpty) 'area': area,
        if (style != null && style.isNotEmpty) 'style': style,
        if (budget != null && budget.isNotEmpty) 'budget': budget,
        if (deadline != null && deadline.isNotEmpty) 'deadline': deadline,
      };
      final formData = FormData.fromMap(map);
      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length && i < 10; i++) {
          final f = images[i];
          final name = f.path.split(RegExp(r'[/\\]')).last;
          final multipart = await MultipartFile.fromFile(f.path, filename: name);
          if (i == 0) {
            formData.files.add(MapEntry('image', multipart));
          } else {
            formData.files.add(MapEntry('images[]', multipart));
          }
        }
      }
      final res = await _dio.post(
        ApiEndpoints.companyCreatePost,
        data: formData,
      );
      return ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// جلب الطلبات — GET /home/orders
  static Future<ApiResponse<Map<String, dynamic>>> getHomeOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.homeOrders,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'orders': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'orders': data, 'data': data},
            message: raw['message'] as String?,
          );
        }
        return ApiResponse.fromJson(
          raw,
          fromJsonT: (d) => d as Map<String, dynamic>,
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// قائمة العروض على طلب — GET /home/orders/:orderId/proposals
  static Future<ApiResponse<Map<String, dynamic>>> getOrderProposals(
    int orderId,
  ) async {
    try {
      final res = await _dio.get(ApiEndpoints.homeOrderProposals(orderId));
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        final list = data is List ? data : null;
        return ApiResponse(
          status: raw['status'] as int? ?? 200,
          data: {
            'proposals': list ?? [],
            'data': list ?? [],
            'order': raw['order'],
          },
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// تقديم عرض على طلب — POST /home/orders/:orderId/proposals (message، image)
  static Future<ApiResponse<Map<String, dynamic>>> submitProposal(
    int orderId, {
    String? message,
    File? image,
  }) async {
    if ((message == null || message.isEmpty) && image == null) {
      return ApiResponse(
        status: 400,
        message: 'يجب إرسال رسالة أو صورة على الأقل',
      );
    }
    try {
      final map = <String, dynamic>{};
      if (message != null && message.isNotEmpty) map['message'] = message;
      if (image != null) {
        map['image'] = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(RegExp(r'[/\\]')).last,
        );
      }
      final formData = FormData.fromMap(map);
      final res = await _dio.post(
        ApiEndpoints.homeOrderSubmitProposal(orderId),
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        return ApiResponse(
          status: raw['status'] as int? ?? res.statusCode ?? 200,
          data: raw['data'] ?? raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(
        status: res.statusCode ?? 200,
        data: <String, dynamic>{},
        message: null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// قبول عرض (ورفض الباقي) — POST /home/orders/:orderId/proposals/:proposalId/accept
  static Future<ApiResponse<Map<String, dynamic>>> acceptProposal(
    int orderId,
    int proposalId,
  ) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.homeOrderAcceptProposal(orderId, proposalId),
      );
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        return ApiResponse(
          status: raw['status'] as int? ?? res.statusCode ?? 200,
          data: raw['data'] ?? raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(
        status: res.statusCode ?? 200,
        data: <String, dynamic>{},
        message: null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getPost(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.homePosts(id));
      final raw = res.data;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
      }
      final data = raw['data'] ?? raw['post'] ?? raw;
      if (data is! Map) {
        return ApiResponse(
          status: res.statusCode ?? 200,
          data: raw,
          message: raw['message']?.toString(),
        );
      }
      return ApiResponse(
        status: raw['status'] as int? ?? res.statusCode ?? 200,
        data: Map<String, dynamic>.from(data),
        message: raw['message']?.toString(),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// نشر منشور في آخر الأخبار — POST /home/posts (قسم الشركات، زر "بماذا تفكر").
  /// يدعم رفع صور وملف PDF (مخطط المشروع).
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
    int? timerDays,
    int? timerHours,
    List<File>? images,
    File? planPdf,
  }) async {
    try {
      final map = <String, dynamic>{
        'title': title,
        'category': category,
        'description': description,
        if (designDetails != null && designDetails.isNotEmpty)
          'design_details': designDetails,
        if (projectTypes != null && projectTypes.isNotEmpty)
          'project_types': projectTypes,
        if (area != null && area.isNotEmpty) 'area': area,
        if (planStatus != null && planStatus.isNotEmpty)
          'plan_status': planStatus,
        if (suitableFor != null && suitableFor.isNotEmpty)
          'suitable_for': suitableFor,
        if (style != null && style.isNotEmpty) 'style': style,
        if (budget != null && budget.isNotEmpty) 'budget': budget,
        if (timerDays != null && timerDays >= 0) 'timer_days': timerDays,
        if (timerHours != null && timerHours >= 0) 'timer_hours': timerHours,
        if (timerDays != null || timerHours != null) 'timer_minutes': 0,
      };

      final formData = FormData.fromMap(map);

      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length && i < 10; i++) {
          final f = images[i];
          final name = f.path.split(RegExp(r'[/\\]')).last;
          final multipart = await MultipartFile.fromFile(f.path, filename: name);
          if (i == 0) {
            formData.files.add(MapEntry('image', multipart));
          } else {
            formData.files.add(MapEntry('images[]', multipart));
          }
        }
      }

      if (planPdf != null) {
        final name = planPdf.path.split(RegExp(r'[/\\]')).last;
        formData.files.add(
          MapEntry(
            'plan_file',
            await MultipartFile.fromFile(planPdf.path, filename: name),
          ),
        );
      }

      final res = await _dio.post(
        ApiEndpoints.homePosts(),
        data: formData,
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
  static Future<ApiResponse<Map<String, dynamic>>> toggleLike(
    int postId,
  ) async {
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

  /// جلب التعليقات — كل تعليق: id، comment_id، author: { user_id, name, profile_picture }، body، text، image_url، audio_url، parent_id، replies
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
      final raw = res.data;
      if (raw is List) {
        return ApiResponse(
          status: 200,
          data: {'comments': raw, 'data': raw},
          message: null,
        );
      }
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return ApiResponse(
            status: raw['status'] as int? ?? 200,
            data: {'comments': data, 'data': data},
            message: raw['message'] as String?,
          );
        }
        return ApiResponse.fromJson(
          raw,
          fromJsonT: (d) => d as Map<String, dynamic>,
        );
      }
      return ApiResponse(status: 0, message: 'صيغة استجابة غير متوقعة');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// إضافة تعليق — POST /home/posts/:id/comments
  static Future<ApiResponse<Map<String, dynamic>>> addComment(
    int postId, {
    String? body,
    File? image,
    File? audio,
    String? audioPath,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (body != null && body.isNotEmpty) map['body'] = body;
      if (image != null) {
        map['image'] = await MultipartFile.fromFile(image.path);
      }
      if (audio != null) {
        map['audio'] = await MultipartFile.fromFile(audio.path);
      } else if (audioPath != null && audioPath.isNotEmpty) {
        map['audio'] = await MultipartFile.fromFile(audioPath);
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

  /// رد على تعليق — POST /home/comments/:id/reply
  static Future<ApiResponse<Map<String, dynamic>>> replyComment(
    int commentId, {
    String? body,
    File? image,
    File? audio,
    String? audioPath,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (body != null && body.isNotEmpty) map['body'] = body;
      if (image != null) {
        map['image'] = await MultipartFile.fromFile(image.path);
      }
      if (audio != null) {
        map['audio'] = await MultipartFile.fromFile(audio.path);
      } else if (audioPath != null && audioPath.isNotEmpty) {
        map['audio'] = await MultipartFile.fromFile(audioPath);
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

  // ========== الأعمال (Works) ==========

  /// جلب أعمال المستخدم — GET /home/works
  static Future<ApiResponse<Map<String, dynamic>>> getWorks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.homeWorks,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = res.data;
      List? list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['posts'] is List) {
          list = data['posts'] as List;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else if (raw['posts'] is List) {
          list = raw['posts'] as List;
        } else if (raw['works'] is List) {
          list = raw['works'] as List;
        }
      }
      if (list != null) {
        return ApiResponse(
          status: raw is Map ? (raw['status'] as int? ?? 200) : 200,
          data: {
            'data': list,
            'posts': list,
            if (raw is Map && raw['pagination'] != null) 'pagination': raw['pagination'],
          },
          message: raw is Map ? raw['message']?.toString() : null,
        );
      }
      if (raw is Map<String, dynamic>) {
        return ApiResponse.fromJson(
          raw,
          fromJsonT: (d) => d as Map<String, dynamic>,
        );
      }
      return ApiResponse(status: 0, data: {'data': [], 'posts': []}, message: 'صيغة استجابة غير متوقعة');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// إضافة منشور إلى الأعمال — POST /home/works
  static Future<ApiResponse<Map<String, dynamic>>> addPostToWorks(
    int postId,
  ) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.homeWorksAdd,
        data: {'post_id': postId},
        options: Options(contentType: Headers.jsonContentType),
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
        data: <String, dynamic>{},
        message: null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// حذف منشور من الأعمال — DELETE /home/works/:postId
  static Future<ApiResponse<Map<String, dynamic>>> deletePostFromWorks(
    int postId,
  ) async {
    try {
      final res = await _dio.delete(ApiEndpoints.homeWorksDelete(postId));
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
        data: <String, dynamic>{},
        message: null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponse<Map<String, dynamic>> _handleError(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    String? message;
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = 'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى.';
    }
    if (message == null && data is Map) {
      message = data['message']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString();
    }
    if (message == null || message.isEmpty) {
      if (status >= 500 && status < 600) {
        message = 'خطأ من الخادم. حاول مرة أخرى لاحقاً.';
      } else {
        message = e.message ?? 'حدث خطأ في الاتصال';
      }
    }
    return ApiResponse(status: status, message: message);
  }
}
