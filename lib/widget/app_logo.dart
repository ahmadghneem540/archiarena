import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Image.asset(
          'assets/app_logo.png',
          width: 120,
          height: 132,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

