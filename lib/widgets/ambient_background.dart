import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(); // Reverse yok, sonsuz döngü
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sabit Arkaplan Rengi
        Container(color: AppColors.of(context).background),

        // Hareketli Orblar (Dairesel Yörünge)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * pi; // 0'dan 2π'ye

            return Stack(
              children: [
                // Orb 1: Sağ Üst
                _PositionedOrb(
                  alignment: Alignment(1.2 + 0.2 * cos(t), -1.2 + 0.2 * sin(t)),
                  color: AppColors.of(context).primaryLight,
                  size: 300,
                  opacity: 0.08,
                ),

                // Orb 2: Sol Alt
                _PositionedOrb(
                  alignment: Alignment(-1.2 + 0.3 * cos(t + 2), 1.0 + 0.3 * sin(t + 2)),
                  color: AppColors.of(context).primary,
                  size: 350,
                  opacity: 0.06,
                ),

                // Orb 3: Orta Sağ
                _PositionedOrb(
                  alignment: Alignment(1.3 + 0.2 * sin(t + 4), 0.2 + 0.4 * cos(t + 4)),
                  color: AppColors.of(context).primaryDark,
                  size: 250,
                  opacity: 0.04,
                ),
              ],
            );
          },
        ),

        // İçerik
        widget.child,
      ],
    );
  }
}

class _PositionedOrb extends StatelessWidget {
  const _PositionedOrb({
    required this.alignment,
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}
