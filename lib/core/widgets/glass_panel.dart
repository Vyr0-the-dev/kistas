import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Clean matte study card container.
/// Keeps the `GlassPanel` name for backward compatibility across screens while
/// rendering crisp, glare-free paper/slate surfaces without heavy BackdropFilter.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius radius;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? colors.border),
        boxShadow: colors.isDark
            ? const []
            : [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
