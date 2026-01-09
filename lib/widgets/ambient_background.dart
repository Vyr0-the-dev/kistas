import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sabit Arkaplan Rengi
        Container(color: AppColors.of(context).background),
        
        // Üst Sağ Orb
        Positioned(
          top: -50,
          right: -50,
          child: _Orb(
            color: AppColors.of(context).primaryLight, 
            size: 200, 
            opacity: 0.15,
          ),
        ),

        // Alt Sol Orb
        Positioned(
          bottom: 100,
          left: -60,
          child: _Orb(
            color: AppColors.of(context).primary, 
            size: 240, 
            opacity: 0.12,
          ),
        ),

        // Orta Sağ (Hafif dolgu)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -80,
          child: _Orb(
            color: AppColors.of(context).primaryDark, 
            size: 180, 
            opacity: 0.08,
          ),
        ),

        // İçerik
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.color, 
    required this.size, 
    this.opacity = 0.18
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
