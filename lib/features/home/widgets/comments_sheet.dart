import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widget/fullscreen_image_viewer.dart';
import '../../../widget/safe_circle_avatar.dart';
import '../home_controller.dart';
import '../models/comment_model.dart';
import 'audio_comment_player.dart';

/// شاشة التعليقات — تظهر عند الضغط على أيقونة التعليقات.
/// تدعم التعليق النصي والصوتي والردود المتداخلة.
class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.postId});

  final int postId;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  String? _replyingToId;
  String? _replyingToName;
  bool _isRecording = false;
  bool _showIcons = false;
  int _recordingSeconds = 0;
  DateTime? _recordStartTime;
  Timer? _recordingTimer;

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1)}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    if (_isRecording) _audioRecorder.stop();
    super.dispose();
  }

  List<CommentModel> _buildCommentTree(List<CommentModel> flat) {
    final topLevel = flat.where((c) => c.parentId == null).toList();
    List<CommentModel> attachReplies(CommentModel c) {
      final children = flat.where((x) => x.parentId == c.id).toList();
      return children
          .map((child) => child.copyWith(replies: attachReplies(child)))
          .toList();
    }

    return topLevel.map((c) => c.copyWith(replies: attachReplies(c))).toList();
  }

  Future<void> _sendComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final controller = Get.find<HomeController>();
    final success = await controller.addComment(widget.postId, text, _replyingToId);
    if (success && mounted) {
      _textController.clear();
      setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      final controller = Get.find<HomeController>();
      final success = await controller.addImageComment(
        widget.postId,
        file.path,
        _replyingToId,
      );
      if (success && mounted) {
        setState(() {
          _replyingToId = null;
          _replyingToName = null;
        });
      }
    }
  }

  Future<void> _toggleRecording() async {
    // التسجيل الصوتي مدعوم فقط على Android و iOS
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('voice_record_mobile_only'.tr),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (_isRecording) {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      final durationSecs = _recordingSeconds;
      try {
        final path = await _audioRecorder.stop();
        if (path != null && mounted) {
          final controller = Get.find<HomeController>();
          await controller.addAudioComment(
            widget.postId,
            path,
            _replyingToId,
            durationSecs > 0 ? durationSecs : null,
          );
          if (mounted) {
            setState(() {
              _replyingToId = null;
              _replyingToName = null;
            });
          }
        }
      } catch (_) {}
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
        _recordStartTime = null;
      });
      return;
    }

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('grant_microphone'.tr),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/comment_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      if (mounted) {
        _recordStartTime = DateTime.now();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted || !_isRecording) return;
          setState(() {
            _recordingSeconds = DateTime.now()
                .difference(_recordStartTime!)
                .inSeconds;
          });
        });
      }
    } on MissingPluginException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('voice_record_not_available'.tr),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'voice_record_start_failed'.tr}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingToId = comment.id;
      _replyingToName = comment.authorName;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final controller = Get.find<HomeController>();
    final flatList = controller.getCommentsListForPost(widget.postId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: screenHeight * 0.75,
        decoration: BoxDecoration(
          color: context.themeSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildHandle(context),
              const SizedBox(height: 8),
              Text(
                'comments_title'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.themeOnSurface,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final tree = _buildCommentTree(flatList);
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tree.length,
                    itemBuilder: (context, index) {
                      return _CommentTile(
                        comment: tree[index],
                        depth: 0,
                        onReply: _startReply,
                      );
                    },
                  );
                }),
              ),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.themeBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).padding.left,
        right: MediaQuery.of(context).padding.right,
        bottom: MediaQuery.of(context).padding.bottom,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: context.themeSurface,
        border: Border(top: BorderSide(color: context.themeBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToName != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'reply_to'.trParams({'name': _replyingToName ?? ''}),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: context.themeGrey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  _showIcons ? Icons.close : Icons.add_circle_outline,
                  color: AppColors.primary,
                  size: 28,
                ),
                tooltip: _showIcons ? 'hide_options'.tr : 'show_comment_options'.tr,
                onPressed: () => setState(() => _showIcons = !_showIcons),
              ),
              if (_showIcons) ...[
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.mic_none,
                    color: _isRecording ? AppColors.error : AppColors.primary,
                    size: 26,
                  ),
                  onPressed: _toggleRecording,
                ),
                if (_isRecording)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _formatDuration(_recordingSeconds),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.themeOnSurface,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  onPressed: _pickFromGallery,
                ),
              ],
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackgroundBy(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.themeBorder),
                  ),
                  child: TextField(
                    controller: _textController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'write_comment'.tr,
                      hintStyle: TextStyle(
                        color: context.themeGrey600,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        onPressed: _sendComment,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SafeCircleAvatar(
                radius: 20,
                imageUrl: controller.myProfile.profilePicture,
                backgroundColor: context.themeBorder,
                fallback: Text(
                  controller.myProfile.name.isNotEmpty
                      ? controller.myProfile.name[0].toUpperCase()
                      : '؟',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.depth,
    required this.onReply,
  });

  final CommentModel comment;
  final int depth;
  final void Function(CommentModel) onReply;

  @override
  Widget build(BuildContext context) {
    const indent = 24.0;
    const lineWidth = 2.0;

    final controller = Get.find<HomeController>();
    final myProfileId = controller.myProfile.id;
    final isMe = comment.authorId != null &&
        (comment.authorId == myProfileId || comment.authorId == 'me');
    final avatarUrl = comment.authorAvatar != null &&
            comment.authorAvatar!.isNotEmpty
        ? HomeController.fullImageUrl(comment.authorAvatar)
        : (isMe &&
                controller.myProfile.profilePicture != null &&
                controller.myProfile.profilePicture!.isNotEmpty
            ? controller.myProfile.profilePicture
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: depth * indent, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (depth > 0) ...[
                SizedBox(
                  width: indent,
                  height: 24,
                  child: CustomPaint(
                    size: const Size(lineWidth, 24),
                    painter: _LinePainter(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.themeCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.themeBorder),
                    boxShadow: [
                      BoxShadow(
                        color: context.themeShadowLight,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SafeCircleAvatar(
                            radius: 18,
                            imageUrl: avatarUrl,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            fallback: Text(
                              comment.authorName.isNotEmpty
                                  ? comment.authorName[0].toUpperCase()
                                  : '؟',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              comment.authorName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: context.themeOnSurface,
                              ),
                            ),
                          ),
                          Text(
                            comment.createdAt,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.themeGrey600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => onReply(comment),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  'reply'.tr,
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (comment.imageUrl != null &&
                          comment.imageUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onTap: () => Get.to(
                                () => FullscreenImageViewer(
                                  imageUrl: comment.imageUrl!,
                                ),
                              ),
                              child: CachedNetworkImage(
                                 imageUrl: comment.imageUrl!,
                                 httpHeaders: const {
                                   'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                                 },
                                 fit: BoxFit.cover,
                                 width: double.infinity,
                                 height: 180,
                                 placeholder: (_, __) => Container(
                                   height: 180,
                                   color: context.themeBorder.withValues(
                                     alpha: 0.1,
                                   ),
                                   alignment: Alignment.center,
                                   child: const SizedBox(
                                     width: 24,
                                     height: 24,
                                     child: CircularProgressIndicator(
                                       strokeWidth: 2,
                                     ),
                                   ),
                                 ),
                                 errorWidget: (_, __, ___) => Container(
                                   height: 180,
                                   color: context.themeBorder.withValues(
                                     alpha: 0.1,
                                   ),
                                   alignment: Alignment.center,
                                   child: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(
                                         Icons.broken_image_outlined,
                                         color: context.themeGrey600,
                                         size: 32,
                                       ),
                                       const SizedBox(height: 4),
                                       Text(
                                         'image_load_failed'.tr,
                                         style: TextStyle(
                                           fontSize: 12,
                                           color: context.themeGrey600,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                            ),
                          ),
                        ),
                      if (comment.isAudio && comment.audioPath != null)
                        AudioCommentPlayer(
                          audioPath: comment.audioPath!,
                          durationSeconds: comment.audioDurationSeconds,
                        )
                      else if (comment.isAudio)
                        _buildAudioPlaceholder()
                      else
                        Text(
                          comment.text ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.themeOnSurface,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ...comment.replies.map(
          (r) => _CommentTile(comment: r, depth: depth + 1, onReply: onReply),
        ),
      ],
    );
  }

  Widget _buildAudioPlaceholder() {
    return Row(
      children: [
        Icon(Icons.audiotrack, color: AppColors.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          'voice_comment'.tr,
          style: TextStyle(fontSize: 13, color: AppColors.grey700),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey300
      ..strokeWidth = size.width;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
