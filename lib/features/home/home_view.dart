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
import 'widgets/shimmer_loading.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        body: SafeArea(
          child: Column(
            children: [
              HomeHeader(controller: controller),
              Expanded(
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.currentTab.value == HomeTab.work) {
                        return Obx(() {
                          if (controller.isWorksLoading.value) {
                            return buildShimmerPostList(4);
                          }

                          final posts = controller.worksPosts;

                          if (posts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.work_outline,
                                      size: 64,
                                      color: context.themeGrey600),
                                  const SizedBox(height: 16),
                                  Text(
                                    'no_posts'.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: context.themeGrey600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return RepaintBoundary(
                                child: HomePostCard1(
                                  controller: controller,
                                  post: posts[index],
                                  isInWorks: true,
                                ),
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
                            child: RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: () async {
                                await controller.loadPosts(force: true);
                                await controller.loadChatUnreadMessageCount();
                              },
                              child: Obx(() {
                                if (controller.isPostsLoading.value) {
                                  return ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 24),
                                    children: [
                                      for (var i = 0; i < 4; i++)
                                        const Padding(
                                          padding: EdgeInsets.only(bottom: 16),
                                          child: ShimmerPostCard(),
                                        ),
                                    ],
                                  );
                                }

                                final posts = controller.mainFeedPosts;

                                if (posts.isEmpty) {
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        children: [
                                          SizedBox(
                                            height: constraints.maxHeight > 200
                                                ? constraints.maxHeight * 0.25
                                                : 80,
                                          ),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.feed_outlined,
                                                  size: 64,
                                                  color: context.themeGrey600,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'no_posts'.tr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        context.themeGrey600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    return RepaintBoundary(
                                      child: HomePostCard1(
                                        controller: controller,
                                        post: posts[index],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    }),

                    /// صفحة رفع المشروع
                    Obx(() {
                      if (controller.showUploadPage.value) {
                        return Positioned.fill(
                          child: Material(
                            color: context.themeSurface,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: context.themeSurface,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: context.themeOnSurface,
                                        ),
                                        onPressed: () {
                                          controller.closeUploadPage();
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'رفع المشروع',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: context.themeOnSurface,
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