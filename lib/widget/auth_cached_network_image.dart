import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constant/const_data.dart';
import '../core/services/services.dart';

/// صورة شبكة مع تخزين مؤقت؛ يضيف [Authorization] عندما يكون الرابط على نفس مضيف الـ API.
class AuthCachedNetworkImage extends StatefulWidget {
  const AuthCachedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fit,
    this.width,
    this.height,
    this.placeholder,
    required this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget errorWidget;

  @override
  State<AuthCachedNetworkImage> createState() => _AuthCachedNetworkImageState();
}

class _AuthCachedNetworkImageState extends State<AuthCachedNetworkImage> {
  Map<String, String>? _headers;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _prepareHeaders();
  }

  Future<void> _prepareHeaders() async {
    Map<String, String>? h;
    if (ConstData.imageUrlSameHostAsApi(widget.imageUrl)) {
      final t = await MyServices.getStringValue(ConstData.keyToken);
      if (t != null && t.isNotEmpty) {
        h = {
          'Authorization': 'Bearer $t',
          'Accept': 'image/*,*/*',
        };
      }
    }
    if (!mounted) return;
    setState(() {
      _headers = h;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      final ph = widget.placeholder;
      if (ph != null) return ph;
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      httpHeaders: _headers,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: Duration.zero,
      placeholder: (_, __) =>
          widget.placeholder ??
          ColoredBox(
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      errorWidget: (_, __, ___) => widget.errorWidget,
    );
  }
}
