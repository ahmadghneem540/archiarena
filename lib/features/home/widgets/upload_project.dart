import 'package:flutter/material.dart';

import '../../../widget/gradient_button.dart';

class UploadProjectPage extends StatelessWidget {
  const UploadProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// ---------------- الشروط ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الشروط:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('• احصل على تقييم كامل بعلامة ناجح'),
                SizedBox(height: 4),
                Text('• الصورة تحوي على 5 لقطات للمشروع'),
                SizedBox(height: 4),
                Text('• يكون المشروع تم تصميمه حديثاً'),
                SizedBox(height: 4),
                Text('• ويحسن الشروط المطلوبة'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ---------------- كارد الرفع ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xffEAF4F4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.teal.withOpacity(.2)),
            ),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'شارك أعمالك وتصاميمك الإبداعية',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ArchiButton(
                  label: 'رفع المشروع',
                  height: 48,
                  fontSize: 16,
                  icon: Icons.upload_file_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
