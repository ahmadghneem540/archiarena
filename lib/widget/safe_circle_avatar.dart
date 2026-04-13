import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// صورة دائرية من الشبكة مع placeholder عند الفشل (404 وغيره) — بدون NetworkImage.
class SafeCircleAvatar extends StatelessWidget {
  const SafeCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.radius = 28,
    this.backgroundColor,
  });

  final String? imageUrl;
  final Widget fallback;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
    final d = radius * 2;
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: bg, child: fallback);
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!.trim(),
          httpHeaders: const {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
          width: d,
          height: d,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          placeholder: (_, __) => Container(
            width: d,
            height: d,
            color: bg,
            alignment: Alignment.center,
            child: SizedBox(
              width: radius * 0.7,
              height: radius * 0.7,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (_, __, ___) =>
              Container(
                width: d,
                height: d,
                color: bg,
                alignment: Alignment.center,
                child: fallback,
              ),
        ),
      ),
    );
  }
}
