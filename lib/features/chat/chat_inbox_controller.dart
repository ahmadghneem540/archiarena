import 'dart:async';

import 'package:get/get.dart';

import '../../core/services/fcm_service.dart';
import '../../data/services/chat_api_service.dart';
import '../home/home_controller.dart';
import 'models/chat_request_model.dart';
import 'models/chat_thread_model.dart';

class ChatInboxController extends GetxController {
  final conversations = <ChatThreadModel>[].obs;
  final incomingRequests = <ChatRequestModel>[].obs;
  final isLoadingConversations = false.obs;
  final isLoadingRequests = false.obs;
  final selectedSegment = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['openRequestsTab'] == true) {
      selectedSegment.value = 1;
    }
    FcmService.addChatDataListener(_onFcmChatData);
    refreshAll();
  }

  void _onFcmChatData(Map<String, dynamic> data) {
    if (isClosed) return;
    final type = data['type']?.toString() ?? '';
    if (type == 'chat_message' || type == 'new_chat_message') {
      unawaited(loadConversations());
    } else if (type == 'chat_request' ||
        type == 'new_chat_request' ||
        type == 'chat_message_request') {
      unawaited(refreshAll());
    }
  }

  @override
  void onClose() {
    FcmService.removeChatDataListener(_onFcmChatData);
    super.onClose();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadConversations(), loadIncomingRequests()]);
  }

  Future<void> loadConversations() async {
    isLoadingConversations.value = true;
    try {
      final res = await ChatApiService.getConversations();
      if (res.isSuccess && res.data != null) {
        final list = res.data!['conversations'] ?? res.data!['list'];
        if (list is List) {
          final out = <ChatThreadModel>[];
          for (final e in list) {
            if (e is! Map) continue;
            final t = ChatThreadModel.fromJson(Map<String, dynamic>.from(e));
            if (t != null) out.add(t);
          }
          out.sort((a, b) {
            final ta = a.lastMessageAt;
            final tb = b.lastMessageAt;
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return tb.compareTo(ta);
          });
          conversations.assignAll(out);
        } else {
          conversations.clear();
        }
      } else {
        conversations.clear();
      }
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> loadIncomingRequests() async {
    isLoadingRequests.value = true;
    try {
      final res = await ChatApiService.getIncomingRequests();
      if (res.isSuccess && res.data != null) {
        final list = res.data!['requests'] ?? res.data!['list'];
        if (list is List) {
          final out = <ChatRequestModel>[];
          for (final e in list) {
            if (e is! Map) continue;
            final r = ChatRequestModel.fromJson(Map<String, dynamic>.from(e));
            if (r != null) out.add(r);
          }
          incomingRequests.assignAll(out);
        } else {
          incomingRequests.clear();
        }
      } else {
        incomingRequests.clear();
      }
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> acceptRequest(ChatRequestModel r) async {
    final res = await ChatApiService.acceptRequest(r.requestId);
    if (res.isSuccess) {
      Get.snackbar('success'.tr, 'chat_request_accepted'.tr);
      await refreshAll();
    } else {
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectOrBlockRequest(ChatRequestModel r, {required bool block}) async {
    if (block) {
      final res = await ChatApiService.blockUser(int.parse(r.senderId));
      if (res.isSuccess) {
        Get.snackbar('success'.tr, 'chat_blocked_ok'.tr);
        await loadIncomingRequests();
        return;
      }
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final res = await ChatApiService.rejectRequest(r.requestId);
    if (res.isSuccess) {
      Get.snackbar('success'.tr, 'chat_request_rejected'.tr);
      await loadIncomingRequests();
    } else {
      Get.snackbar(
        'failure'.tr,
        res.message ?? 'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static String? avatarFull(String? path) => HomeController.fullImageUrl(path);
}
