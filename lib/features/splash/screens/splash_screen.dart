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
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 1000.ms,
                  curve: Curves.easeOutQuart,
                ),

                // 2. TAM KONTROL METNİ
                // Transform.translate ile yazıyı yukarı (-50px) çekiyoruz
                // Böylece SVG'nin altındaki boşluk görsel olarak kapanıyor.
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
                    // Animasyon bittikten sonra 1 saniye bekle
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                widget.onInitializationComplete ?? const MainScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              const curve = Curves.easeOutExpo; // Daha dinamik bir eğri
                                              final curvedAnimation = CurvedAnimation(
                                                parent: animation,
                                                curve: curve,
                                              );
                      
                                              return FadeTransition(
                                                opacity: curvedAnimation,
                                                child: ScaleTransition(
                                                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation), // Daha belirgin büyüme
                                                  child: child,
                                                ),
                                              );
                                            },
                                            transitionDuration: const Duration(milliseconds: 800), // Süreyi biraz uzattık
                                          ),
                                        );                    }
                  },
                )
                .fadeIn(delay: 800.ms, duration: 1000.ms)
                .moveY(
                  begin: 15, 
                  end: 0, 
                  delay: 800.ms, 
                  duration: 1000.ms, 
                  curve: Curves.easeOutCirc
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}