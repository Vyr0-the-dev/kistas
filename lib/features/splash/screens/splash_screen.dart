import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  final Widget? onInitializationComplete;
  const SplashScreen({super.key, this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              child: SvgPicture.asset(
                'assets/images/KISTAS.svg',
                width: 220,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  colors.isDark ? colors.textPrimary : colors.primary,
                  BlendMode.srcIn,
                ),
              ),
            )
                .fadeIn(duration: 750.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 750.ms,
                  curve: Curves.easeOut,
                ),
            Transform.translate(
              offset: const Offset(0, -72),
              child: Text(
                'ÇALIŞMA ASİSTANI',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4.5,
                    ),
              ),
            )
                .animate(
                  onComplete: (controller) async {
                    await Future.delayed(const Duration(milliseconds: 220));
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              widget.onInitializationComplete ?? const MainScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 240),
                        ),
                      );
                    }
                  },
                )
                .fadeIn(delay: 220.ms, duration: 550.ms)
                .moveY(
                  begin: 8,
                  end: 0,
                  delay: 220.ms,
                  duration: 550.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
