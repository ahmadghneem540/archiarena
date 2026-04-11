import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_controller.dart';
import 'chat_inbox_controller.dart';
import 'chat_room_binding.dart';
import 'chat_room_view.dart';
import 'models/chat_request_model.dart';
import 'models/chat_thread_model.dart';

class ChatInboxView extends GetView<ChatInboxController> {
  const ChatInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          backgroundColor: context.themeSurface,
          foregroundColor: context.themeOnSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'chat_inbox_title'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.themeOnSurface,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Obx(() {
                final requestCount = controller.incomingRequests.length;
                final segmentIndex = controller.selectedSegment.value;
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.themeCardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.themeBorder),
                  ),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentChip(
                          label: 'chat_tab_conversations'.tr,
                          selected: segmentIndex == 0,
                          onTap: () => controller.selectedSegment.value = 0,
                        ),
                      ),
                      Expanded(
                        child: _SegmentChip(
                          label: 'chat_tab_requests'.tr,
                          selected: segmentIndex == 1,
                          badge: requestCount,
                          onTap: () => controller.selectedSegment.value = 1,
                        ),
                      ),
                    ],
                    ),
                  ),
                );
              }),
            ),
            Expanded(
              child: Obx(() {
                if (controller.selectedSegment.value == 0) {
                  return _ConversationsList(controller: controller);
                }
                return _RequestsList(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: selected ? AppColors.onPrimary : context.themeOnSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.onPrimary.withValues(alpha: 0.25)
                      : Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? AppColors.onPrimary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConversationsList extends StatelessWidget {
  const _ConversationsList({required this.controller});

  final ChatInboxController controller;

  void _openThread(ChatThreadModel t) {
    final nav = Get.to(
      () => const ChatRoomView(),
      binding: ChatRoomBinding(),
      arguments: {
        'peerId': t.peerId,
        'peerName': t.peerName.isEmpty ? 'user_default'.tr : t.peerName,
        'peerAvatar': t.peerAvatar,
      },
    );
    nav?.then((_) => controller.refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingConversations.value &&
          controller.conversations.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2,
          ),
        );
      }
      if (controller.conversations.isEmpty) {
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: controller.loadConversations,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
              Icon(
                Icons.forum_outlined,
                size: 64,
                color: context.themeGrey600,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'chat_no_conversations'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.themeGrey600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: controller.loadConversations,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.conversations.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 72,
            color: context.themeBorder,
          ),
          itemBuilder: (context, index) {
            final t = controller.conversations[index];
            final url = ChatInboxController.avatarFull(t.peerAvatar);
            final name =
                t.peerName.isEmpty ? 'user_default'.tr : t.peerName;
            // بدون ListTile — يتجنب InkWell داخل قيود غير مكتملة مع Scaffold/ListView
            return RepaintBoundary(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openThread(t),
                  child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 72),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          backgroundImage: url != null && url.isNotEmpty
                              ? CachedNetworkImageProvider(url)
                              : null,
                          child: url == null || url.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0] : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: context.themeOnSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.lastMessageBody ?? 'chat_tap_to_open'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.themeGrey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (t.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            child: Center(
                              child: Text(
                                '${t.unreadCount > 9 ? '9+' : t.unreadCount}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            );
          },
        ),
      );
    });
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.controller});

  final ChatInboxController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRequests.value &&
          controller.incomingRequests.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2,
          ),
        );
      }
      if (controller.incomingRequests.isEmpty) {
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: controller.loadIncomingRequests,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
              Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: context.themeGrey600,
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'chat_no_requests'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.themeGrey600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: controller.loadIncomingRequests,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: controller.incomingRequests.length,
          itemBuilder: (context, index) {
            final r = controller.incomingRequests[index];
            return _RequestCard(controller: controller, request: r);
          },
        ),
      );
    });
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.controller,
    required this.request,
  });

  final ChatInboxController controller;
  final ChatRequestModel request;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = ChatInboxController.avatarFull(request.senderAvatar);
    final name = request.senderName.isEmpty
        ? 'user_default'.tr
        : request.senderName;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.themeCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.themeBorder),
          boxShadow: [
            BoxShadow(
              color: context.themeShadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: url != null && url.isNotEmpty
                    ? CachedNetworkImageProvider(url)
                    : null,
                child: url == null || url.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.themeOnSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'chat_request_subtitle'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.themeGrey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniAction(
                  label: 'chat_accept_request'.tr,
                  filled: true,
                  onTap: () => controller.acceptRequest(request),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniAction(
                  label: 'chat_reject_request'.tr,
                  filled: false,
                  onTap: () =>
                      controller.rejectOrBlockRequest(request, block: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () =>
                controller.rejectOrBlockRequest(request, block: true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            icon: Icon(Icons.block, color: scheme.error, size: 20),
            label: Text('chat_block_user'.tr),
          ),
        ],
      ),
    ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      final scheme = Theme.of(context).colorScheme;
      return SizedBox(
        height: 44,
        width: double.infinity,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.themeOnSurface,
        side: BorderSide(color: context.themeBorder),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

/// فتح صندوق الوارد من أي مكان (القائمة، إلخ)
void openChatInbox({bool openRequestsTab = false}) {
  HomeController? hc;
  if (Get.isRegistered<HomeController>()) {
    hc = Get.find<HomeController>();
  }
  final nav = Get.toNamed(
    AppRoutes.chatInbox,
    arguments: openRequestsTab ? {'openRequestsTab': true} : null,
  );
  nav?.then((_) {
    hc?.loadChatPendingRequestCount();
    hc?.loadChatUnreadMessageCount();
  });
}

/// فتح غرفة دردشة مع مستخدم بالمعرّف والاسم (من البروفايل، إلخ)
void openChatWithUser({
  required String peerId,
  required String peerName,
  String? peerAvatar,
}) {
  HomeController? hc;
  if (Get.isRegistered<HomeController>()) {
    hc = Get.find<HomeController>();
  }
  final nav = Get.to(
    () => const ChatRoomView(),
    binding: ChatRoomBinding(),
    arguments: {
      'peerId': peerId,
      'peerName': peerName,
      'peerAvatar': peerAvatar,
    },
  );
  nav?.then((_) {
    hc?.loadChatPendingRequestCount();
    hc?.loadChatUnreadMessageCount();
  });
}
