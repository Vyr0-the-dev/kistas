import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Calm matte desk surface background.
/// Replaces the old continuously animated orb backdrop for better eye comfort
/// and smoother frame pacing during long study sessions.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.of(context).background,
      child: child,
    );
  }
}
