import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../models/order_model.dart';

/// شاشة الطلبات - للمشاريع المرفوعة (للشركات فقط)
class OrdersTabView extends StatelessWidget {
  const OrdersTabView({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders_title'.tr,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المشاريع المرفوعة:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
              Obx(() {
                if (controller.orders.isEmpty) return const SizedBox.shrink();
                return TextButton.icon(
                  onPressed: controller.isDownloadingOrders.value
                      ? null
                      : () => controller.downloadAllOrdersAndImages(),
                  icon: controller.isDownloadingOrders.value
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.download, size: 20, color: AppColors.primary),
                  label: Text(
                    controller.isDownloadingOrders.value ? 'downloading'.tr : 'download_all'.tr,
                    style: TextStyle(color: AppColors.primary),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_orders_uploaded'.tr,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(
                controller.orders.length,
                (index) {
                  final order = controller.orders[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < controller.orders.length - 1 ? 12 : 0,
                    ),
                    child: _buildOrderCard(order),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final imageUrl = order.imageUrl;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // صورة المشروع
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.placeholder1,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.grey400,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.placeholder1,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // معلومات المشروع
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.timeAgo,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // زر العرض
            SizedBox(
              width: 80,
              height: 40,
              child: Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.openOrderDetails(order.id, order.title);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'view'.tr,
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
