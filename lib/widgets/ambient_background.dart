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
                // Orb 1: Sağ Üst - Geniş Eliptik Hareket
                Align(
                  alignment: Alignment(
                    1.0 + 0.3 * cos(t), 
                    -1.0 + 0.3 * sin(t),
                  ),
                  child: _Orb(
                    color: AppColors.of(context).primaryLight,
                    size: 240,
                    opacity: 0.15 + 0.05 * sin(t), // Hafif yanıp sönme
                  ),
                ),

                // Orb 2: Sol Alt - Ters Yön, Daha Yavaş
                Align(
                  alignment: Alignment(
                    -1.0 + 0.4 * cos(t + 2), 
                    0.8 + 0.4 * sin(t + 2), // Faz farkı
                  ),
                  child: _Orb(
                    color: AppColors.of(context).primary,
                    size: 280,
                    opacity: 0.12 + 0.04 * cos(t),
                  ),
                ),

                // Orb 3: Orta Sağ - Dikey Salınım Ağırlıklı
                Align(
                  alignment: Alignment(
                    0.8 + 0.2 * sin(t + 4), 
                    0.2 + 0.5 * cos(t + 4),
                  ),
                  child: _Orb(
                    color: AppColors.of(context).primaryDark,
                    size: 200,
                    opacity: 0.08,
                  ),
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

class _Orb extends StatelessWidget {
  const _Orb({
    required this.color,
    required this.size,
    this.opacity = 0.18,
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
        color: color.withOpacity(opacity.clamp(0.0, 1.0)),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
