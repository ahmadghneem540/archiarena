import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/menu_page_scaffold.dart';


class FeedbackController extends GetxController {
  RxString selectedType = ''.obs;

  final List<String> types = [
    'feedback_type_bug'.tr,
    'feedback_type_suggestion'.tr,
    'feedback_type_complaint'.tr,
    'feedback_type_other'.tr,
  ];

  void setType(String value) {
    selectedType.value = value;
  }

  Future<void> openEmail() async {
    final email = 'info@kakapoagency.com';

    final subject = Uri.encodeComponent(
      selectedType.value.isEmpty ? 'Feedback' : selectedType.value.tr,
    );

    final body = Uri.encodeComponent(
      '---\n${'contact_us_desc'.tr}\n',
    );

    final gmailUri = Uri.parse(
      'googlegmail://co?to=$email&subject=$subject&body=$body',
    );

    final mailUri = Uri.parse(
      'mailto:$email?subject=$subject&body=$body',
    );

    try {
      await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

class FeedbackView extends StatelessWidget {
  FeedbackView({super.key});

  final FeedbackController controller = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    return MenuPageScaffold(
      title: 'send_feedback'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'feedback_desc'.tr,
              style: TextStyle(
                fontSize: 14,
                color: context.themeGrey700,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'feedback_type'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.themeGrey600,
              ),
            ),

            const SizedBox(height: 8),

            /// Dropdown
            Obx(() {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: context.themeCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.themeBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedType.value.isEmpty
                        ? null
                        : controller.selectedType.value,
                    hint: Text(
                      'feedback_placeholder'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.themeGrey700,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.themeGrey600,
                    ),
                    items: controller.types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.tr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setType(value);
                      }
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            Text(
              'help_support_text'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.themeGrey600,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'contact_us_desc'.tr,
              style: TextStyle(
                fontSize: 14,
                color: context.themeGrey700,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: controller.openEmail,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Center(child: Text('open_gmail'.tr)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}