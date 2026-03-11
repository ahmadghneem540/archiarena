import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// مؤقت تنازلي يعرض الوقت المتبقي حتى تاريخ الانتهاء (أيام، ساعات، دقائق).
/// يقبل [deadline] كنص (ISO أو صيغة قابلة للتحليل) أو [deadlineAt] كـ DateTime.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    this.deadline,
    this.deadlineAt,
    this.style,
    this.iconSize = 18,
    this.showIcon = true,
  });

  /// تاريخ/وقت الانتهاء كنص من الـ API (مثل 2026-04-15T12:00:00.000Z)
  final String? deadline;
  /// تاريخ الانتهاء كـ DateTime (إن وُفر يُستخدم بدل deadline)
  final DateTime? deadlineAt;
  final TextStyle? style;
  final double iconSize;
  final bool showIcon;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration? _remaining;
  DateTime? _endAt;

  @override
  void initState() {
    super.initState();
    _parseDeadline();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _update());
    _update();
  }

  void _parseDeadline() {
    if (widget.deadlineAt != null) {
      _endAt = widget.deadlineAt;
      return;
    }
    final s = widget.deadline?.trim();
    if (s == null || s.isEmpty) return;
    _endAt = DateTime.tryParse(s);
  }

  void _update() {
    if (_endAt == null) return;
    final now = DateTime.now();
    _remaining = _endAt!.difference(now);
    if (_remaining!.isNegative) _remaining = Duration.zero;
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline ||
        oldWidget.deadlineAt != widget.deadlineAt) {
      _parseDeadline();
      _update();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRemaining() {
    if (_endAt == null) return widget.deadline ?? '—';
    if (_remaining == null) return '...';
    if (_remaining!.inSeconds <= 0) return 'منتهي';
    final d = _remaining!.inDays;
    final h = _remaining!.inHours % 24;
    final m = _remaining!.inMinutes % 60;
    final parts = <String>[];
    if (d > 0) parts.add('$d يوم');
    if (h > 0) parts.add('$h ساعة');
    if (m > 0 || parts.isEmpty) parts.add('$m دقيقة');
    return parts.join(' و ');
  }

  @override
  Widget build(BuildContext context) {
    final text = _formatRemaining();
    final style = widget.style ??
        TextStyle(fontSize: 13, color: AppColors.grey700);

    if (widget.showIcon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _remaining != null && _remaining!.inSeconds <= 0
                ? Icons.check_circle_outline
                : Icons.timer_outlined,
            size: widget.iconSize,
            color: _remaining != null && _remaining!.inSeconds <= 0
                ? AppColors.grey500
                : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return Text(text, style: style, overflow: TextOverflow.ellipsis);
  }
}
