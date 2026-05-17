import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widget/safe_circle_avatar.dart';
import '../home_controller.dart';
import '../models/user_profile_model.dart';
import 'other_user_profile_page.dart';
import 'shimmer_loading.dart';

/// شاشة بحث المستخدمين — GET /search/users?q=... ثم الدخول لبروفايل المستخدم.
class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key, required this.controller});

  final HomeController controller;

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.controller.searchUsers(_queryController.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    widget.controller.clearSearchResults();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = context.themeSurface;
    final onSurface = context.themeOnSurface;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Directionality(
      textDirection:
      isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: surface,
        appBar: AppBar(
          backgroundColor: surface,
          elevation: 0,
          foregroundColor: onSurface,
          iconTheme: IconThemeData(color: onSurface),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _queryController,
              autofocus: true,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              cursorColor: context.themePrimary,
              style: TextStyle(fontSize: 16, color: onSurface),

              decoration: InputDecoration(
                isDense: true,
                hintText: 'search_users_hint'.tr,
                hintStyle: TextStyle(
                  color: context.themeGrey600,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        ),
        body: Obx(() {
          if (widget.controller.isSearchLoading.value) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(
                6,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerListTile(leadingSize: 48, titleWidth: 140, subtitleWidth: 80),
                ),
              ),
            );
          }
          final list = widget.controller.searchResults;
          if (_queryController.text.trim().isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: context.themeGrey400),
                  const SizedBox(height: 16),
                  Text(
                    'search_users_type_hint'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: context.themeGrey600),
                  ),
                ],
              ),
            );
          }
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 64, color: context.themeGrey400),
                  const SizedBox(height: 16),
                  Text(
                    'no_results'.tr,
                    style: TextStyle(fontSize: 15, color: context.themeGrey600),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = list[index];
              return _UserTile(
                user: user,
                onTap: () {
                  widget.controller.loadMyFriends();
                  widget.controller.loadOtherUserProfile(user.id);
                  widget.controller.loadOtherUserPosts(user.id);
                  Get.to(
                    () => OtherUserProfilePage(
                      controller: widget.controller,
                      user: user,
                      fromRequest: false,
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});

  final UserProfileModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0] : '؟';
    final onSurface = context.themeOnSurface;
    return Material(
      color: context.themeCardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SafeCircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                imageUrl: user.profilePicture,
                fallback: Text(
                  initial.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    if (user.username != null && user.username!.isNotEmpty)
                      Text(
                        '@${user.username}',
                        style: TextStyle(fontSize: 13, color: context.themeGrey600),
                      ),
                    if (user.job != null && user.job!.isNotEmpty)
                      Text(
                        user.job!,
                        style: TextStyle(fontSize: 12, color: context.themeGrey500),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.themeGrey500),
            ],
          ),
        ),
      ),
    );
  }
}
