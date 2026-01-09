import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = const BorderRadius.all(Radius.circular(22)),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.glass,
            borderRadius: radius,
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}
