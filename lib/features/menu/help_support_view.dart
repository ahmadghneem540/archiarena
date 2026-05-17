import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_direction.dart';
import 'widgets/menu_page_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
/// =============================
/// MAIN VIEW
/// =============================
class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'help_support'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _header(context),

              const SizedBox(height: 24),

              _buildLink(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'faq'.tr,
                onTap: () => Get.to(() => const FAQView()),
              ),

              const SizedBox(height: 12),

              _buildLink(
                context: context,
                icon: Icons.mail_outline_rounded,
                title: 'contact_us'.tr,
                subtitle: 'info@kakapoagency.com',
                onTap: () => Get.to(() => const ContactUsView()),
              ),

              const SizedBox(height: 12),

              _buildLink(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                title: 'live_chat'.tr,
                subtitle: 'live_chat_hours'.tr,
                onTap: () => Get.to(() => const LiveChatView()),
              ),

              const SizedBox(height: 12),

              _buildLink(
                context: context,
                icon: Icons.description_outlined,
                title: 'help_center'.tr,
                onTap: () => Get.to(() => const HelpCenterView()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primaryDark.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(Icons.support_agent, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'help_support_how_help'.tr,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontSize: 18,
                  color: context.themeOnSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'help_support_desc'.tr,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(color: context.themeGrey700),
          ),
        ],
      ),
    );
  }

  Widget _buildLink({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.themeCardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.themeBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(color: context.themeOnSurface)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(color: context.themeGrey600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: context.themeGrey600),
          ],
        ),
      ),
    );
  }
}

/// =============================
/// FAQ PAGE
/// =============================
class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'faq'.tr,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _faqItem(context, 'faq_q1'.tr, 'faq_a1'.tr),
          _faqItem(context, 'faq_q2'.tr, 'faq_a2'.tr),
        ],
      ),
    );
  }

  Widget _faqItem(BuildContext context, String q, String a) {
    return Card(
      color: context.themeCardBackground,
      child: ExpansionTile(
        title: Text(
            q,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(color: context.themeOnSurface)
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(a,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(color: context.themeGrey700)),
          )
        ],
      ),
    );
  }
}

/// =============================
/// CONTACT US
/// =============================


class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'contact_us'.tr,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined,
                      color: context.theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'contact_us_desc'.tr,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Email Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 10),
                  SelectableText(
                    'info@kakapoagency.com',
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      color: context.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openEmailApp,
                icon: Icon(Icons.send,textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,),
                label: Text('send_message'.tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@kakapoagency.com',
    );

    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  }
}

/// =============================
/// LIVE CHAT (UI ONLY)
/// =============================
class LiveChatView extends StatelessWidget {
  const LiveChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return MenuPageScaffold(
      title: 'contact_developer'.tr,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              /// Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.support_agent,
                        color: context.theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'contact_dev_desc'.tr,
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Email display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: context.theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined),
                    const SizedBox(width: 10),
                    SelectableText(
                      'info@kakapoagency.com',
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              const SizedBox(height: 16),

              /// Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openEmailApp,
                  icon: const Icon(Icons.email),
                  label: Text('send_message'.tr),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@kakapoagency.com',
    );

    await launchUrl(emailUri);
  }
}

/// =============================
/// HELP CENTER
/// =============================


class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'help_center'.tr,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.support_agent_rounded,
              size: 70,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            /// نص بسيط
            Text(
              'help_support_text'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            /// البريد
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.email_outlined),
                  SizedBox(width: 10),
                  SelectableText(
                    'info@kakapoagency.com',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// زر فتح Gmail
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openGmail,
                icon: const Icon(Icons.email),
                label: Text('open_gmail'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@kakapoagency.com',
    );

    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  }
}