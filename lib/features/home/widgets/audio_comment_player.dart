import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';

/// ويدجت لتشغيل التعليق الصوتي — تشغيل/إيقاف، شريط تقدم، ووقت.
class AudioCommentPlayer extends StatefulWidget {
  const AudioCommentPlayer({
    super.key,
    required this.audioPath,
    this.durationSeconds,
  });

  final String audioPath;

  /// مدة الملف بالثواني (للعرض إن لم يُحمّل بعد).
  final int? durationSeconds;

  @override
  State<AudioCommentPlayer> createState() => _AudioCommentPlayerState();
}

class _AudioCommentPlayerState extends State<AudioCommentPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isSeeking = false;

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(1)}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.playing || state == PlayerState.paused) {
            _isLoading = false;
            _errorMessage = null;
          }
        });
      }
    });
    _player.onDurationChanged.listen((d) {
      if (mounted && !_isSeeking) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted && !_isSeeking) setState(() => _position = p);
    });
    _player.onLog.listen((msg) {
      debugPrint('AudioPlayer Log: $msg');
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
    if (widget.durationSeconds != null) {
      _duration = Duration(seconds: widget.durationSeconds!);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        String finalPath = widget.audioPath;
        Source source;

        if (widget.audioPath.startsWith('http')) {
          // تحميل الملف الصوتي محلياً لتجاوز حماية السيرفر (Browser Check)
          final tempDir = await getTemporaryDirectory();
          final fileName = widget.audioPath.split('/').last.split('?').first;
          final localFile = File('${tempDir.path}/$fileName');

          if (!await localFile.exists()) {
            final dio = Dio(BaseOptions(
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              },
            ));
            await dio.download(widget.audioPath, localFile.path);
          }
          source = DeviceFileSource(localFile.path);
        } else {
          source = DeviceFileSource(widget.audioPath);
        }

        await _player.play(source);
        if (widget.durationSeconds != null && _duration.inSeconds == 0) {
          setState(() => _duration = Duration(seconds: widget.durationSeconds!));
        }
      } catch (e) {
        debugPrint('AudioPlayer Error: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'audio_play_failed'.tr;
          });
        }
      }
    }
  }

  Future<void> _seekTo(double seconds) async {
    setState(() => _isSeeking = true);
    await _player.seek(Duration(milliseconds: (seconds * 1000).round()));
    setState(() => _isSeeking = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalSec = _duration.inSeconds;
    final posSec = _position.inSeconds;
    final maxSec = totalSec > 0 ? totalSec.toDouble() : 1.0;
    final value = totalSec > 0 ? posSec.clamp(0, totalSec).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _isLoading ? null : _togglePlay,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: _errorMessage != null
                        ? AppColors.error
                        : AppColors.primary,
                    size: 40,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.grey300,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: value,
                      min: 0,
                      max: maxSec,
                      onChanged: (v) => _seekTo(v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _errorMessage ?? _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          color: _errorMessage != null
                              ? AppColors.error
                              : AppColors.grey600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
