import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_controller.dart';
import 'chat_room_controller.dart';
import 'models/chat_message_model.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final title = controller.peerDisplayName.isEmpty
        ? 'user_default'.tr
        : controller.peerDisplayName;
    final avatarUrl = HomeController.fullImageUrl(controller.peerAvatar);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.themeSurface,
        appBar: AppBar(
          backgroundColor: context.themeSurface,
          foregroundColor: context.themeOnSurface,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                        title.isNotEmpty ? title[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: context.themeOnSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            Obx(() {
              final blocked =
                  controller.messagingState.value.toLowerCase().contains('blocked');
              final err = Theme.of(context).colorScheme.error;
              return PopupMenuButton<String>(
                color: context.themeSurface,
                surfaceTintColor: Colors.transparent,
                icon: Icon(Icons.more_vert, color: context.themeOnSurface),
                onSelected: (v) {
                  if (v == 'block') controller.confirmBlock();
                  if (v == 'unblock') controller.confirmUnblock();
                },
                itemBuilder: (context) => [
                  if (blocked)
                    PopupMenuItem(
                      value: 'unblock',
                      child: Text('chat_unblock'.tr),
                    )
                  else
                    PopupMenuItem(
                      value: 'block',
                      child: Text(
                        'chat_block'.tr,
                        style: TextStyle(color: err),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              final key = controller.statusBannerKey;
              if (key == null) return const SizedBox.shrink();
              final blocked = controller.messagingState.value
                  .toLowerCase()
                  .contains('blocked');
              final pendingIn =
                  controller.messagingState.value == 'pending_incoming';
              final cs = Theme.of(context).colorScheme;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.12,
                  ),
                  border: Border(
                    bottom: BorderSide(color: context.themeBorder.withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: cs.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        key.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.themeOnSurface,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (blocked)
                      TextButton(
                        onPressed: controller.confirmUnblock,
                        style: TextButton.styleFrom(foregroundColor: cs.primary),
                        child: Text('chat_unblock'.tr),
                      ),
                    if (pendingIn)
                      TextButton(
                        onPressed: controller.openIncomingRequestsTab,
                        style: TextButton.styleFrom(foregroundColor: cs.primary),
                        child: Text('chat_open_requests'.tr),
                      ),
                  ],
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.messages.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  );
                }
                if (controller.messages.isEmpty) {
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: controller.refreshMessages,
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.42,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 56,
                                  color: context.themeGrey600,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'chat_empty_thread'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: context.themeGrey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: controller.refreshMessages,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ListView.builder(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final m = controller.messages[index];
                        return RepaintBoundary(
                          child: _MessageBubble(
                            message: m,
                            controller: controller,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.themeSurface,
                boxShadow: [
                  BoxShadow(
                    color: context.themeShadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: MediaQuery.paddingOf(context).bottom + 10,
              ),
              child: Obx(() {
                final enabled = controller.canSendMessage && !controller.isSending.value;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        minLines: 1,
                        maxLines: 5,
                        enabled: controller.canSendMessage,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(color: context.themeOnSurface),
                        decoration: InputDecoration(
                          hintText: 'chat_input_hint'.tr,
                          hintStyle: TextStyle(
                            color: context.themeGrey600,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: context.themeInputBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: context.themeBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: context.themeBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: enabled ? controller.send : null,
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: controller.isSending.value
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: enabled
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.5),
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.controller,
  });

  final ChatMessageModel message;
  final ChatRoomController controller;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final mine = m.isFromMeForUi(controller.myUserId, controller.peerUserId);
    final body = m.body;
    final at = m.createdAt;
    final timeStr = at != null
        ? '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}'
        : '';
    final bubbleMaxW = MediaQuery.sizeOf(context).width * 0.78;

    final peerLabel = controller.peerDisplayName.trim().isEmpty
        ? 'user_default'.tr
        : controller.peerDisplayName;
    final myName = controller.myProfileName.trim();
    final senderLabel = mine
        ? (myName.isNotEmpty ? myName : 'chat_you'.tr)
        : (m.senderName?.trim().isNotEmpty == true
            ? m.senderName!.trim()
            : peerLabel);

    final cs = Theme.of(context).colorScheme;
    final sentColor = Color.lerp(cs.primary, AppColors.primaryDark, 0.12)!;
    final recvColor = context.themeChatBubbleReceived;
    final sentTextColor = cs.onPrimary;
    final recvTextColor = context.themeOnSurface;

    // LTR ثابت: حزمة chat_bubbles تبني Row بحيث «المرسل» يمين الشاشة؛ في RTL ينعكس المعنى بصرياً.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: mine ? 48 : 12,
                right: mine ? 12 : 48,
                bottom: 4,
              ),
              child: Text(
                senderLabel,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: mine ? cs.primary : context.themeGrey700,
                ),
              ),
            ),
            BubbleNormal(
              text: body,
              isSender: mine,
              color: mine ? sentColor : recvColor,
              tail: true,
              textStyle: TextStyle(
                color: mine ? sentTextColor : recvTextColor,
                fontSize: 15.5,
                height: 1.38,
              ),
              timestamp: timeStr.isNotEmpty ? timeStr : null,
              bubbleRadius: 16,
              constraints: BoxConstraints(maxWidth: bubbleMaxW),
              margin: EdgeInsets.only(
                left: mine ? 36 : 6,
                right: mine ? 6 : 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
