import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/legal/legal_documents.dart';
import '../../core/theme/app_colors.dart';

/// سياسة الخصوصية وشروط الاستخدام الكاملة للعرض من القائمة (متطلبات متاجر التطبيقات).
class TermsPrivacyLegalView extends StatelessWidget {
  const TermsPrivacyLegalView({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Get.locale?.languageCode;
    final isRtl = (lang ?? 'ar') == 'ar';

    final privacy = LegalDocuments.privacyPolicy(lang);
    final terms = LegalDocuments.termsOfService(lang);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          backgroundColor: context.themeSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: context.themeOnSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'terms_and_privacy_policy'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.themeOnSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(context, 'privacy_policy'.tr),
                const SizedBox(height: 10),
                SelectableText(
                  privacy,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: context.themeGrey700,
                  ),
                ),
                const SizedBox(height: 28),
                _sectionTitle(context, 'terms_and_conditions'.tr),
                const SizedBox(height: 10),
                SelectableText(
                  terms,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: context.themeGrey700,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: context.themeOnSurface,
      ),
    );
  }
}
