import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';

class HomePostDetailsSheet extends StatefulWidget {
  const HomePostDetailsSheet({super.key});

  @override
  State<HomePostDetailsSheet> createState() => _HomePostDetailsSheetState();
}

class _HomePostDetailsSheetState extends State<HomePostDetailsSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<Color> _carouselColors = [
    AppColors.placeholder1,
    AppColors.placeholder2,
    AppColors.placeholder3,
  ];

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPostHeader(),
                      const SizedBox(height: 16),
                      _buildImageCarousel(),
                      const SizedBox(height: 20),
                      _buildTitleAndDescription(),
                      const SizedBox(height: 16),
                      _buildDesignDetailsList(),
                      const SizedBox(height: 20),
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
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'شركة زيرو للتصميم',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'منذ ساعتين',
                style: TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
            ],
          ),
        ),
        Text(
          'تصميم داخلي',
          style: TextStyle(fontSize: 14, color: AppColors.grey700),
        ),
        const SizedBox(width: 8),
        Icon(Icons.more_vert, size: 24, color: AppColors.grey600),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _carouselColors[index],
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: AppColors.grey500,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
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
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تصميم داخلي لمكتب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تصميم داخلي لمكتب هندسي عصري يحقق التوازن بين العملية والهوية البصرية، مع استغلال ذكي للمساحات.',
          style: TextStyle(fontSize: 15, color: AppColors.grey700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDesignDetailsList() {
    const items = [
      'توزيع ذكي لمنطقة الاستقبال',
      'مكاتب عمل مفتوحة + غرف اجتماعات',
      'إضاءة طبيعية وصناعية مدروسة',
      'مواد تشطيب عالية الجودة',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل التصميم :',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
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
                    item,
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

  Widget _buildCategorizedInfo() {
    const rows = [
      ('نوع المشروع:', 'مكتب إداري / 🏢 سكني / 🏠 تجاري / 🏭'),
      ('المساحة:', '120 م²'),
      ('حالة المخطط:', 'قابل للتعديل'),
      ('مناسب لـ:', 'مكتب عقاري / مكتب هندسي'),
      ('الطراز:', 'مودرن - كلاسيك - نيو كلاسيك'),
    ];
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
    return ArchiButton(
      label: 'تحميل المخطط ونقل إلى الأعمال',
      height: 52,
      fontSize: 16,
      icon: Icons.description_outlined,
      iconSize: 22,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
