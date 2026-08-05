import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF262836),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. LOGO
                Animate(
                  child: SvgPicture.asset(
                    'assets/images/KISTAS.svg',
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                )
                .fadeIn(duration: 1000.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 1000.ms,
                  curve: Curves.easeOut,
                ),

                // 2. TAM KONTROL METNİ
                Transform.translate(
                  offset: const Offset(0, -80), 
                  child: const Text(
                    'TAM KONTROL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 10,
                      fontFamily: 'Roboto',
                    ),
                  ),
                )
                .animate(
                  onComplete: (controller) async {
                    // Toplam süreyi 1.25sn (1250ms) yapacak şekilde ayarlandı
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (mounted) {
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                widget.onInitializationComplete ?? const MainScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(milliseconds: 250),
                                          ),
                                        );                    }
                  },
                )
                .fadeIn(delay: 300.ms, duration: 700.ms)
                .moveY(
                  begin: 10, 
                  end: 0, 
                  delay: 300.ms, 
                  duration: 700.ms, 
                  curve: Curves.easeOut
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}