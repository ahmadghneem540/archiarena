import 'package:archiarena/features/home/widgets/what_do__think.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widget/gradient_button.dart';
import '../home_controller.dart';

class HomeSearchBar extends StatelessWidget {
  final HomeController controller;

  const HomeSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          /// صورة المستخدم
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.grey300,
            child: Icon(Icons.person, color: AppColors.grey600, size: 26),
          ),

          const SizedBox(width: 10),

          /// 🔥 حقل البحث + زر
          Expanded(
            child: Row(
              children: [
                /// ✅ حقل البحث يأخذ المساحة الأكبر
                Flexible(
                  flex: 5,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'قم بالبحث عن التصميم؟',
                        hintStyle: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// ✅ زر مرن بدل عرض ثابت
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ArchiButton(
                      label: 'بما تفكّر',
                      fontSize: 12,
                      height: 44,
                      icon: Icons.auto_awesome,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WhatDoThink(controller: controller),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// ❌ حذفنا أيقونة البحث لأنها كانت تسبب ضيق
          // Icon(Icons.search, color: AppColors.primary, size: 26),
        ],
      ),
    );
  }
}
