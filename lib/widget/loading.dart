import 'package:flutter/cupertino.dart';
import '../core/constant/color.dart';

class LoadingManager extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color color;

  const LoadingManager({
    super.key,
    required this.isLoading,
    required this.child,
    this.color = AppColor.textBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return CupertinoActivityIndicator(
      radius: 10,
      color: color,
    );
  }
}
