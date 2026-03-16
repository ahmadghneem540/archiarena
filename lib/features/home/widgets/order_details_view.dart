import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../models/project_image_model.dart';

/// صفحة تفاصيل الطلب مع GridView للصور
class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({
    super.key,
    required this.controller,
    required this.orderId,
    required this.orderTitle,
  });

  final HomeController controller;
  final String orderId;
  final String orderTitle;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              Text(orderTitle),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  orderTitle.isNotEmpty ? orderTitle[0] : '؟',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isDownloadingOrderImages.value
                      ? null
                      : () => controller.downloadAllImages(orderId),
                  icon: controller.isDownloadingOrderImages.value
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: Text(
                    controller.isDownloadingOrderImages.value ? 'downloading'.tr : 'download_all'.tr,
                  ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              )),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isOrderProposalsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final images = controller.getOrderImages(orderId);
          if (images.isEmpty) {
            return Center(
              child: Text(
                'no_proposals_on_order'.tr,
                style: TextStyle(color: AppColors.grey600),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return _buildImageCard(image, orderId);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildImageCard(ProjectImageModel image, String orderId) {
    return Obx(() {
      final isAccepted = image.isAccepted.value;
      final isRejected = image.isRejected.value;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted 
              ? AppColors.primary 
              : isRejected 
                  ? AppColors.error 
                  : AppColors.border,
          width: isAccepted || isRejected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // معلومات المستخدم
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    image.authorName.isNotEmpty ? image.authorName[0] : '؟',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.authorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        image.timeAgo,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // الصورة
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  child: ColorFiltered(
                    colorFilter: isRejected
                        ? ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.5),
                            BlendMode.darken,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.color,
                          ),
                    child: (image.imageUrl.startsWith('http'))
                        ? Image.network(
                            image.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.placeholder1,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.grey400,
                                  size: 32,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            image.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.placeholder1,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.grey400,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                if (isRejected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: AppColors.error,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // زر القبول/الرفض
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: isAccepted || isRejected
                    ? null
                    : () => controller.acceptImage(orderId, image.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAccepted
                      ? AppColors.primary
                      : isRejected
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: isAccepted
                      ? AppColors.onPrimary
                      : isRejected
                          ? AppColors.error
                          : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAccepted
                      ? 'accepted'.tr
                      : isRejected
                          ? 'rejected'.tr
                          : 'accept_offer'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    });
  }
}
