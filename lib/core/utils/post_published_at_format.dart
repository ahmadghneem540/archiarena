import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// تنسيق تاريخ ووقت نشر المنشور في الخلاصة (يُفك ISO8601 ويُعرض بالتوقيت المحلي).
String formatPostPublishedAt(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final s = raw.trim();
  final dt = DateTime.tryParse(s);
  if (dt == null) return s;
  final local = dt.toLocal();
  final code = Get.locale?.languageCode ??
      Get.deviceLocale?.languageCode ??
      'ar';
  try {
    return DateFormat('yyyy/MM/dd HH:mm', code).format(local);
  } catch (_) {
    return DateFormat('yyyy-MM-dd HH:mm').format(local);
  }
}
