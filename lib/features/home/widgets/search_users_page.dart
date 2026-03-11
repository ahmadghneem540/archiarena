import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: TextField(
            controller: _queryController,
            autofocus: true,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث عن مستخدمين...',
              hintStyle: TextStyle(color: AppColors.grey600, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 16, color: AppColors.onSurface),
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
                  Icon(Icons.search, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(
                    'اكتب اسم المستخدم أو اسمه للبحث',
                    style: TextStyle(fontSize: 15, color: AppColors.grey600),
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
                  Icon(Icons.person_off_outlined, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد نتائج',
                    style: TextStyle(fontSize: 15, color: AppColors.grey600),
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
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture != null && user.profilePicture!.isNotEmpty
                    ? null
                    : Text(
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (user.username != null && user.username!.isNotEmpty)
                      Text(
                        '@${user.username}',
                        style: TextStyle(fontSize: 13, color: AppColors.grey600),
                      ),
                    if (user.job != null && user.job!.isNotEmpty)
                      Text(
                        user.job!,
                        style: TextStyle(fontSize: 12, color: AppColors.grey500),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: AppColors.grey500),
            ],
          ),
        ),
      ),
    );
  }
}
