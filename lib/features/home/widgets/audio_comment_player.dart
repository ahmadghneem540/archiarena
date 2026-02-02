import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted && !_isSeeking) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted && !_isSeeking) setState(() => _position = p);
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
      await _player.play(DeviceFileSource(widget.audioPath));
      if (widget.durationSeconds != null && _duration.inSeconds == 0) {
        setState(() => _duration = Duration(seconds: widget.durationSeconds!));
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
            IconButton(
              onPressed: _togglePlay,
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: AppColors.primary,
                size: 40,
              ),
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
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
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
