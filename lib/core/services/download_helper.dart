import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// تحميل الملفات محلياً (طلبات، صور، مخططات)
class DownloadHelper {
  DownloadHelper._();

  static final _dio = Dio();

  /// مجلد التحميلات الأساسي
  static Future<Directory> get downloadsDir async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/archiarena_downloads');
    if (!await downloadDir.exists()) await downloadDir.create(recursive: true);
    return downloadDir;
  }

  /// تحميل ملف من رابط وحفظه محلياً. يرجع مسار الملف المحلي أو null عند الفشل.
  /// localPath يمكن أن يحتوي مجلدات فرعية مثل orders/29/proposal_0
  static Future<String?> downloadFile(String url, String localPath) async {
    if (url.isEmpty) return null;
    try {
      final dir = await downloadsDir;
      final fullPath = '${dir.path}/$localPath';
      final file = File(fullPath);
      final parent = file.parent;
      if (!await parent.exists()) await parent.create(recursive: true);
      await _dio.download(url, fullPath);
      return fullPath;
    } catch (_) {
      return null;
    }
  }

  /// تحميل صورة من رابط — يُحدد الامتداد من الرابط أو يستخدم .jpg
  /// basePath مثل orders/29/proposal_0 (بدون امتداد)
  static Future<String?> downloadImage(String url, String basePath) async {
    String ext = '.jpg';
    try {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last.toLowerCase();
        if (last.endsWith('.png')) ext = '.png';
        else if (last.endsWith('.jpeg') || last.endsWith('.jfif')) ext = '.jpg';
        else if (last.endsWith('.webp')) ext = '.webp';
      }
    } catch (_) {}
    final name = basePath.endsWith(ext) ? basePath : '$basePath$ext';
    return downloadFile(url, name);
  }
}
