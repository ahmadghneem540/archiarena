import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import 'create_account_company_controller.dart';

class CreateAccountCompanyView extends GetView<CreateAccountCompanyController> {
  const CreateAccountCompanyView({super.key});

  List<String> get _months {
    return Get.locale?.languageCode == 'ar'
        ? [
            'month_january'.tr,
            'month_february'.tr,
            'month_march'.tr,
            'month_april'.tr,
            'month_may'.tr,
            'month_june'.tr,
            'month_july'.tr,
            'month_august'.tr,
            'month_september'.tr,
            'month_october'.tr,
            'month_november'.tr,
            'month_december'.tr,
          ]
        : [
            'month_january'.tr,
            'month_february'.tr,
            'month_march'.tr,
            'month_april'.tr,
            'month_may'.tr,
            'month_june'.tr,
            'month_july'.tr,
            'month_august'.tr,
            'month_september'.tr,
            'month_october'.tr,
            'month_november'.tr,
            'month_december'.tr,
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('create_company_account'.tr),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'what_is_company_name'.tr,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'enter_company_name'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  textDirection: Get.locale?.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  controller: controller.companyNameController,
                  decoration: InputDecoration(
                    hintText: 'company_name'.tr,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  textDirection: Get.locale?.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  controller: controller.mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'phone_number'.tr,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textDirection: Get.locale?.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'account_password'.tr,
                    prefixIcon: const Icon(Icons.lock_outline, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textDirection: Get.locale?.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'email'.tr,
                    prefixIcon: const Icon(Icons.email_sharp, size: 22),
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  'when_company_established'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(height: 160, child: _dayPicker()),
                      ),
                      Expanded(
                        child: SizedBox(height: 160, child: _monthPicker()),
                      ),
                      Expanded(
                        child: SizedBox(height: 160, child: _yearPicker()),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.yearsSinceEstablishment} ${'years'.tr}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                ArchiButton(label: 'next'.tr, onPressed: controller.next),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayPicker() {
    return ListWheelScrollView.useDelegate(
      controller: controller.dayController,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (i) {
        final d = controller.establishmentDate.value;
        final newDay = (i + 1).clamp(1, 31);
        controller.setDate(DateTime(d.year, d.month, newDay));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 31,
        builder: (context, index) {
          final day = index + 1;
          final selected = controller.establishmentDate.value.day == day;
          return Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? context.themeOnSurface
                    : context.themeOnSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _monthPicker() {
    return ListWheelScrollView.useDelegate(
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      controller: controller.monthController,
      onSelectedItemChanged: (i) {
        final d = controller.establishmentDate.value;
        controller.setDate(DateTime(d.year, i + 1, d.day));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 12,
        builder: (context, index) {
          final selected = controller.establishmentDate.value.month == index + 1;
          return Center(
            child: Text(
              _months[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? context.themeOnSurface
                    : context.themeOnSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _yearPicker() {
    const startYear = 1900;
    final endYear = DateTime.now().year;
    return ListWheelScrollView.useDelegate(
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      controller: controller.yearController,
      onSelectedItemChanged: (i) {
        final d = controller.establishmentDate.value;
        controller.setDate(DateTime(endYear - i, d.month, d.day));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: endYear - startYear + 1,
        builder: (context, index) {
          final year = endYear - index;
          final selected = controller.establishmentDate.value.year == year;
          return Center(
            child: Text(
              '$year',
              style: TextStyle(
                fontSize: 18,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? context.themeOnSurface
                    : context.themeOnSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
