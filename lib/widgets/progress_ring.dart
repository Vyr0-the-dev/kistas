import 'dart:math';

import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.child,
    this.centerColor,
    this.innerPadding = 24,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final Color? centerColor;
  final double innerPadding;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: clampedValue),
        duration: duration,
        curve: curve,
        builder: (context, animatedValue, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _ProgressRingPainter(
                  value: animatedValue,
                  strokeWidth: strokeWidth,
                  trackColor: trackColor,
                  progressColor: progressColor,
                ),
              ),
              if (centerColor != null)
                Container(
                  width: max(0, size - strokeWidth * 2 - innerPadding),
                  height: max(0, size - strokeWidth * 2 - innerPadding),
                  decoration: BoxDecoration(
                    color: centerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progressColor;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return value != oldDelegate.value ||
        strokeWidth != oldDelegate.strokeWidth ||
        trackColor != oldDelegate.trackColor ||
        progressColor != oldDelegate.progressColor;
  }
}
