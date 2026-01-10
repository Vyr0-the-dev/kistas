import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../analysis/screens/analysis_screen.dart';
import 'home_screen.dart';
import '../../settings/screens/profile_screen.dart';
import '../../questions/screens/quick_add_screen.dart';
import '../../questions/screens/topic_summaries_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            HomeScreen(),
            TopicSummariesScreen(),
            QuickAddScreen(),
            AnalysisScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        activeIndex: _currentIndex,
        onSelect: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}