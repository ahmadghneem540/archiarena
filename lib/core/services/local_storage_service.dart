import 'package:hive/hive.dart';
import '../../features/home/models/local_project_image_model.dart';

class LocalStorageService {

  static final box =
  Hive.box<LocalProjectImageModel>('project_images');

  static Future<void> saveProjectImage(
      LocalProjectImageModel image,
      ) async {
    await box.put(image.id, image);
  }

  static List<LocalProjectImageModel> getOrderImages(
      String orderId,
      ) {
    return box.values
        .where((e) => e.orderId == orderId)
        .toList();
  }

  static Future<void> clearOrder(String orderId) async {
    final items = box.values
        .where((e) => e.orderId == orderId)
        .toList();

    for (final item in items) {
      await item.delete();
    }
  }
}