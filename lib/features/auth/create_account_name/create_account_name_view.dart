import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../../../widget/radio_option.dart';
import 'create_account_name_controller.dart';

class CreateAccountNameView extends GetView<CreateAccountNameController> {
  const CreateAccountNameView({super.key});

  static const List<String> _monthKeys = [
    'month_january', 'month_february', 'month_march', 'month_april',
    'month_may', 'month_june', 'month_july', 'month_august',
    'month_september', 'month_october', 'month_november', 'month_december',
  ];

  @override
  Widget build(BuildContext context) {
    final isRtl = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text('create_account'.tr),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'what_is_your_name'.tr,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'enter_actual_name'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                        controller: controller.firstNameController,
                        decoration: InputDecoration(
                          hintText: 'first_name'.tr,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                        controller: controller.lastNameController,
                        decoration: InputDecoration(
                          hintText: 'last_name'.tr,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  textDirection:
                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                  controller: controller.mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'phone_number'.tr,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textDirection:
                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'account_password'.tr,
                    prefixIcon: const Icon(Icons.lock_outline, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textDirection:
                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'email'.tr,
                    prefixIcon: const Icon(Icons.email_sharp, size: 22),
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  'when_birthday'.tr,
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
                    '${controller.age} ${'years_old'.tr}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'what_gender'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Column(
                    children: [
                      RadioOption<Gender>(
                        value: Gender.female,
                        groupValue: controller.selectedGender.value,
                        label: 'female'.tr,
                        onChanged: (v) => controller.selectGender(v!),
                      ),
                      RadioOption<Gender>(
                        value: Gender.male,
                        groupValue: controller.selectedGender.value,
                        label: 'male'.tr,
                        onChanged: (v) => controller.selectGender(v!),
                      ),
                    ],
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
        final d = controller.birthDate.value;
        final newDay = (i + 1).clamp(1, 31);
        controller.setDate(DateTime(d.year, d.month, newDay));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 31,
        builder: (context, index) {
          final day = index + 1;
          final selected = controller.birthDate.value.day == day;
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
        final d = controller.birthDate.value;
        controller.setDate(DateTime(d.year, i + 1, d.day));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 12,
        builder: (context, index) {
          final selected = controller.birthDate.value.month == index + 1;
          return Center(
              child: Text(
              _monthKeys[index].tr,
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
    const startYear = 1950;
    const endYear = 2010;
    return ListWheelScrollView.useDelegate(
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      controller: controller.yearController,
      onSelectedItemChanged: (i) {
        final d = controller.birthDate.value;
        controller.setDate(DateTime(endYear - i, d.month, d.day));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: endYear - startYear + 1,
        builder: (context, index) {
          final year = endYear - index;
          final selected = controller.birthDate.value.year == year;
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
