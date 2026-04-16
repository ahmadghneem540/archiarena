import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constant/const_data.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/services.dart';
import '../../../data/services/auth_api_service.dart';
import '../../../data/services/profile_api_service.dart';
import '../../home/home_controller.dart';

class LoginController extends GetxController {
  final phoneOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    phoneOrEmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final phoneOrEmail = phoneOrEmailController.text.trim();
    final password = passwordController.text;
    if (phoneOrEmail.isEmpty || password.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال الهاتف أو البريد وكلمة المرور.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final outcome = await AuthApiService.login(
        identifier: phoneOrEmail,
        password: password,
      );
      final res = outcome.response;
      final raw = outcome.rawJson;

      if (res.isSuccess) {
        if (AuthApiService.requiresEmailVerificationBeforeAccess(raw, res.data)) {
          final email = AuthApiService.emailForVerificationAfterLogin(
            phoneOrEmail,
            raw,
            res.data,
          );
          if (email == null || email.isEmpty) {
            Get.snackbar(
              'تنبيه',
              'لم يُعثر على البريد للتحقق. جرّب تسجيل الدخول باستخدام البريد الإلكتروني.',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          final isCompany = AuthApiService.readIsCompanyFromLoginPayload(raw) ??
              ((await MyServices.getStringValue(ConstData.keyIsCompany)) == '1');
          Get.offAllNamed(
            AppRoutes.verifyEmail,
            arguments: {'email': email, 'isCompany': isCompany},
          );
          return;
        }

        ApiClient.reset();
        bool isCompany = (await MyServices.getStringValue(ConstData.keyIsCompany)) == '1';
        try {
          final profileRes = await ProfileApiService.getMyProfile();
          if (profileRes.isSuccess && profileRes.data != null) {
            final d = profileRes.data!;
            final fromProfile = _checkIsCompany(d) ?? _checkIsCompany(d['user']);
            if (fromProfile == true) {
              isCompany = true;
              await MyServices.saveStringValue(ConstData.keyIsCompany, '1');
            } else if (fromProfile == false) {
              isCompany = false;
              await MyServices.saveStringValue(ConstData.keyIsCompany, '0');
            }
          }
        } catch (_) {}
        Get.delete<HomeController>(force: true);
        Get.offAllNamed(AppRoutes.home, arguments: {'isCompany': isCompany});
      } else {
        if (AuthApiService.requiresEmailVerificationBeforeAccess(outcome.rawJson, null) ||
            _messageImpliesVerifyEmail(res.message, outcome.rawJson)) {
          final email = AuthApiService.emailForVerificationAfterLogin(
            phoneOrEmail,
            outcome.rawJson,
            null,
          );
          if (email != null && email.isNotEmpty) {
            final isCompany =
                AuthApiService.readIsCompanyFromLoginPayload(outcome.rawJson) ?? false;
            Get.offAllNamed(
              AppRoutes.verifyEmail,
              arguments: {'email': email, 'isCompany': isCompany},
            );
            return;
          }
        }
        Get.snackbar(
          'فشل تسجيل الدخول',
          res.message ?? 'بيانات الدخول غير صحيحة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      // معالجة أي خطأ غير متوقع (مثل 503 من getMyProfile أو أخطاء شبكة)
      Get.snackbar(
        'فشل تسجيل الدخول',
        'error_server_unavailable'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _messageImpliesVerifyEmail(String? message, Map<String, dynamic> raw) {
    final parts = <String?>[
      message,
      raw['message']?.toString(),
      raw['error']?.toString(),
    ];
    final s = parts.whereType<String>().join(' ').toLowerCase();
    return s.contains('verify') ||
        s.contains('verification') ||
        s.contains('unverified') ||
        s.contains('تأكيد') ||
        s.contains('التحقق') ||
        (s.contains('email') && s.contains('not'));
  }

  bool? _checkIsCompany(dynamic data) {
    if (data is! Map) return null;
    final m = Map<String, dynamic>.from(data);
    if (m['is_company'] == true) return true;
    if (m['is_company'] == false) return false;
    final t = (m['user_type'] ?? m['type'] ?? m['account_type'] ?? m['role'])
        ?.toString()
        .toLowerCase();
    if (t == null || t.isEmpty) return null;
    if (t == 'company' || t.contains('company')) return true;
    if (t == 'customer' || t == 'personal' || t == 'individual') return false;
    return null;
  }

  void forgotPassword() {
    Get.toNamed(AppRoutes.forgotPasswordRequest);
  }

  void createNewAccount() {
    Get.offAllNamed(AppRoutes.createAccountIntro);
  }
}
