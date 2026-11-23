import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/models/exam_profile.dart';
import '../../../core/models/mock_exam.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/models/study_schedule_block.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/subject_colors.dart';
import '../../../core/widgets/delete_helpers.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/in_app_notice.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../curriculum/screens/curriculum_hub_screen.dart';
import '../../mistakes/screens/mistake_gallery_screen.dart';
import '../../questions/screens/entry_wizard_screen.dart';
import '../../questions/screens/focus_timer_screen.dart';
import '../../schedule/screens/weekly_schedule_screen.dart';
import '../../schedule/widgets/schedule_sheets.dart';
import 'main_screen.dart';
import 'streak_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _platform = MethodChannel('com.kistas.app/alarm');
  static Timer? _globalTimer;

  int _rangeIndex = 0; // 0: Bugün, 1: Hafta, 2: 30 Gün
  int _lastSetMinutes = 25;
  int _selectedScheduleWeekday = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final colors = AppColors.of(context);

    return SafeArea(
      child: ValueListenableBuilder<List<QuestionEntry>>(
        valueListenable: repository.questionEntries,
        builder: (context, questionEntries, _) {
          return ValueListenableBuilder<List<MockExam>>(
            valueListenable: repository.mockExams,
            builder: (context, mockExams, __) {
              return ValueListenableBuilder<int>(
                valueListenable: repository.dailyGoal,
                builder: (context, dailyGoal, ___) {
                  final filteredQuestions = _filterQuestionsByRange(
                    questionEntries,
                    _rangeIndex,
                  );
                  final filteredExams = _filterExamsByRange(
                    mockExams,
                    _rangeIndex,
                  );
                  final rangeSolved = _totalQuestions(filteredQuestions);
                  final rangeGoal = _rangeGoal(dailyGoal, _rangeIndex);
                  final rangeLabel = _rangeIndex == 0
                      ? 'Bugün'
                      : _rangeIndex == 1
                          ? '7 Gün'
                          : '30 Gün';
                  final avgNet = _averageNet(filteredExams);
                  final accuracy = _overallAccuracy(filteredQuestions);
                  final isEmpty = questionEntries.isEmpty && mockExams.isEmpty;
                  final activity = _buildActivity(
                    context,
                    filteredQuestions,
                    filteredExams,
                  );
                  final unsolvedMistakes = questionEntries
                      .where((e) => e.imagePaths.isNotEmpty && !e.isSolved)
                      .length;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<String>(
                          valueListenable: repository.userName,
                          builder: (context, name, _) {
                            return ValueListenableBuilder(
                              valueListenable: repository.notifications,
                              builder: (context, notifs, __) {
                                final hasUnread = notifs.any((n) => n.unread);
                                return _StudentHeader(
                                  userName: name,
                                  dateLabel: _formatToday(DateTime.now()),
                                  rangeIndex: _rangeIndex,
                                  hasUnreadNotifications: hasUnread,
                                  isDark: colors.isDark,
                                  onRangeChange: (i) =>
                                      setState(() => _rangeIndex = i),
                                  onOpenSchedule: () =>
                                      _openWeeklySchedule(context),
                                  onToggleTheme: () =>
                                      repository.toggleLightDarkTheme(),
                                  onOpenNotifications: () =>
                                      _showNotificationsSheet(
                                    context,
                                    repository,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Onboarding banner only when no subjects/topics exist yet
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<List<TopicSummary>>(
                          valueListenable: repository.userTopics,
                          builder: (context, topics, _) {
                            if (topics.isNotEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                              child: _SetupCurriculumBanner(
                                onOpenHub: () => Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CurriculumHubScreen(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // BLOCK 1: Unified Student Hero Card (Countdown + Streak + Progress)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                          child: ValueListenableBuilder<List<ExamProfile>>(
                            valueListenable: repository.examProfiles,
                            builder: (context, profiles, _) {
                              return ValueListenableBuilder<DateTime>(
                                valueListenable: repository.examDate,
                                builder: (context, fallbackDate, __) {
                                  final target = _pickUpcomingCountdown(
                                    profiles,
                                    fallbackDate,
                                  );
                                  final daysLeft = target.date
                                      .difference(DateTime.now())
                                      .inDays;
                                  final streak =
                                      repository.calculateCurrentStreak();
                                  return ValueListenableBuilder<Map<String, int>>(
                                    valueListenable: repository.aiGoalTargets,
                                    builder: (context, aiTargets, ___) {
                                      return _DailyHeroCard(
                                        countdownLabel: target.label,
                                        daysLeft: daysLeft,
                                        streak: streak,
                                        solved: rangeSolved,
                                        goal: rangeGoal,
                                        rangeLabel: rangeLabel,
                                        accuracy: accuracy,
                                        avgNet: avgNet,
                                        isEmpty: isEmpty,
                                        aiTargetCount: aiTargets.isEmpty
                                            ? null
                                            : aiTargets.values
                                                .fold<int>(0, (a, b) => a + b),
                                        onTapCountdown: () =>
                                            _pickCountdownDate(
                                          context,
                                          repository,
                                          target.profile,
                                          target.date,
                                        ),
                                        onTapStreak: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const StreakDetailScreen(),
                                          ),
                                        ),
                                        onQuickAdd: () => _openEntry(context),
                                        onOpenAiGoals: () =>
                                            MainScreen.switchTab(context, 4),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // BLOCK 2: Study Schedule (View, Add, Edit, Copy right from Home)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                          child: ValueListenableBuilder<List<StudyScheduleBlock>>(
                            valueListenable: repository.weeklySchedule,
                            builder: (context, _, __) {
                              final now = DateTime.now();
                              final currentMonday =
                                  StudyScheduleBlock.mondayOf(now);
                              final weekKey =
                                  StudyScheduleBlock.weekKeyFor(currentMonday);
                              final dayBlocks = repository.scheduleForDay(
                                _selectedScheduleWeekday,
                                weekMonday: currentMonday,
                              );
                              final dayCounts = {
                                for (var d = DateTime.monday;
                                    d <= DateTime.sunday;
                                    d++)
                                  d: repository
                                      .scheduleForDay(
                                        d,
                                        weekMonday: currentMonday,
                                      )
                                      .length,
                              };
                              return _TodayScheduleCard(
                                selectedWeekday: _selectedScheduleWeekday,
                                todayWeekday: now.weekday,
                                dayBlocks: dayBlocks,
                                dayCounts: dayCounts,
                                weekKey: weekKey,
                                onSelectWeekday: (day) => setState(
                                  () => _selectedScheduleWeekday = day,
                                ),
                                onToggleBlock: (id) =>
                                    repository.toggleScheduleBlockCompleted(
                                  id,
                                  weekKey: weekKey,
                                  weekday: _selectedScheduleWeekday,
                                ),
                                onAddBlock: () async {
                                  final savedDay =
                                      await showScheduleBlockEditorSheet(
                                    context,
                                    repository,
                                    weekday: _selectedScheduleWeekday,
                                    weekMonday: currentMonday,
                                  );
                                  if (savedDay != null && mounted) {
                                    setState(
                                      () => _selectedScheduleWeekday = savedDay,
                                    );
                                  }
                                },
                                onEditBlock: (block) async {
                                  final savedDay =
                                      await showScheduleBlockEditorSheet(
                                    context,
                                    repository,
                                    weekday: block.weekday,
                                    weekMonday: currentMonday,
                                    existing: block,
                                  );
                                  if (savedDay != null && mounted) {
                                    setState(
                                      () => _selectedScheduleWeekday = savedDay,
                                    );
                                  }
                                },
                                onCopyBlock: (block) =>
                                    showCopyScheduleBlockSheet(
                                  context,
                                  repository,
                                  source: block,
                                  currentWeekMonday: currentMonday,
                                ),
                                onOpenVideo: (url) =>
                                    openScheduleVideoUrl(context, url),
                                onOpenImages: (block) =>
                                    openScheduleImageGallery(
                                  context,
                                  block.imagePaths,
                                  block.subject,
                                ),
                                onOpenFullSchedule: () => _openWeeklySchedule(
                                  context,
                                  initialWeekday: _selectedScheduleWeekday,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // BLOCK 3: Compact Study Tools Row (Focus Timer + Mistake Notebook)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                          child: ValueListenableBuilder<int>(
                            valueListenable: repository.focusRemaining,
                            builder: (context, focusRemaining, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: repository.focusRunning,
                                builder: (context, focusRunning, __) {
                                  return _StudyToolsRow(
                                    remainingSeconds: focusRemaining,
                                    timerRunning: focusRunning,
                                    unsolvedMistakes: unsolvedMistakes,
                                    onTapTimer: () => _showFocusTimerSheet(
                                      context,
                                      repository,
                                    ),
                                    onToggleTimer: () {
                                      if (focusRunning) {
                                        _pauseFocusTimer(repository);
                                      } else {
                                        _startFocusTimer(repository);
                                        _openFocusTimerScreen(repository);
                                      }
                                    },
                                    onOpenMistakes: () =>
                                        Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MistakeGalleryScreen(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // BLOCK 4: Recent Activity (max 3, swipe-to-delete + tap detail)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openEntry(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => const EntryWizardScreen(
          type: EntryType.question,
        ),
      ),
    );
  }

  void _openWeeklySchedule(BuildContext context, {int? initialWeekday}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => WeeklyScheduleScreen(
          initialWeekday: initialWeekday,
        ),
      ),
    );
  }

  Future<void> _pickCountdownDate(
    BuildContext context,
    AppRepository repository,
    ExamProfile? profile,
    DateTime currentDate,
  ) async {
    final now = DateTime.now();
    final initial = currentDate.isBefore(now) ? now : currentDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: profile != null
          ? '${profile.name} Sınav Tarihi'
          : 'Hedef Sınav Tarihi',
    );
    if (picked == null) return;
    if (profile != null) {
      await repository.upsertExamProfile(profile.copyWith(examDate: picked));
    } else {
      await repository.setExamDate(picked);
    }
    if (context.mounted) {
      InAppNotice.show(context, 'Sınav tarihi güncellendi.');
    }
  }

  Future<void> _invokeAlarmSafe(String method) async {
    try {
      await _platform.invokeMethod(method);
    } on MissingPluginException {
      // Ignored on platforms without native alarm channel
    } catch (e) {
      debugPrint('HomeScreen: Alarm channel error ($method): $e');
    }
  }

  void _startFocusTimer(AppRepository repository) {
    if (repository.focusRunning.value) return;
    repository.focusRunning.value = true;

    if (repository.focusRemaining.value > 5) {
      NotificationService.scheduleFocusEnd(repository.focusRemaining.value);
    }

    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (repository.focusRemaining.value <= 1) {
        timer.cancel();
        repository.focusRunning.value = false;
        repository.focusRemaining.value = 0;
        _invokeAlarmSafe('play');
        NotificationService.showFocusEndNotification();
        return;
      }
      repository.focusRemaining.value -= 1;
    });
  }

  void _pauseFocusTimer(AppRepository repository) {
    _globalTimer?.cancel();
    NotificationService.cancelFocusEnd();
    _invokeAlarmSafe('stop');
    repository.focusRunning.value = false;
  }

  void _resetFocusTimer(AppRepository repository) {
    _globalTimer?.cancel();
    NotificationService.cancelFocusEnd();
    _invokeAlarmSafe('stop');
    repository.focusRunning.value = false;
    repository.focusRemaining.value = _lastSetMinutes * 60;
  }

  void _setFocusDuration(AppRepository repository, int minutes) {
    _globalTimer?.cancel();
    NotificationService.cancelFocusEnd();
    _invokeAlarmSafe('stop');
    _lastSetMinutes = minutes;
    repository.focusRunning.value = false;
    repository.focusRemaining.value = minutes * 60;
  }

  void _openFocusTimerScreen(AppRepository repository) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => FocusTimerScreen(
          remainingSeconds: repository.focusRemaining,
          running: repository.focusRunning,
          onPause: () => _pauseFocusTimer(repository),
          onResume: () => _startFocusTimer(repository),
          onReset: () => _resetFocusTimer(repository),
        ),
      ),
    );
  }

  void _showFocusTimerSheet(BuildContext context, AppRepository repository) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = AppColors.of(sheetContext);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final minutes =
                max(1, (repository.focusRemaining.value / 60).round());
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Odak Zamanlayıcı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimer(repository.focusRemaining.value),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colors.primary,
                        inactiveTrackColor: colors.subtleFill,
                        thumbColor: colors.primary,
                      ),
                      child: Slider(
                        value: minutes.toDouble(),
                        min: 1,
                        max: 120,
                        divisions: 119,
                        label: '$minutes dk',
                        onChanged: (value) {
                          setSheetState(() {
                            _setFocusDuration(repository, value.round());
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [15, 25, 30, 45, 60, 90]
                          .map(
                            (preset) => ChoiceChip(
                              label: Text('$preset dk'),
                              selected: minutes == preset,
                              onSelected: (_) {
                                setSheetState(() {
                                  _setFocusDuration(repository, preset);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Kaydet'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _startFocusTimer(repository);
                              Navigator.of(sheetContext).pop();
                              _openFocusTimerScreen(repository);
                            },
                            child: const Text('Başlat'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: repository.focusRunning.value
                                ? () => _pauseFocusTimer(repository)
                                : null,
                            child: const Text('Duraklat'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _resetFocusTimer(repository),
                            child: const Text('Sıfırla'),
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

({String label, DateTime date, ExamProfile? profile}) _pickUpcomingCountdown(
  List<ExamProfile> profiles,
  DateTime fallbackDate,
) {
  final now = DateTime.now();
  final withDates = profiles.where((p) => p.examDate != null).toList();
  if (withDates.isEmpty) {
    return (label: 'Hedef Sınav', date: fallbackDate, profile: null);
  }
  final future = withDates.where((p) => !p.examDate!.isBefore(now)).toList()
    ..sort((a, b) => a.examDate!.compareTo(b.examDate!));
  final chosen = future.isNotEmpty ? future.first : withDates.first;
  return (label: chosen.name, date: chosen.examDate!, profile: chosen);
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({
    required this.userName,
    required this.dateLabel,
    required this.rangeIndex,
    required this.hasUnreadNotifications,
    required this.isDark,
    required this.onRangeChange,
    required this.onOpenSchedule,
    required this.onToggleTheme,
    required this.onOpenNotifications,
  });

  final String userName;
  final String dateLabel;
  final int rangeIndex;
  final bool hasUnreadNotifications;
  final bool isDark;
  final ValueChanged<int> onRangeChange;
  final VoidCallback onOpenSchedule;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final greeting = userName.trim().isEmpty
        ? 'İyi çalışmalar'
        : 'Merhaba, ${userName.trim()}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(
                icon: Icons.calendar_month_outlined,
                tooltip: 'Haftalık Program',
                onTap: onOpenSchedule,
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                tooltip: isDark ? 'Gündüz Moduna Geç' : 'Gece Moduna Geç',
                onTap: onToggleTheme,
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Bildirimler',
                showBadge: hasUnreadNotifications,
                onTap: onOpenNotifications,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.subtleFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                _RangeTab(
                  label: 'Bugün',
                  active: rangeIndex == 0,
                  onTap: () => onRangeChange(0),
                ),
                _RangeTab(
                  label: 'Hafta',
                  active: rangeIndex == 1,
                  onTap: () => onRangeChange(1),
                ),
                _RangeTab(
                  label: '30 Gün',
                  active: rangeIndex == 2,
                  onTap: () => onRangeChange(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: colors.textPrimary, size: 20),
              if (showBadge)
                Positioned(
                  right: 9,
                  top: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  const _RangeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active && !colors.isDark
                ? [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active ? colors.primary : colors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _SetupCurriculumBanner extends StatelessWidget {
  const _SetupCurriculumBanner({required this.onOpenHub});
  final VoidCallback onOpenHub;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderColor: colors.primary.withValues(alpha: 0.35),
      color: colors.primary.withValues(alpha: colors.isDark ? 0.12 : 0.06),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_stories_outlined, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Derslerini Seçmeye Başla',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Maarif TYT/AYT, KPSS, YDS veya kendi derslerini ekle.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onOpenHub,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Seç'),
          ),
        ],
      ),
    );
  }
}

class _DailyHeroCard extends StatelessWidget {
  const _DailyHeroCard({
    required this.countdownLabel,
    required this.daysLeft,
    required this.streak,
    required this.solved,
    required this.goal,
    required this.rangeLabel,
    required this.accuracy,
    required this.avgNet,
    required this.isEmpty,
    required this.aiTargetCount,
    required this.onTapCountdown,
    required this.onTapStreak,
    required this.onQuickAdd,
    required this.onOpenAiGoals,
  });

  final String countdownLabel;
  final int daysLeft;
  final int streak;
  final int solved;
  final int goal;
  final String rangeLabel;
  final double? accuracy;
  final double? avgNet;
  final bool isEmpty;
  final int? aiTargetCount;
  final VoidCallback onTapCountdown;
  final VoidCallback onTapStreak;
  final VoidCallback onQuickAdd;
  final VoidCallback onOpenAiGoals;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final progress = goal <= 0 ? 0.0 : (solved / goal).clamp(0.0, 1.0);
    final countdownText = daysLeft > 0
        ? '$countdownLabel • $daysLeft gün'
        : daysLeft == 0
            ? '$countdownLabel • Bugün!'
            : '$countdownLabel • Tarih seç';

    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top compact status pills: Exam Countdown + Streak
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTapCountdown,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(
                        alpha: colors.isDark ? 0.16 : 0.09,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 14,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            countdownText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onTapStreak,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(
                      alpha: colors.isDark ? 0.16 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 15,
                        color: colors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak gün seri',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Main Progress Row
          Row(
            children: [
              ProgressRing(
                value: progress,
                size: 98,
                strokeWidth: 9,
                trackColor: colors.subtleFill,
                progressColor: progress >= 1.0 ? colors.success : colors.primary,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$solved',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      '/ $goal',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$rangeLabel Soru Hedefi',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroMetric(
                            label: 'Doğruluk',
                            value: accuracy == null
                                ? '—'
                                : '%${(accuracy! * 100).round()}',
                            accent: colors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroMetric(
                            label: 'Ort. Net',
                            value: avgNet == null
                                ? '—'
                                : avgNet!.toStringAsFixed(1),
                            accent: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (aiTargetCount != null && aiTargetCount! > 0) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: onOpenAiGoals,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.subtleFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 15, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Günlük Hedefi: $aiTargetCount soru',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colors.textPrimary,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onQuickAdd,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('İlk Soru veya Denemeni Ekle'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.subtleFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: value == '—' ? colors.textMuted : accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard({
    required this.selectedWeekday,
    required this.todayWeekday,
    required this.dayBlocks,
    required this.dayCounts,
    required this.weekKey,
    required this.onSelectWeekday,
    required this.onToggleBlock,
    required this.onAddBlock,
    required this.onEditBlock,
    required this.onCopyBlock,
    required this.onOpenVideo,
    required this.onOpenImages,
    required this.onOpenFullSchedule,
  });

  final int selectedWeekday;
  final int todayWeekday;
  final List<StudyScheduleBlock> dayBlocks;
  final Map<int, int> dayCounts;
  final String weekKey;
  final ValueChanged<int> onSelectWeekday;
  final ValueChanged<String> onToggleBlock;
  final VoidCallback onAddBlock;
  final ValueChanged<StudyScheduleBlock> onEditBlock;
  final ValueChanged<StudyScheduleBlock> onCopyBlock;
  final ValueChanged<String> onOpenVideo;
  final ValueChanged<StudyScheduleBlock> onOpenImages;
  final VoidCallback onOpenFullSchedule;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final completedCount = dayBlocks
        .where((b) => b.isCompletedForWeek(weekKey, weekday: selectedWeekday))
        .length;

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 17,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Ders Programı',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    if (dayBlocks.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.subtleFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$completedCount/${dayBlocks.length}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onAddBlock,
                style: TextButton.styleFrom(
                  backgroundColor: colors.primary.withValues(
                    alpha: colors.isDark ? 0.18 : 0.10,
                  ),
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'Görev',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: onOpenFullSchedule,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Tamamını Aç',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 7-day compact weekday selector right on Home
          Row(
            children: List.generate(7, (index) {
              final day = index + 1;
              final selected = day == selectedWeekday;
              final isToday = day == todayWeekday;
              final count = dayCounts[day] ?? 0;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelectWeekday(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : colors.subtleFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? colors.primary
                            : isToday
                                ? colors.primary.withValues(alpha: 0.55)
                                : colors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          scheduleShortWeekdays[index],
                          style: TextStyle(
                            color: selected
                                ? colors.onPrimary
                                : colors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 16,
                          height: 14,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.onPrimary.withValues(alpha: 0.18)
                                : count > 0
                                    ? colors.primary.withValues(alpha: 0.14)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            count > 0 ? '$count' : '·',
                            style: TextStyle(
                              color: selected
                                  ? colors.onPrimary
                                  : count > 0
                                      ? colors.primary
                                      : colors.textMuted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          if (dayBlocks.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${scheduleFullWeekdays[selectedWeekday - 1]} için planlı görev yok.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAddBlock,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text('Görev Ekle'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenFullSchedule,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.calendar_view_week_rounded, size: 17),
                    label: const Text('Haftalık Plan'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            ...dayBlocks.take(5).map((block) {
              final completed = block.isCompletedForWeek(
                weekKey,
                weekday: selectedWeekday,
              );
              final subjectStyle = SubjectColors.of(
                block.subject,
                isDark: colors.isDark,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onEditBlock(block),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colors.subtleFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            color: completed
                                ? colors.textMuted
                                : subjectStyle.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onToggleBlock(block.id),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: completed
                                    ? colors.success
                                    : colors.surface,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: completed
                                      ? colors.success
                                      : subjectStyle.accent,
                                  width: 1.6,
                                ),
                              ),
                              child: completed
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                block.topic.isNotEmpty
                                    ? '${block.subject} • ${block.topic}'
                                    : block.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: completed
                                          ? colors.textMuted
                                          : colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      decoration: completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                              Text(
                                '${block.startTime.isNotEmpty ? '${block.startTime} • ' : ''}'
                                '${block.durationMinutes} dk'
                                '${block.targetQuestions > 0 ? ' • ${block.targetQuestions} soru' : ''}'
                                '${block.recurrence != ScheduleRecurrence.weekly ? ' • ${block.recurrence.label}' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (block.videoUrl.trim().isNotEmpty)
                          IconButton(
                            tooltip: 'Videoyu Aç',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            padding: const EdgeInsets.all(2),
                            onPressed: () => onOpenVideo(block.videoUrl),
                            icon: Icon(
                              Icons.play_circle_outline_rounded,
                              size: 18,
                              color: colors.danger,
                            ),
                          ),
                        if (block.imagePaths.isNotEmpty)
                          IconButton(
                            tooltip: 'Fotoğrafları Aç',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            padding: const EdgeInsets.all(2),
                            onPressed: () => onOpenImages(block),
                            icon: Icon(
                              Icons.photo_outlined,
                              size: 17,
                              color: subjectStyle.accent,
                            ),
                          ),
                        IconButton(
                          tooltip: 'Görevi Kopyala',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          padding: const EdgeInsets.all(2),
                          onPressed: () => onCopyBlock(block),
                          icon: Icon(
                            Icons.copy_rounded,
                            size: 17,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (dayBlocks.length > 5)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onOpenFullSchedule,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('+ ${dayBlocks.length - 5} görev daha gör'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StudyToolsRow extends StatelessWidget {
  const _StudyToolsRow({
    required this.remainingSeconds,
    required this.timerRunning,
    required this.unsolvedMistakes,
    required this.onTapTimer,
    required this.onToggleTimer,
    required this.onOpenMistakes,
  });

  final int remainingSeconds;
  final bool timerRunning;
  final int unsolvedMistakes;
  final VoidCallback onTapTimer;
  final VoidCallback onToggleTimer;
  final VoidCallback onOpenMistakes;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTapTimer,
            borderRadius: BorderRadius.circular(20),
            child: GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Odak Sayacı',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimer(remainingSeconds),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: timerRunning
                                    ? colors.primary
                                    : colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onToggleTimer,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        timerRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: colors.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: onOpenMistakes,
            borderRadius: BorderRadius.circular(20),
            child: GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hata Defteri',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unsolvedMistakes == 0
                              ? 'Tertemiz'
                              : '$unsolvedMistakes bekleyen',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: unsolvedMistakes == 0
                                    ? colors.success
                                    : colors.warning,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(
                        alpha: colors.isDark ? 0.16 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.collections_bookmark_outlined,
                      color: colors.warning,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activity, required this.onShowAll});
  final List<_ActivityItem> activity;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Aktiviteler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: onShowAll,
              child: const Text('Tümü'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (activity.isEmpty)
          GlassPanel(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: colors.textMuted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu aralıkta henüz kayıt yok.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: activity.map((item) => _ActivityCard(item: item)).toList(),
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
    final colors = AppColors.of(context);
    final subjectStyle = SubjectColors.of(
      item.subjectForColor,
      isDark: colors.isDark,
    );
    final card = InkWell(
      onTap: () => _showActivityDetailSheet(context, item),
      borderRadius: BorderRadius.circular(18),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        radius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: subjectStyle.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: subjectStyle.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: subjectStyle.tint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.badge,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: subjectStyle.accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final deleteKey = item.questionEntry?.id ?? item.mockExam?.id;
    if (deleteKey == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: card,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey('activity_$deleteKey'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colors.danger,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Sil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          if (item.questionEntry != null) {
            return deleteQuestionEntryWithUndo(context, item.questionEntry!);
          }
          if (item.mockExam != null) {
            return deleteMockExamWithUndo(context, item.mockExam!);
          }
          return false;
        },
        child: card,
      ),
    );
  }
}

void _showActivityDetailSheet(BuildContext context, _ActivityItem item) {
  final colors = AppColors.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final q = item.questionEntry;
      final e = item.mockExam;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item.title,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.subtitle} • ${item.timeLabel}',
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              if (q != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniPill(label: 'Doğru ${q.correct}', color: colors.success),
                    _MiniPill(label: 'Yanlış ${q.wrong}', color: colors.danger),
                    _MiniPill(label: 'Boş ${q.blank}', color: colors.warning),
                    _MiniPill(label: '${q.minutes} dk', color: colors.primary),
                  ],
                ),
              if (e != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniPill(
                      label: '${e.totalNet.toStringAsFixed(1)} net',
                      color: colors.primary,
                    ),
                    _MiniPill(label: 'Doğru ${e.correct}', color: colors.success),
                    _MiniPill(label: 'Yanlış ${e.wrong}', color: colors.danger),
                    _MiniPill(label: 'Boş ${e.blank}', color: colors.warning),
                    _MiniPill(label: '${e.minutes} dk', color: colors.textSecondary),
                  ],
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    bool deleted = false;
                    if (q != null) {
                      deleted = await deleteQuestionEntryWithUndo(context, q);
                    } else if (e != null) {
                      deleted = await deleteMockExamWithUndo(context, e);
                    }
                    if (deleted && sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.danger.withValues(alpha: 0.45)),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                  label: const Text('Kaydı Sil'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ActivityItem {
  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.badge,
    required this.icon,
    required this.subjectForColor,
    required this.timestamp,
    this.questionEntry,
    this.mockExam,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String badge;
  final IconData icon;
  final String subjectForColor;
  final DateTime timestamp;
  final QuestionEntry? questionEntry;
  final MockExam? mockExam;
}

List<QuestionEntry> _filterQuestionsByRange(
  List<QuestionEntry> entries,
  int rangeIndex,
) {
  final now = DateTime.now();
  if (rangeIndex == 0) {
    return entries.where((e) => _isSameDay(e.createdAt, now)).toList();
  }
  final days = rangeIndex == 1 ? 7 : 30;
  final cutoff = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: days - 1));
  return entries.where((e) => !e.createdAt.isBefore(cutoff)).toList();
}

List<MockExam> _filterExamsByRange(List<MockExam> exams, int rangeIndex) {
  final now = DateTime.now();
  if (rangeIndex == 0) {
    return exams.where((e) => _isSameDay(e.createdAt, now)).toList();
  }
  final days = rangeIndex == 1 ? 7 : 30;
  final cutoff = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: days - 1));
  return exams.where((e) => !e.createdAt.isBefore(cutoff)).toList();
}

int _rangeGoal(int dailyGoal, int rangeIndex) {
  if (rangeIndex == 0) return dailyGoal;
  if (rangeIndex == 1) return dailyGoal * 7;
  return dailyGoal * 30;
}

List<_ActivityItem> _buildAllActivityItems(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
) {
  final items = <_ActivityItem>[];
  for (final entry in questionEntries) {
    items.add(
      _ActivityItem(
        title: entry.bookName.isNotEmpty
            ? entry.bookName
            : (entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic),
        subtitle: '${entry.subject} • ${entry.total} soru',
        timeLabel: _formatTime(entry.createdAt),
        badge: '${entry.correct} doğru',
        icon: Icons.edit_note_rounded,
        subjectForColor: entry.subject,
        timestamp: entry.createdAt,
        questionEntry: entry,
      ),
    );
  }
  for (final exam in mockExams) {
    items.add(
      _ActivityItem(
        title: exam.title.isEmpty ? 'Deneme' : exam.title,
        subtitle: '${exam.scopeSummary} • ${exam.examType}',
        timeLabel: _formatTime(exam.createdAt),
        badge: '${exam.totalNet.toStringAsFixed(1)} net',
        icon: Icons.assignment_turned_in_outlined,
        subjectForColor:
            exam.focusSubject.isNotEmpty ? exam.focusSubject : exam.examType,
        timestamp: exam.createdAt,
        mockExam: exam,
      ),
    );
  }
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}

List<_ActivityItem> _buildActivity(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
) {
  return _buildAllActivityItems(context, questionEntries, mockExams)
      .take(3)
      .toList();
}

void _showActivitySheet(
  BuildContext context,
  List<QuestionEntry> _,
  List<MockExam> __,
) {
  final repository = AppRepositoryScope.of(context);
  var filterIndex = 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return ValueListenableBuilder<List<QuestionEntry>>(
                valueListenable: repository.questionEntries,
                builder: (context, liveQuestions, _) {
                  return ValueListenableBuilder<List<MockExam>>(
                    valueListenable: repository.mockExams,
                    builder: (context, liveExams, __) {
                      final allItems = _buildAllActivityItems(
                        context,
                        filterIndex == 2 ? const [] : liveQuestions,
                        filterIndex == 1 ? const [] : liveExams,
                      );
                      final colors = AppColors.of(context);

                      return Container(
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.border,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tüm Aktiviteler (${allItems.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Silmek için sola kaydır veya kayda dokun',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colors.textMuted),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Tümü'),
                                    selected: filterIndex == 0,
                                    onSelected: (_) =>
                                        setModalState(() => filterIndex = 0),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: Text('Sorular (${liveQuestions.length})'),
                                    selected: filterIndex == 1,
                                    onSelected: (_) =>
                                        setModalState(() => filterIndex = 1),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: Text('Denemeler (${liveExams.length})'),
                                    selected: filterIndex == 2,
                                    onSelected: (_) =>
                                        setModalState(() => filterIndex = 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: allItems.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Bu kategoride kayıt yok.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.textSecondary,
                                            ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: controller,
                                      padding: const EdgeInsets.all(16),
                                      itemCount: allItems.length,
                                      itemBuilder: (_, index) =>
                                          _ActivityCard(item: allItems[index]),
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
        },
      );
    },
  );
}

void _showNotificationsSheet(BuildContext context, AppRepository repository) {
  final colors = AppColors.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ValueListenableBuilder(
        valueListenable: repository.notifications,
        builder: (context, notifications, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/KISTAS.svg',
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bildirimler',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (notifications.isNotEmpty) ...[
                        TextButton(
                          onPressed: () => repository.markAllNotificationsRead(),
                          child: const Text('Okundu'),
                        ),
                        TextButton(
                          onPressed: () => repository.clearNotifications(),
                          child: Text(
                            'Temizle',
                            style: TextStyle(color: colors.danger),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (notifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Henüz bildirim yok.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: colors.divider),
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
                                      color: colors.primary,
                                    ),
                                  )
                                : const SizedBox(width: 8),
                            title: Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            subtitle: Text(
                              item.body,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colors.textSecondary),
                            ),
                            trailing: Text(
                              _formatTime(item.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colors.textMuted),
                            ),
                          );
                        },
                      ),
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

double? _averageNet(List<MockExam> exams) {
  if (exams.isEmpty) return null;
  return exams.fold<double>(0, (sum, item) => sum + item.totalNet) /
      exams.length;
}

double? _overallAccuracy(List<QuestionEntry> entries) {
  if (entries.isEmpty) return null;
  final correct =
      entries.fold<int>(0, (sum, entry) => sum + entry.effectiveCorrect);
  final total = entries.fold<int>(0, (sum, entry) => sum + entry.total);
  return total == 0 ? null : correct / total;
}

int _totalQuestions(List<QuestionEntry> entries) =>
    entries.fold<int>(0, (sum, entry) => sum + entry.total);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatToday(DateTime date) {
  const months = [
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
  const weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  return '${date.day} ${months[date.month - 1]}, ${weekdays[date.weekday - 1]}';
}

String _formatTime(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatTimer(int totalSeconds) {
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
