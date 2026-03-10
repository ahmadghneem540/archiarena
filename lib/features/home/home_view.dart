import 'package:archiarena/features/home/widgets/upload_project.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'home_controller.dart';
import 'widgets/friends_tab_view.dart';
import 'widgets/home_header.dart';
import 'widgets/home_post_card_1.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/menu_tab_view.dart';
import 'widgets/notifications_tab_view.dart';
import 'widgets/orders_tab_view.dart';
import 'widgets/profile_tab_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              HomeHeader(controller: controller),
              Expanded(
                child: Stack(
                  children: [
                    Obx(() {
                      // المحتوى الأساسي حسب التبويب
                      if (controller.currentTab.value == HomeTab.work) {
                        return Obx(() {
                          final posts = controller.posts;
                          if (posts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.work_outline,
                                      size: 64, color: AppColors.grey400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'no_posts'.tr,
                                    style: TextStyle(
                                        fontSize: 16, color: AppColors.grey600),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return HomePostCard1(
                                controller: controller,
                                post: posts[index],
                              );
                            },
                          );
                        });
                      }
                      if (controller.currentTab.value == HomeTab.orders) {
                        return OrdersTabView(controller: controller);
                      }
                      if (controller.currentTab.value == HomeTab.groups) {
                        return ListView(
                          children: [FriendsTabView(controller: controller)],
                        );
                      }
                      if (controller.currentTab.value == HomeTab.profile) {
                        return ListView(
                          children: [ProfileTabView(controller: controller)],
                        );
                      }
                      if (controller.currentTab.value ==
                          HomeTab.notifications) {
                        return ListView(
                          children: [
                            NotificationsTabView(controller: controller),
                          ],
                        );
                      }
                      if (controller.currentTab.value == HomeTab.menu) {
                        return ListView(
                          children: [MenuTabView(controller: controller)],
                        );
                      }
                      return Column(
                        children: [
                          HomeSearchBar(controller: controller),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Obx(() {
                              final posts = controller.posts;
                              if (posts.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.feed_outlined, size: 64, color: AppColors.grey400),
                                      const SizedBox(height: 16),
                                      Text(
                                        'no_posts'.tr,
                                        style: TextStyle(fontSize: 16, color: AppColors.grey600),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  return HomePostCard1(
                                    controller: controller,
                                    post: posts[index],
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      );
                    }),
                    Obx(() {
                      // صفحة رفع المشروع تظهر فوق المحتوى
                      if (controller.showUploadPage.value) {
                        return Positioned.fill(
                          child: Material(
                            color: Colors.white,
                            child: Column(
                              children: [
                                // زر رجوع
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: AppColors.surface,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          controller.closeUploadPage();
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'رفع المشروع',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(child: UploadProjectPage()),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
