import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

import '../../../core/constant/const_data.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../models/post_model.dart';
import '../../../widget/gradient_button.dart';

/// شيت تفاصيل المنشور والمخططات — البيانات من الـ API (المنشور + GET /home/posts/:id).
class HomePostDetailsSheet extends StatefulWidget {
  const HomePostDetailsSheet({
    super.key,
    required this.controller,
    required this.post,
  });

  final HomeController controller;
  final PostModel post;

  @override
  State<HomePostDetailsSheet> createState() => _HomePostDetailsSheetState();
}

class _HomePostDetailsSheetState extends State<HomePostDetailsSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late PostModel _post;
  bool _loading = true;
  bool _isDownloadingAndAdding = false;

  static String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = ConstData.API_BASE;
    final path = url.startsWith('/') ? url : '/$url';
    return base.endsWith('/') ? '$base${path.substring(1)}' : '$base$path';
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    widget.controller.loadPostDetails(widget.post.id).then((full) {
      if (!mounted) return;
      setState(() {
        if (full != null) _post = full;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: screenHeight * 0.90,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildHandle(),
              Flexible(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPostHeader(),
                            const SizedBox(height: 16),
                            _buildImageCarousel(),
                            const SizedBox(height: 20),
                            _buildTitleAndDescription(),
                            if (_post.designDetails != null &&
                                _post.designDetails!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildDesignDetails(),
                            ],
                            if (_post.plans.isNotEmpty ||
                                _post.blueprints.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildPlansSection(),
                            ],
                            const SizedBox(height: 16),
                            _buildCategorizedInfo(),
                            const SizedBox(height: 24),
                            _buildActionButton(context),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildPostHeader() {
    final initial = (_post.authorName?.isNotEmpty == true)
        ? _post.authorName!.substring(0, 1).toUpperCase()
        : '؟';
    final avatarUrl = _post.authorAvatar != null && _post.authorAvatar!.isNotEmpty
        ? _fullImageUrl(_post.authorAvatar)
        : null;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _post.authorName ?? 'مستخدم',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                _post.createdAt ?? '',
                style: TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
            ],
          ),
        ),
        if (_post.category != null && _post.category!.isNotEmpty)
          Text(
            _post.category!,
            style: TextStyle(fontSize: 14, color: AppColors.grey700),
          ),
        const SizedBox(width: 8),
        Icon(Icons.more_vert, size: 24, color: AppColors.grey600),
      ],
    );
  }

  List<Widget> _carouselItems() {
    final list = <Widget>[];
    if (_post.images.isNotEmpty) {
      for (final img in _post.images) {
        final url = _fullImageUrl(img.url);
        if (url.isEmpty) continue;
        list.add(_networkImageItem(url));
      }
    }
    if (list.isEmpty && _post.imageUrl != null && _post.imageUrl!.isNotEmpty) {
      list.add(_networkImageItem(_fullImageUrl(_post.imageUrl)));
    }
    if (list.isEmpty) {
      list.add(_placeholderItem());
    }
    return list;
  }

  Widget _networkImageItem(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.placeholder1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _placeholderItem(),
        ),
      ),
    );
  }

  Widget _placeholderItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.placeholder1,
      ),
      child: Center(
        child: Icon(Icons.image_outlined, size: 64, color: AppColors.grey500),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final items = _carouselItems();
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (index) {
              final isActive = index == _currentPage;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _post.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.onSurface,
          ),
        ),
        if (_post.description != null && _post.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _post.description!,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.grey700,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesignDetails() {
    final text = _post.designDetails!.trim();
    final lines = text.contains('\n')
        ? text.split('\n').where((s) => s.trim().isNotEmpty).toList()
        : [text];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'design_details'.tr}:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey700,
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim(),
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlansSection() {
    final allPlans = <PostPlanItem>[
      ..._post.plans,
      ..._post.blueprints,
    ];
    if (allPlans.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'plans_and_drawings'.tr}:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allPlans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final plan = allPlans[index];
              final url = _fullImageUrl(plan.url);
              return SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.cardBackground,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: url.isNotEmpty
                              ? Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.architecture,
                                    color: AppColors.grey400,
                                    size: 32,
                                  ),
                                )
                              : Icon(
                                  Icons.architecture,
                                  color: AppColors.grey400,
                                  size: 32,
                                ),
                        ),
                      ),
                    ),
                    if (plan.title != null && plan.title!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorizedInfo() {
    final rows = <(String, String)>[];
    if (_post.projectTypes != null && _post.projectTypes!.isNotEmpty) {
      rows.add(('${'project_type'.tr}:', _post.projectTypes!));
    }
    if (_post.area != null && _post.area!.isNotEmpty) {
      rows.add(('${'area'.tr}:', _post.area!));
    }
    if (_post.planStatus != null && _post.planStatus!.isNotEmpty) {
      rows.add(('${'plan_status'.tr}:', _post.planStatus!));
    }
    if (_post.suitableFor != null && _post.suitableFor!.isNotEmpty) {
      rows.add(('${'suitable_for'.tr}:', _post.suitableFor!));
    }
    if (_post.style != null && _post.style!.isNotEmpty) {
      rows.add(('${'style'.tr}:', _post.style!));
    }
    if (_post.budget != null && _post.budget!.isNotEmpty) {
      rows.add(('${'budget'.tr}:', _post.budget!));
    }
    if (_post.deadline != null && _post.deadline!.isNotEmpty) {
      rows.add(('${'end_date'.tr}:', _post.deadline!));
    }
    if (_post.projectTimer != null && _post.projectTimer!.isNotEmpty) {
      rows.add(('${'deal_timer'.tr}:', _post.projectTimer!));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        r.$1,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r.$2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (_isDownloadingAndAdding) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: AppColors.transparent,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'downloading'.tr,
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return ArchiButton(
      label: 'download_plan_and_move'.tr,
      height: 52,
      fontSize: 16,
      icon: Icons.description_outlined,
      iconSize: 22,
      onPressed: () async {
        setState(() => _isDownloadingAndAdding = true);
        try {
          final paths = await widget.controller.downloadPostPlans(_post);
          if (!mounted) return;
          if (paths.isNotEmpty) {
            Get.snackbar(
              'plans_downloaded'.tr,
              'plans_downloaded_hint'.tr,
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.surface,
              margin: const EdgeInsets.all(12),
              mainButton: TextButton(
                onPressed: () => OpenFile.open(paths.first),
                child: Text('open_file'.tr, style: TextStyle(color: AppColors.primary)),
              ),
            );
          }
          final added = await widget.controller.addPostToWorks(_post.id);
          if (!mounted) return;
          if (added) {
            Get.snackbar(
              'plans_downloaded'.tr,
              'post_added_to_works'.tr,
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.surface,
              margin: const EdgeInsets.all(12),
            );
          }
        } finally {
          if (mounted) setState(() => _isDownloadingAndAdding = false);
        }
      },
    );
  }
}
