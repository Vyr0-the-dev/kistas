import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const P3RotaApp());
}

class P3RotaApp extends StatelessWidget {
  const P3RotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P3 Rota',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
