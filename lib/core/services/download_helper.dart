import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/const_data.dart';
import 'services.dart';
import 'package:path_provider/path_provider.dart';


/// تحميل الملفات محلياً (طلبات، صور، مخططات)
class DownloadHelper {
  DownloadHelper._();

  static final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(seconds: 45),
      followRedirects: true,
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  /// مجلد التحميلات الأساسي
  static Future<Directory> get downloadsDir async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/archarena_downloads');
    if (!await downloadDir.exists()) await downloadDir.create(recursive: true);
    return downloadDir;
  }

  static Future<Map<String, dynamic>?> _bearerHeaders() async {
    final token = await MyServices.getStringValue(ConstData.keyToken);
    if (token == null || token.isEmpty) return null;
    return <String, dynamic>{
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
  }

  /// تحميل ملف من رابط وحفظه محلياً. يرجع مسار الملف المحلي أو null عند الفشل.
  static Future<String?> downloadFile(
    String url,
    String localPath, {
    Map<String, dynamic>? headers,
  }) async {
    if (url.isEmpty) return null;
    try {
      final dir = await downloadsDir;
      final fullPath = '${dir.path}/$localPath';
      final file = File(fullPath);
      final parent = file.parent;
      if (!await parent.exists()) await parent.create(recursive: true);

      final res = await _dio.download(
        url,
        fullPath,
        options: Options(headers: headers),
      );
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        try {
          await file.delete();
        } catch (_) {}
        if (kDebugMode) {
          debugPrint('[DownloadHelper] HTTP $code for $url');
        }
        return null;
      }

      final fixed = await _ensurePdfExtensionIfNeeded(fullPath);
      return fixed;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[DownloadHelper] download failed: $e\n$st');
      }
      return null;
    }
  }

  /// إن كان المحتوى PDF والامتداد خاطئ (مثل .jpg) يُعاد تسمية الملف.
  static Future<String> _ensurePdfExtensionIfNeeded(String fullPath) async {
    if (!await _fileStartsWithPdfMagic(fullPath)) return fullPath;
    final lower = fullPath.toLowerCase();
    if (lower.endsWith('.pdf')) return fullPath;
    final dot = fullPath.lastIndexOf('.');
    final base = dot > 0 ? fullPath.substring(0, dot) : fullPath;
    final pdfPath = '$base.pdf';
    try {
      await File(fullPath).rename(pdfPath);
      return pdfPath;
    } catch (_) {
      return fullPath;
    }
  }

  static Future<bool> _fileStartsWithPdfMagic(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return false;
      final len = await f.length();
      if (len < 4) return false;
      final b = await f.openRead(0, 5).first;
      if (b.length < 4) return false;
      return b[0] == 0x25 &&
          b[1] == 0x50 &&
          b[2] == 0x44 &&
          b[3] == 0x46; // %PDF
    } catch (_) {
      return false;
    }
  }

  static String _extensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      if (path.endsWith('.pdf')) return '.pdf';
      if (path.endsWith('.png')) return '.png';
      if (path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.jfif')) {
        return '.jpg';
      }
      if (path.endsWith('.webp')) return '.webp';
    } catch (_) {}
    return '.jpg';
  }

  /// تحميل صورة أو مخطط PDF من رابط — يُحدد الامتداد من الرابط ثم يصححه إن كان الملف PDF.
  /// يمرّر [Authorization] تلقائياً إن وُجد توكن (مطلوب لروابط التخزين المحمية).
  /// basePath مثل orders/29/proposal_0 (بدون امتداد)
  static Future<String?> downloadImage(String url, String basePath) async {
    final ext = _extensionFromUrl(url);
    final name = basePath.endsWith(ext) ? basePath : '$basePath$ext';
    final headers = await _bearerHeaders();
    return downloadFile(url, name, headers: headers);
  }

  /// تحميل ملف PDF فقط — المسار المحلي ينتهي بـ `.pdf` حتى لا يُحفظ كصورة (.jpg).
  /// [basePathWithoutExt] مثل `plans/12/plan_file` (دون امتداد).
  static Future<String?> downloadPdfFile(
    String url,
    String basePathWithoutExt,
  ) async {
    if (url.isEmpty) return null;
    final trimmed = basePathWithoutExt.trim();
    final base = trimmed.toLowerCase().endsWith('.pdf')
        ? trimmed.substring(0, trimmed.length - 4)
        : trimmed;
    final name = '$base.pdf';
    final headers = await _bearerHeaders();
    return downloadFile(url, name, headers: headers);
  }
///تخزين الصور في المعرض
  static Future<bool> downloadImageToGallery(
      String imageUrl,
      String fileName,
      ) async {
    try {
      // طلب الصلاحيات
      if (Platform.isAndroid) {
        await Permission.storage.request();
        await Permission.photos.request();
      }

      // تحميل الصورة مباشرة
      await FileDownloader.downloadFile(
        url: imageUrl,
        name: '$fileName.jpg',
        onDownloadCompleted: (path) {
          print('Image downloaded to: $path');
        },
        onDownloadError: (errorMessage) {
          print('Download error: $errorMessage');
        },
      );

      return true;
    } catch (e) {
      print('Download error: $e');
      return false;
    }
  }
}
