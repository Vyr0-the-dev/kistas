import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../questions/screens/quick_add_screen.dart';
import '../../questions/screens/topic_summaries_screen.dart';
import '../../settings/screens/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    state?._onTabSelect(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Future<bool> _onWillPop() async {
    final NavigatorState? currentState =
        _navigatorKeys[_currentIndex].currentState;
    if (currentState != null && await currentState.maybePop()) {
      return false;
    }
    if (_currentIndex != 0) {
      _onTabSelect(0);
      return false;
    }
    return true;
  }

  void _onTabSelect(int index) {
    final safeIndex = index.clamp(0, 4);
    if (_currentIndex == safeIndex) {
      _navigatorKeys[safeIndex].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _currentIndex = safeIndex);
  }

  Widget _buildTab(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => child,
        settings: settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: AmbientBackground(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildTab(0, const HomeScreen()),
              _buildTab(1, const TopicSummariesScreen()),
              _buildTab(2, const QuickAddScreen()),
              _buildTab(3, const AnalysisScreen()),
              _buildTab(4, const ProfileScreen()),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          activeIndex: _currentIndex,
          onSelect: _onTabSelect,
        ),
      ),
    );
  }
}
