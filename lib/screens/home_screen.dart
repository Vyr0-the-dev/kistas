import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../services/app_repository.dart';
import '../services/gemini_client.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_loading_dialog.dart';
import '../widgets/ai_response_dialog.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/in_app_notice.dart';
import '../widgets/progress_ring.dart';
import 'analysis_screen.dart';
import 'entry_wizard_screen.dart';
import 'focus_timer_screen.dart';
import 'profile_screen.dart';
import 'quick_add_screen.dart';
import 'topic_summaries_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedRange = 0;
  String? _lastReminderCheckKey;
  Timer? _focusTimer;
  int _focusRemaining = 25 * 60;
  bool _focusRunning = false;
  final ValueNotifier<int> _focusRemainingNotifier = ValueNotifier(25 * 60);
  final ValueNotifier<bool> _focusRunningNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: ValueListenableBuilder<List<QuestionEntry>>(
          valueListenable: repository.questionEntries,
          builder: (context, questionEntries, _) {
            return ValueListenableBuilder<List<MockExam>>(
              valueListenable: repository.mockExams,
              builder: (context, mockExams, __) {
                return ValueListenableBuilder<int>(
                  valueListenable: repository.dailyGoal,
                  builder: (context, dailyGoal, ___) {
                    final avgNet = _averageNet(mockExams);
                    final activity = _buildActivity(context, questionEntries, mockExams);
                    final focusTopic =
                        _pickFocusTopic(repository, questionEntries);
                    final isEmpty =
                        questionEntries.isEmpty && mockExams.isEmpty;
                    final todayTotal = _countTodayQuestions(questionEntries);

                    final now = DateTime.now();
                    final reminderKey =
                        '${now.year}-${now.month}-${now.day}-$todayTotal-$dailyGoal';
                    if (_lastReminderCheckKey != reminderKey) {
                      _lastReminderCheckKey = reminderKey;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _maybeTriggerReminder(
                          repository,
                          todayTotal,
                          dailyGoal,
                        );
                      });
                    }

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _Header(
                            selectedRange: _selectedRange,
                            onRangeChanged: (value) {
                              setState(() => _selectedRange = value);
                            },
                            onNotificationsTap: () =>
                                _showNotificationsSheet(context, repository),
                          ),
                        ),
                        if (isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: _EmptyStateHero(
                                onQuickAdd: () => _openEntry(context),
                              ),
                            ),
                          ),
                    SliverToBoxAdapter(
                      child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: _FocusCard(
                              focusTopic: focusTopic,
                              hasData: questionEntries.isNotEmpty,
                              todayTotal: todayTotal,
                              dailyGoal: dailyGoal,
                              onAiSuggestion: () => _requestAiSuggestion(
                                context,
                                repository,
                                questionEntries,
                                focusTopic,
                                todayTotal,
                                dailyGoal,
                                avgNet,
                              ),
                              onQuickAdd: () => _openEntry(context),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: _AiGoalPanel(
                              repository: repository,
                              onOpenProfile: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: _PerformanceRow(
                              todayTotal: todayTotal,
                              dailyGoal: dailyGoal,
                              avgNet: avgNet,
                              accuracy: _overallAccuracy(questionEntries),
                              totalQuestions: _totalQuestions(questionEntries),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            child: _StreakCard(
                              streak: _calculateStreak(
                                questionEntries,
                                mockExams,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: _DailyTasksCard(
                              tasks: _buildDailyTasks(
                                questionEntries,
                                focusTopic,
                                todayTotal,
                                dailyGoal,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: _FocusTimerCard(
                              remainingSeconds: _focusRemaining,
                              running: _focusRunning,
                              onStart: () {
                                _startFocusTimer();
                                _openFocusTimerScreen();
                              },
                              onPause: _pauseFocusTimer,
                              onReset: _resetFocusTimer,
                              onOpen: () => _showFocusTimerSheet(context),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: _AiCheckInCard(
                              onStart: () => _requestAiCheckIn(
                                context,
                                repository,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: _ActivitySection(
                              activity: activity,
                              onShowAll: () => _showActivitySheet(
                                context,
                                questionEntries,
                                mockExams,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                            child: _ReviewScheduleCard(
                              schedule: _buildReviewSchedule(repository),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 140)),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: 0,
        onSelect: (index) => _navigateFromNav(context, index),
      ),
    );
  }

  void _openEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EntryWizardScreen(
          type: EntryType.question,
        ),
      ),
    );
  }

  void _navigateFromNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TopicSummariesScreen()),
        );
        return;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const QuickAddScreen()),
        );
        return;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AnalysisScreen()),
        );
        return;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        return;
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _focusRemainingNotifier.dispose();
    _focusRunningNotifier.dispose();
    super.dispose();
  }

  void _startFocusTimer() {
    if (_focusRunning) {
      return;
    }
    setState(() => _focusRunning = true);
    _focusRunningNotifier.value = true;
    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_focusRemaining <= 1) {
        timer.cancel();
        setState(() {
          _focusRunning = false;
          _focusRemaining = 0;
        });
        _focusRunningNotifier.value = false;
        _focusRemainingNotifier.value = 0;
        return;
      }
      setState(() => _focusRemaining -= 1);
      _focusRemainingNotifier.value = _focusRemaining;
    });
  }

  void _pauseFocusTimer() {
    _focusTimer?.cancel();
    setState(() => _focusRunning = false);
    _focusRunningNotifier.value = false;
  }

  void _resetFocusTimer() {
    _focusTimer?.cancel();
    setState(() {
      _focusRunning = false;
      _focusRemaining = 25 * 60;
    });
    _focusRunningNotifier.value = false;
    _focusRemainingNotifier.value = _focusRemaining;
  }

  void _setFocusDuration(int minutes) {
    _focusTimer?.cancel();
    setState(() {
      _focusRunning = false;
      _focusRemaining = minutes * 60;
    });
    _focusRunningNotifier.value = false;
    _focusRemainingNotifier.value = _focusRemaining;
  }

  void _openFocusTimerScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FocusTimerScreen(
          remainingSeconds: _focusRemainingNotifier,
          running: _focusRunningNotifier,
          onPause: _pauseFocusTimer,
          onResume: _startFocusTimer,
          onReset: _resetFocusTimer,
        ),
      ),
    );
  }

  void _showFocusTimerSheet(BuildContext context) {
    final currentMinutes = max(5, (_focusRemaining / 60).round());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        int minutes = currentMinutes;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Odak Zamanlayıcı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      _formatTimer(minutes * 60),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.of(context).primary,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: AppColors.of(context).primary,
                      ),
                      child: Slider(
                        value: minutes.toDouble(),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        label: '$minutes dk',
                        onChanged: (value) {
                          setSheetState(() {
                            minutes = value.round();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [15, 25, 30, 45, 60, 90]
                          .map(
                            (preset) => _FocusPresetChip(
                              minutes: preset,
                              selected: minutes == preset,
                              onTap: () {
                                setSheetState(() {
                                  minutes = preset;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _setFocusDuration(minutes);
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text('Süreyi Uygula'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _setFocusDuration(minutes);
                              _startFocusTimer();
                              Navigator.of(sheetContext).pop();
                              if (!mounted) {
                                return;
                              }
                              _openFocusTimerScreen();
                            },
                            child: Text('Başlat'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _focusRunning ? _pauseFocusTimer : null,
                            child: Text('Duraklat'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _resetFocusTimer,
                            child: Text('Sıfırla'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedRange,
    required this.onRangeChanged,
    this.onNotificationsTap,
  });

  final int selectedRange;
  final ValueChanged<int> onRangeChanged;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.of(context).background.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba, Öğrenci',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.of(context).textSecondary,
                            letterSpacing: 1,
                          ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      _formatToday(now),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.of(context).textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onNotificationsTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.of(context).surfaceLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _SegmentedButton(
                  label: 'Bugün',
                  active: selectedRange == 0,
                  onTap: () => onRangeChanged(0),
                ),
                _SegmentedButton(
                  label: '7 Gün',
                  active: selectedRange == 1,
                  onTap: () => onRangeChanged(1),
                ),
                _SegmentedButton(
                  label: '30 Gün',
                  active: selectedRange == 2,
                  onTap: () => onRangeChanged(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.of(context).surfaceLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.of(context).textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.focusTopic,
    required this.hasData,
    required this.todayTotal,
    required this.dailyGoal,
    required this.onAiSuggestion,
    required this.onQuickAdd,
  });

  final TopicProgress? focusTopic;
  final bool hasData;
  final int todayTotal;
  final int dailyGoal;
  final VoidCallback onAiSuggestion;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final remaining = (dailyGoal - todayTotal).clamp(0, dailyGoal);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: hasData && focusTopic != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.explore,
                        color: AppColors.of(context).primary,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Konu Pusulası',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.of(context).primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '${focusTopic!.topic.subject} - ${focusTopic!.topic.title}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 12),
                Text(
                  remaining == 0
                      ? 'Hedef tamamlandı'
                      : 'Önerilen: $remaining soru çöz',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: focusTopic!.progressRatio,
                    minHeight: 6,
                    backgroundColor: AppColors.of(context).surfaceLight,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.of(context).primary),
                  ),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onAiSuggestion,
                      icon: Icon(Icons.auto_awesome,
                          size: 16, color: AppColors.of(context).primary),
                      label: Text(
                        'AI Mentor',
                        style: TextStyle(color: AppColors.of(context).primary),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: onQuickAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      icon: Icon(Icons.arrow_forward, size: 18),
                      label: Text('Başla'),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Henüz veri yok',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bugün ilk kaydını ekleyerek paneli doldur.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
                SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onQuickAdd,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.of(context).primary,
                    side: BorderSide(color: AppColors.of(context).primary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(Icons.bolt),
                  label: Text('Hızlı Kayıt Aç'),
                ),
              ],
            ),
    );
  }
}

class _EmptyStateHero extends StatelessWidget {
  const _EmptyStateHero({required this.onQuickAdd});

  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.of(context).surfaceLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.insights, color: AppColors.of(context).primary),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Henüz veri yok',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6),
                Text(
                  'İlk soru veya denemeni ekleyerek dashboardu doldur.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onQuickAdd,
                  icon: Icon(Icons.bolt, color: AppColors.of(context).primary),
                  label: Text(
                    'Hızlı Ekle',
                    style: TextStyle(color: AppColors.of(context).primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({this.label = '', this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.of(context).surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.of(context).surface),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color == null ? AppColors.of(context).textSecondary : Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AiGoalPanel extends StatelessWidget {
  const _AiGoalPanel({
    required this.repository,
    required this.onOpenProfile,
  });

  final AppRepository repository;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: repository.aiGoalTargets,
      builder: (context, targets, _) {
        return ValueListenableBuilder<String>(
          valueListenable: repository.aiGoalCadence,
          builder: (context, cadence, __) {
            return ValueListenableBuilder<DateTime?>(
              valueListenable: repository.aiGoalUpdatedAt,
              builder: (context, updatedAt, ___) {
                final displayValue = _pickCadenceValue(targets, cadence);
                final cadenceLabel = _cadenceLabel(cadence);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.of(context).primary.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppColors.of(context).primary,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Hedef Panosu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Text(
                                  updatedAt == null
                                      ? 'Henüz hedef oluşturulmadı.'
                                      : 'Son güncelleme: ${_formatDateTime(updatedAt)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.of(context).textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: onOpenProfile,
                            child: Text('Düzenle'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _AiGoalValueCard(
                              label: cadenceLabel,
                              value: displayValue == null
                                  ? '—'
                                  : displayValue.toString(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _AiGoalValueCard(
                              label: 'Günlük',
                              value: targets['daily']?.toString() ?? '—',
                              isMuted: cadence != 'daily',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _AiGoalValueCard(
                              label: 'Haftalık',
                              value: targets['weekly']?.toString() ?? '—',
                              isMuted: cadence != 'weekly',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _AiGoalValueCard(
                              label: 'Aylık',
                              value: targets['monthly']?.toString() ?? '—',
                              isMuted: cadence != 'monthly',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _requestAiPlan(context, repository),
                          icon: Icon(Icons.psychology_alt),
                          label: Text('AI Program Hazırla'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AiGoalValueCard extends StatelessWidget {
  const _AiGoalValueCard({
    required this.label,
    required this.value,
    this.isMuted = false,
  });

  final String label;
  final String value;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isMuted ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
          ),
          SizedBox(height: 4),
          Text(
            '$value soru',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.of(context).primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_fire_department,
                color: AppColors.of(context).primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Çalışma Serisi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  streak == 0 ? 'Bugün başla' : '$streak gün üst üste',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            streak.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailyTasksCard extends StatelessWidget {
  const _DailyTasksCard({required this.tasks});

  final List<String> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günlük Görevler',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8),
          if (tasks.isEmpty)
            Text(
              'Henüz görev oluşturulmadı.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
            )
          else
            Column(
              children: tasks
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.of(context).primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ReviewScheduleItem {
  const _ReviewScheduleItem({
    required this.title,
    required this.subject,
    required this.date,
  });

  final String title;
  final String subject;
  final DateTime date;
}

class _ReviewScheduleCard extends StatelessWidget {
  const _ReviewScheduleCard({required this.schedule});

  final List<_ReviewScheduleItem> schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tekrar Takvimi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8),
          if (schedule.isEmpty)
            Text(
              'Henüz tekrar planı oluşmadı.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
            )
          else
            Column(
              children: schedule
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.subject} • ${item.title}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ),
                          Text(
                            _formatShortDate(item.date),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.of(context).textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _FocusTimerCard extends StatelessWidget {
  const _FocusTimerCard({
    required this.remainingSeconds,
    required this.running,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onOpen,
  });

  final int remainingSeconds;
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.of(context).primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.timer, color: AppColors.of(context).primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Odak Zamanlayıcı',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    _formatTimer(remainingSeconds),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            if (!running)
              IconButton(
                onPressed: onStart,
                icon: Icon(Icons.play_arrow, color: Colors.white),
              )
            else
              IconButton(
                onPressed: onPause,
                icon: Icon(Icons.pause, color: Colors.white),
              ),
            IconButton(
              onPressed: onReset,
              icon: Icon(Icons.replay, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusPresetChip extends StatelessWidget {
  const _FocusPresetChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.of(context).primary.withOpacity(0.25)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.of(context).primary.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          '$minutes dk',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _AiCheckInCard extends StatelessWidget {
  const _AiCheckInCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.of(context).primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.psychology_alt, color: AppColors.of(context).primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Mini Koç',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Kısa check-in ile yönlendirme al.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onStart,
            child: Text('Başlat'),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({
    required this.todayTotal,
    required this.dailyGoal,
    required this.avgNet,
    required this.accuracy,
    required this.totalQuestions,
  });

  final int todayTotal;
  final int dailyGoal;
  final double? avgNet;
  final double? accuracy;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _RingCard(
            solved: todayTotal,
            dailyGoal: dailyGoal,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _StatCard(
                label: 'Ortalama Net',
                value: avgNet == null ? '—' : avgNet!.toStringAsFixed(1),
                trailing: avgNet == null
                    ? null
                    : _TrendChip(
                        delta: avgNet! >= 0 ? '+${avgNet!.toStringAsFixed(1)}' :
                            avgNet!.toStringAsFixed(1),
                        positive: avgNet! >= 0,
                      ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Doğruluk',
                      value: accuracy == null
                          ? '—'
                          : '%${(accuracy! * 100).round()}',
                      valueColor: AppColors.of(context).primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Toplam',
                      value: totalQuestions == 0
                          ? '—'
                          : totalQuestions.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingCard extends StatelessWidget {
  const _RingCard({required this.solved, required this.dailyGoal});

  final int solved;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final safeGoal = max(dailyGoal, 1);
    final ratio = (solved / safeGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
                ProgressRing(
                  value: ratio,
                  size: 156,
                  strokeWidth: 12,
                  trackColor: AppColors.of(context).surfaceLight,
                  progressColor: AppColors.of(context).primary,
                  centerColor: AppColors.of(context).surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: Text(
                          solved.toString(),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '/$dailyGoal',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.of(context).textSecondary,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 12),
          Text(
            'Günlük Soru',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.delta, required this.positive});

  final String delta;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.of(context).success : AppColors.of(context).danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            delta,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.of(context).textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activity, required this.onShowAll});

  final List<_ActivityItem> activity;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Aktiviteler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: onShowAll,
              child: Text(
                'Tümü',
                style: TextStyle(color: AppColors.of(context).primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        if (activity.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.timeline, color: Colors.white54),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Henüz etkinlik yok. İlk kaydın burada görünecek.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.of(context).textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: activity
                .map(
                  (item) => _ActivityCard(item: item),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.of(context).surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: item.accentColor.withOpacity(0.5)),
            ),
            child: Icon(item.icon, color: item.accentColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.timeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
              ),
              SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: item.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.activeIndex, required this.onSelect});

  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(activeIndex: activeIndex, onSelect: onSelect);
  }
}

class _ActivityItem {
  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.timestamp,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final DateTime timestamp;
}

List<_ActivityItem> _buildActivity(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
) {
  final items = <_ActivityItem>[];

  for (final entry in questionEntries) {
    items.add(
      _ActivityItem(
        title: entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic,
        subtitle: '${entry.subject} • ${entry.total} soru',
        timeLabel: _formatTime(entry.createdAt),
        badge: '${entry.correct} doğru',
        icon: Icons.quiz,
        accentColor: AppColors.of(context).primary,
        timestamp: entry.createdAt,
      ),
    );
  }

  for (final exam in mockExams) {
    items.add(
      _ActivityItem(
        title: exam.title.isEmpty ? 'Deneme' : exam.title,
        subtitle: '${exam.totalNet.toStringAsFixed(1)} net',
        timeLabel: _formatTime(exam.createdAt),
        badge: '${exam.totalNet.toStringAsFixed(1)} net',
        icon: Icons.school,
        accentColor: AppColors.of(context).success,
        timestamp: exam.createdAt,
      ),
    );
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  if (items.length > 3) {
    return items.sublist(0, 3);
  }
  return items;
}

List<_ActivityItem> _buildActivityAll(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
) {
  final items = <_ActivityItem>[];

  for (final entry in questionEntries) {
    items.add(
      _ActivityItem(
        title: entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic,
        subtitle: '${entry.subject} • ${entry.total} soru',
        timeLabel: _formatTime(entry.createdAt),
        badge: '${entry.correct} doğru',
        icon: Icons.quiz,
        accentColor: AppColors.of(context).primary,
        timestamp: entry.createdAt,
      ),
    );
  }

  for (final exam in mockExams) {
    items.add(
      _ActivityItem(
        title: exam.title.isEmpty ? 'Deneme' : exam.title,
        subtitle: '${exam.totalNet.toStringAsFixed(1)} net',
        timeLabel: _formatTime(exam.createdAt),
        badge: '${exam.totalNet.toStringAsFixed(1)} net',
        icon: Icons.school,
        accentColor: AppColors.of(context).success,
        timestamp: exam.createdAt,
      ),
    );
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}

void _showActivitySheet(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
) {
  final items = _buildActivityAll(context, questionEntries, mockExams);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Tüm Aktiviteler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz kayıt yok.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white54,
                                    ),
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (_, index) => _ActivityCard(
                            item: items[index],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

int _countTodayQuestions(List<QuestionEntry> entries) {
  final now = DateTime.now();
  return entries
      .where((entry) => _isSameDay(entry.createdAt, now))
      .fold(0, (sum, entry) => sum + entry.total);
}

double? _averageNet(List<MockExam> exams) {
  if (exams.isEmpty) {
    return null;
  }
  final total = exams.fold<double>(0, (sum, item) => sum + item.totalNet);
  return total / exams.length;
}

double? _overallAccuracy(List<QuestionEntry> entries) {
  if (entries.isEmpty) {
    return null;
  }
  final correct = entries.fold<int>(0, (sum, entry) => sum + entry.correct);
  final total = entries.fold<int>(0, (sum, entry) => sum + entry.total);
  if (total == 0) {
    return null;
  }
  return correct / total;
}

int _totalQuestions(List<QuestionEntry> entries) {
  return entries.fold<int>(0, (sum, entry) => sum + entry.total);
}

TopicProgress? _pickFocusTopic(
  AppRepository repository,
  List<QuestionEntry> entries,
) {
  if (entries.isEmpty) {
    return null;
  }
  final progress = repository.buildTopicProgress();
  progress.sort((a, b) {
    if (a.lastStudied == null && b.lastStudied == null) {
      return 0;
    }
    if (a.lastStudied == null) {
      return 1;
    }
    if (b.lastStudied == null) {
      return -1;
    }
    return b.lastStudied!.compareTo(a.lastStudied!);
  });
  return progress.firstWhere(
    (item) => item.totalQuestions > 0,
    orElse: () => progress.first,
  );
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatToday(DateTime date) {
  final months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  return 'Bugün, ${date.day} ${months[date.month - 1]}';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day.$month ${hour}:$minute';
}

String _cadenceLabel(String cadence) {
  switch (cadence) {
    case 'weekly':
      return 'Haftalık';
    case 'monthly':
      return 'Aylık';
    default:
      return 'Günlük';
  }
}

int? _pickCadenceValue(Map<String, int> targets, String cadence) {
  switch (cadence) {
    case 'weekly':
      return targets['weekly'];
    case 'monthly':
      return targets['monthly'];
    default:
      return targets['daily'];
  }
}

Future<void> _maybeTriggerReminder(
  AppRepository repository,
  int todayTotal,
  int dailyGoal,
) async {
  if (!repository.reminderEnabled.value) {
    return;
  }
  if (todayTotal >= dailyGoal) {
    return;
  }
  final now = DateTime.now();
  final lastShown = repository.reminderLastShown.value;
  if (lastShown != null && _isSameDay(lastShown, now)) {
    return;
  }
  final reminderTime = _parseReminderTime(repository.reminderTime.value);
  if (reminderTime == null) {
    return;
  }
  final trigger = DateTime(
    now.year,
    now.month,
    now.day,
    reminderTime.hour,
    reminderTime.minute,
  );
  if (now.isBefore(trigger)) {
    return;
  }
  await repository.addNotification(
    AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Günlük Hedef Hatırlatma',
      body: 'Bugün ${dailyGoal - todayTotal} soru daha çözmen kaldı.',
      createdAt: now,
    ),
  );
  await NotificationService.showReminderNow(
    'Bugün ${dailyGoal - todayTotal} soru daha çözmen kaldı.',
  );
  await repository.setReminderLastShown(now);
}

TimeOfDay? _parseReminderTime(String raw) {
  final parts = raw.split(':');
  if (parts.length != 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

int _calculateStreak(List<QuestionEntry> entries, List<MockExam> exams) {
  final activityDates = <DateTime>{};
  for (final entry in entries) {
    activityDates.add(DateTime(entry.createdAt.year, entry.createdAt.month,
        entry.createdAt.day));
  }
  for (final exam in exams) {
    activityDates.add(DateTime(
        exam.createdAt.year, exam.createdAt.month, exam.createdAt.day));
  }
  if (activityDates.isEmpty) {
    return 0;
  }
  var streak = 0;
  var current = DateTime.now();
  while (true) {
    final normalized = DateTime(current.year, current.month, current.day);
    if (!activityDates.contains(normalized)) {
      break;
    }
    streak += 1;
    current = current.subtract(const Duration(days: 1));
  }
  return streak;
}

List<String> _buildDailyTasks(
  List<QuestionEntry> entries,
  TopicProgress? focusTopic,
  int todayTotal,
  int dailyGoal,
) {
  final tasks = <String>[];
  final remaining = max(dailyGoal - todayTotal, 0);
  if (remaining > 0) {
    tasks.add('Bugün $remaining soru daha çöz.');
  }
  if (focusTopic != null) {
    tasks.add('${focusTopic.topic.title} için 20 soru odaklı tekrar yap.');
  }
  final minutes = entries
      .where((e) => _isSameDay(e.createdAt, DateTime.now()))
      .fold<int>(0, (sum, e) => sum + e.minutes);
  if (minutes < 30) {
    tasks.add('En az 30 dk çalışma süresi tamamla.');
  }
  return tasks;
}

List<_ReviewScheduleItem> _buildReviewSchedule(AppRepository repository) {
  final progress = repository.buildTopicProgress();
  final items = <_ReviewScheduleItem>[];
  for (final topic in progress) {
    if (topic.lastStudied == null || topic.totalQuestions == 0) {
      continue;
    }
    final interval = _reviewInterval(topic.accuracy);
    final nextDate = topic.lastStudied!.add(Duration(days: interval));
    items.add(
      _ReviewScheduleItem(
        title: topic.topic.title,
        subject: topic.topic.subject,
        date: nextDate,
      ),
    );
  }
  items.sort((a, b) => a.date.compareTo(b.date));
  return items.take(3).toList();
}

int _reviewInterval(double accuracy) {
  if (accuracy < 0.5) {
    return 1;
  }
  if (accuracy < 0.7) {
    return 3;
  }
  if (accuracy < 0.85) {
    return 7;
  }
  return 14;
}

String _formatShortDate(DateTime date) {
  return '${date.day}.${date.month}';
}

String _formatTimer(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

void _showNotificationsSheet(
  BuildContext context,
  AppRepository repository,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ValueListenableBuilder(
        valueListenable: repository.notifications,
        builder: (context, notifications, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bildirimler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: notifications.isEmpty
                          ? null
                          : () => repository.markAllNotificationsRead(),
                      child: Text('Okundu Yap'),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: notifications.isEmpty
                          ? null
                          : () => repository.clearNotifications(),
                      child: Text('Temizle'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (notifications.isEmpty)
                  Text(
                    'Henüz bildirim yok.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.of(context).textSecondary,
                        ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white12),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return ListTile(
                          onTap: () =>
                              repository.markNotificationRead(item.id),
                          contentPadding: EdgeInsets.zero,
                          leading: item.unread
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.of(context).primary,
                                  ),
                                )
                              : SizedBox(width: 8),
                          title: Text(
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          subtitle: Text(
                            item.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.of(context).textSecondary),
                          ),
                          trailing: Text(
                            _formatTime(item.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.of(context).textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showSnack(BuildContext context, String message) {
  InAppNotice.show(context, message);
}

Future<void> _requestAiSuggestion(
  BuildContext context,
  AppRepository repository,
  List<QuestionEntry> entries,
  TopicProgress? focusTopic,
  int todayTotal,
  int dailyGoal,
  double? avgNet,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  final targets = repository.aiGoalTargets.value;
  final cadence = repository.aiGoalCadence.value;
  final recentTotal = entries
      .where((e) => DateTime.now().difference(e.createdAt).inDays < 7)
      .fold<int>(0, (sum, e) => sum + e.total);
  final focusLabel = focusTopic == null
      ? 'Henüz net bir odak yok.'
      : '${focusTopic.topic.subject} - ${focusTopic.topic.title}';

  final prompt = '''
KPSS P3 için mentor gibi yol gösterici öneri ver.
Veriler:
- Günlük hedef: $dailyGoal soru
- Seçili kadans: ${_cadenceLabel(cadence)}
- AI hedefleri (günlük/haftalık/aylık): ${targets['daily'] ?? '-'} / ${targets['weekly'] ?? '-'} / ${targets['monthly'] ?? '-'}
- Bugün çözülen: $todayTotal soru
- Son 7 gün toplam: $recentTotal soru
- Odak konu: $focusLabel
- Ortalama net: ${avgNet == null ? '-' : avgNet.toStringAsFixed(1)}
İstenen çıktı: 3 maddelik mentor notu (1) durum özeti (2) bugün öncelik (3) net/konu odaklı öneri.
''';

  final closeLoading = _showLoadingDialog(context, 'AI öneri hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;
    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();
    
    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop(); // Handled by closeLoading
    if (repository.aiNotificationsEnabled.value) {
      await repository.addNotification(
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'AI Mentor Notu',
          body: result.length > 140 ? '${result.substring(0, 140)}…' : result,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (!context.mounted) {
      return;
    }
    await _showResultDialog(context, 'AI Öneri', result);
  } catch (error) {
    closeLoading();
    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    _showSnack(context, 'AI öneri alınamadı.');
  }
}

Future<void> _requestAiPlan(
  BuildContext context,
  AppRepository repository,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }
  final userNeed = await _askAiPlanInput(context);
  if (userNeed == null || userNeed.trim().isEmpty) {
    return;
  }

  final entries = repository.questionEntries.value;
  final exams = repository.mockExams.value;
  final now = DateTime.now();
  final last7 = entries
      .where((e) => now.difference(e.createdAt).inDays < 7)
      .fold<int>(0, (sum, e) => sum + e.total);
  final todayTotal =
      entries.where((e) => _isSameDay(e.createdAt, now)).fold<int>(
            0,
            (sum, e) => sum + e.total,
          );
  final avgNet = _averageNet(exams);
  final targets = repository.aiGoalTargets.value;
  final cadence = repository.aiGoalCadence.value;

  final prompt = '''
Sen KPSS P3 için mentörsün. Kullanıcının derdine göre net, uygulanabilir bir çalışma programı hazırla.
Kullanıcı ihtiyacı: ${userNeed.trim()}
Özet veriler:
- Bugün çözülen: $todayTotal soru
- Son 7 gün toplam: $last7 soru
- Ortalama net: ${avgNet == null ? '-' : avgNet.toStringAsFixed(1)}
- AI hedefleri (günlük/haftalık/aylık): ${targets['daily'] ?? '-'} / ${targets['weekly'] ?? '-'} / ${targets['monthly'] ?? '-'}
- Seçili kadans: ${_cadenceLabel(cadence)}
Çıktı formatı:
1) Kısa durum özeti (1-2 cümle)
2) 7 günlük program (gün gün maddeler halinde)
3) Haftalık hedef ve takip kuralı (2 madde)
4) Motivasyon notu (1 cümle)
''';

  final closeLoading = _showLoadingDialog(context, 'AI program hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;
    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    await repository.setAiProgram(result);
    if (repository.aiNotificationsEnabled.value) {
      await repository.addNotification(
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'AI Programı',
          body: result.length > 140 ? '${result.substring(0, 140)}…' : result,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (!context.mounted) {
      return;
    }
    await _showResultDialog(context, 'AI Programı', result);
  } catch (_) {
    closeLoading();
    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    _showSnack(context, 'AI program alınamadı.');
  }
}

Future<void> _requestAiCheckIn(
  BuildContext context,
  AppRepository repository,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }
  final input = await _askCheckInInput(context);
  if (input == null) {
    return;
  }

  final prompt = '''
Sen KPSS P3 koçusun. Kullanıcının check-in cevaplarına göre yönlendirme ve günlük hedef öner.
Cevaplar:
- Bugün moralin: ${input.mood}
- Bugün engel: ${input.blocker}
- Bugün hedef: ${input.goal}
İstenen çıktı: Tek satır JSON.
Şema: {"dailyGoal":int,"tasks":[string,string,string],"note":"kısa motivasyon"}
Not: dailyGoal 20-300 aralığında olsun.
''';

  final closeLoading = _showLoadingDialog(context, 'AI koç hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;
    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    final parsed = _parseAiCoachResult(result);
    if (repository.aiNotificationsEnabled.value) {
      await repository.addNotification(
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'AI Koç',
          body: parsed == null
              ? (result.length > 140 ? '${result.substring(0, 140)}…' : result)
              : parsed.summary,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (!context.mounted) {
      return;
    }
    if (parsed == null) {
      await _showResultDialog(context, 'AI Koç', result);
      return;
    }
    await _showAiCoachDialog(context, repository, parsed);
  } catch (_) {
    closeLoading();
    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    _showSnack(context, 'AI koç alınamadı.');
  }
}

Future<void> _showAiCoachDialog(
  BuildContext context,
  AppRepository repository,
  _AiCoachResult result,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('AI Koç Planı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Önerilen günlük hedef: ${result.dailyGoal} soru'),
            SizedBox(height: 8),
            ...result.tasks.map((task) => Text('• $task')),
            SizedBox(height: 8),
            Text(result.note),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hedefe Uygula'),
          ),
        ],
      );
    },
  );
  if (!context.mounted) {
    return;
  }
  if (confirmed == true) {
    await repository.setDailyGoal(result.dailyGoal);
    if (!context.mounted) {
      return;
    }
    _showSnack(context, 'Günlük hedef güncellendi.');
  }
}

_AiCoachResult? _parseAiCoachResult(String raw) {
  final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
  if (match == null) {
    return null;
  }
  try {
    final decoded = jsonDecode(match.group(0)!);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final dailyGoal = _readInt(decoded['dailyGoal']);
    if (dailyGoal == null) {
      return null;
    }
    final tasksRaw = decoded['tasks'];
    final tasks = <String>[];
    if (tasksRaw is List) {
      for (final item in tasksRaw) {
        if (item is String && item.trim().isNotEmpty) {
          tasks.add(item.trim());
        }
      }
    }
    final note = decoded['note']?.toString().trim() ?? '';
    return _AiCoachResult(
      dailyGoal: dailyGoal,
      tasks: tasks.isEmpty ? ['Bugün 30 soru hedefle.'] : tasks,
      note: note.isEmpty ? 'Bugün küçük bir adım bile yeter.' : note,
    );
  } catch (_) {
    return null;
  }
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned);
  }
  return null;
}

class _AiCoachResult {
  const _AiCoachResult({
    required this.dailyGoal,
    required this.tasks,
    required this.note,
  });

  final int dailyGoal;
  final List<String> tasks;
  final String note;

  String get summary => 'Günlük hedef: $dailyGoal • ${tasks.join(' / ')}';
}

Future<_CheckInInput?> _askCheckInInput(BuildContext context) async {
  final moodController = TextEditingController();
  final blockerController = TextEditingController();
  final goalController = TextEditingController();
  final result = await showDialog<_CheckInInput>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('AI Mini Koç'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: moodController,
                decoration: InputDecoration(
                  hintText: 'Bugün moralin nasıl?',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: blockerController,
                decoration: InputDecoration(
                  hintText: 'Bugün seni zorlayan konu ne?',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: goalController,
                decoration: InputDecoration(
                  hintText: 'Bugün ulaşmak istediğin hedef?',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(
              _CheckInInput(
                mood: moodController.text.trim(),
                blocker: blockerController.text.trim(),
                goal: goalController.text.trim(),
              ),
            ),
            child: Text('Gönder'),
          ),
        ],
      );
    },
  );
  return result;
}

class _CheckInInput {
  const _CheckInInput({
    required this.mood,
    required this.blocker,
    required this.goal,
  });

  final String mood;
  final String blocker;
  final String goal;
}

Future<String?> _askAiPlanInput(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Derdi Anlat'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                'Örn: Netlerim düştü, matematikte zorlanıyorum, 4 hafta içinde hızlanmak istiyorum.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('Program İste'),
          ),
        ],
      );
    },
  );
  return result;
}

Future<void> Function() _showLoadingDialog(BuildContext context, String title) {
  bool isOpen = true;
  AiLoadingDialog.show(context, status: title).then((_) => isOpen = false);
  return () async {
    if (isOpen && context.mounted) {
      Navigator.of(context).pop();
    }
  };
}

Future<void> _showResultDialog(
  BuildContext context,
  String title,
  String content,
) {
  return AiResponseDialog.show(context, title, content);
}
