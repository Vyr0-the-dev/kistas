import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen for now, will remove later

class SplashScreen extends StatefulWidget {
  final Widget? onInitializationComplete;
  const SplashScreen({super.key, this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {}); // Simulate some loading
    if (mounted && widget.onInitializationComplete != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.onInitializationComplete!),
      );
    } else if (mounted) {
      // Fallback if no specific route is provided
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}