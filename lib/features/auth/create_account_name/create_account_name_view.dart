import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../../../widget/radio_option.dart';
import 'create_account_name_controller.dart';

class CreateAccountNameView extends GetView<CreateAccountNameController> {
  const CreateAccountNameView({super.key});

  static const List<String> _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text('إنشاء حساب'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'ما اسمك؟',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل الاسم الذي تستخدمه في الحياة الواقعية.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textDirection: TextDirection.rtl,
                        controller: controller.firstNameController,
                        decoration: const InputDecoration(
                          hintText: 'الاسم الأول',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        textDirection: TextDirection.rtl,
                        controller: controller.lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'اسم العائلة',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  textDirection: TextDirection.rtl,
                  controller: controller.mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'رقم الموبايل',
                    prefixIcon: Icon(Icons.phone_outlined, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textDirection: TextDirection.rtl,
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'كلمة مرور الحساب',
                    prefixIcon: Icon(Icons.lock_outline, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textDirection: TextDirection.rtl,
                  controller: controller.emailController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'البريد الالكتروني',
                    prefixIcon: Icon(Icons.email_sharp, size: 22),
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  'متى عيد ميلادك؟',
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
                    '${controller.age} سنة',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ما جنسك؟',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Column(
                    children: [
                      RadioOption<Gender>(
                        value: Gender.female,
                        groupValue: controller.selectedGender.value,
                        label: 'أنثى',
                        onChanged: (v) => controller.selectGender(v!),
                      ),
                      RadioOption<Gender>(
                        value: Gender.male,
                        groupValue: controller.selectedGender.value,
                        label: 'ذكر',
                        onChanged: (v) => controller.selectGender(v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ArchiButton(label: 'التالي', onPressed: controller.next),
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
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
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
              _monthsAr[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
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
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
