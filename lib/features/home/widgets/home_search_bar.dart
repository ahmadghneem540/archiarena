import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.grey300,
            child: Icon(Icons.person, color: AppColors.grey600, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'قم بالبحث عن التصميم ؟',
                  hintStyle: TextStyle(color: AppColors.grey600, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.search, color: AppColors.primary, size: 26),
        ],
      ),
    );
  }
}
