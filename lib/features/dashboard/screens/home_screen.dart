import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/models/app_notification.dart';
import '../../../core/models/mock_exam.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/gemini_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_loading_dialog.dart';
import '../../../core/widgets/ai_response_dialog.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/in_app_notice.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../questions/screens/entry_wizard_screen.dart';
import '../../questions/screens/focus_timer_screen.dart';
import '../../settings/screens/profile_screen.dart';
import '../../questions/screens/quick_add_screen.dart';
import 'streak_detail_screen.dart';
import '../../questions/screens/topic_summaries_screen.dart';
import '../../mistakes/screens/mistake_gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedRange = 0;
  int _lastSetMinutes = 25;
  static const _platform = MethodChannel('com.example.app/alarm');

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

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
                  final avgNet = _averageNet(mockExams);
                  final activity = _buildActivity(context, questionEntries, mockExams);
                  final focusTopic = _pickFocusTopic(repository, questionEntries);
                  final isEmpty = questionEntries.isEmpty && mockExams.isEmpty;
                  final todayTotal = _countTodayQuestions(questionEntries);

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
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          child: ValueListenableBuilder<DateTime>(
                            valueListenable: repository.examDate,
                            builder: (context, examDate, _) {
                              return _ExamCountdownCard(examDate: examDate);
                            },
                          ),
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
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: _MistakeNotebookCard(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MistakeGalleryScreen(),
                              ),
                            ),
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
                          child: ValueListenableBuilder<int>(
                            valueListenable: repository.focusRemaining,
                            builder: (context, focusRemaining, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: repository.focusRunning,
                                builder: (context, focusRunning, __) {
                                  return _FocusTimerCard(
                                    remainingSeconds: focusRemaining,
                                    running: focusRunning,
                                    onStart: () {
                                      _startFocusTimer(repository);
                                      _openFocusTimerScreen(repository);
                                    },
                                    onPause: () => _pauseFocusTimer(repository),
                                    onReset: () => _resetFocusTimer(repository),
                                    onOpen: () => _showFocusTimerSheet(context, repository),
                                  );
                                },
                              );
                            },
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
                      const SliverToBoxAdapter(child: SizedBox(height: 140)),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EntryWizardScreen(
          type: EntryType.question,
        ),
      ),
    );
  }

  static Timer? _globalTimer;

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
        _platform.invokeMethod('play');
        NotificationService.showFocusEndNotification();
        
        // Auto-reset timer after 15 seconds (matching alarm duration)
        return;
      }
      repository.focusRemaining.value -= 1;
    });
  }

  void _pauseFocusTimer(AppRepository repository) {
    _globalTimer?.cancel();
    NotificationService.cancelFocusEnd();
    _platform.invokeMethod('stop');
    repository.focusRunning.value = false;
  }

  void _resetFocusTimer(AppRepository repository) {
    _globalTimer?.cancel();
    NotificationService.cancelFocusEnd();
    _platform.invokeMethod('stop');
    repository.focusRunning.value = false;
    repository.focusRemaining.value = _lastSetMinutes * 60;
  }

  void _setFocusDuration(AppRepository repository, int minutes) {
    _globalTimer?.cancel();
    NotificationService.cancelFocusEnd();
    _platform.invokeMethod('stop');
    _lastSetMinutes = minutes;
    repository.focusRunning.value = false;
    repository.focusRemaining.value = minutes * 60;
  }

  void _openFocusTimerScreen(AppRepository repository) {
    Navigator.of(context).push(
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
    final currentMinutes = max(1, (repository.focusRemaining.value / 60).round());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final minutes = max(1, (repository.focusRemaining.value / 60).round());
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
                    Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999))),
                    const SizedBox(height: 16),
                    Text('Odak Zamanlayıcı', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(_formatTimer(repository.focusRemaining.value), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.of(context).primary, inactiveTrackColor: Colors.white12, thumbColor: AppColors.of(context).primary),
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
                      children: [15, 25, 30, 45, 60, 90].map((preset) => _FocusPresetChip(
                        minutes: preset,
                        selected: minutes == preset,
                        onTap: () {
                          setSheetState(() {
                            _setFocusDuration(repository, preset);
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(sheetContext).pop(), child: const Text('Süreyi Uygula'))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(onPressed: () {
                          _startFocusTimer(repository);
                          Navigator.of(sheetContext).pop();
                          _openFocusTimerScreen(repository);
                        }, child: const Text('Başlat'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: repository.focusRunning.value ? () => _pauseFocusTimer(repository) : null, child: const Text('Duraklat'))),
                        Expanded(child: TextButton(onPressed: () => _resetFocusTimer(repository), child: const Text('Sıfırla'))),
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

class _MistakeNotebookCard extends StatelessWidget {
  const _MistakeNotebookCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_stories, color: Colors.orangeAccent),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hata Defteri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Fotoğraflı yanlış sorularını yönet.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.todayTotal, required this.dailyGoal, required this.avgNet, required this.accuracy, required this.totalQuestions});
  final int todayTotal;
  final int dailyGoal;
  final double? avgNet;
  final double? accuracy;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: _RingCard(solved: todayTotal, dailyGoal: dailyGoal)),
          const SizedBox(width: 12),
          Expanded(flex: 7, child: Column(children: [
            Expanded(child: _StatCard(label: 'Ortalama Net', value: avgNet == null ? '—' : avgNet!.toStringAsFixed(1))),
            const SizedBox(height: 10),
            Expanded(child: Row(children: [
              Expanded(child: _MiniStatCard(label: 'Doğruluk', value: accuracy == null ? '—' : '%${(accuracy! * 100).round()}', valueColor: AppColors.of(context).primary)),
              const SizedBox(width: 10),
              Expanded(child: _MiniStatCard(label: 'Toplam', value: totalQuestions == 0 ? '—' : totalQuestions.toString())),
            ])),
          ])),
        ],
      ),
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
      decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: [
        RepaintBoundary(
          child: ProgressRing(value: ratio, size: 156, strokeWidth: 12, trackColor: AppColors.of(context).surfaceLight, progressColor: AppColors.of(context).primary, centerColor: AppColors.of(context).surface, child: Column(mainAxisSize: MainAxisSize.min, children: [
            FittedBox(child: Text(solved.toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 32))),
            const SizedBox(height: 2),
            Text('/$dailyGoal', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.of(context).textSecondary, letterSpacing: 1, fontSize: 14)),
          ])),
        ),
        const SizedBox(height: 12),
        Text('Günlük Soru', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary, fontSize: 14)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
      ]),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: valueColor ?? AppColors.of(context).textPrimary)),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedRange, required this.onRangeChanged, this.onNotificationsTap});
  final int selectedRange;
  final ValueChanged<int> onRangeChanged;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      radius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(_formatToday(now), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.of(context).textPrimary))),
          InkWell(onTap: onNotificationsTap, borderRadius: BorderRadius.circular(16), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.of(context).surfaceLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))), child: const Icon(Icons.notifications_none, color: Colors.white))),
        ]),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.of(context).surfaceLight.withOpacity(0.5), borderRadius: BorderRadius.circular(16)), child: Row(children: [
          _SegmentedButton(label: 'Bugün', active: selectedRange == 0, onTap: () => onRangeChanged(0)),
          _SegmentedButton(label: 'Hafta', active: selectedRange == 1, onTap: () => onRangeChanged(1)),
          _SegmentedButton(label: '30 Gün', active: selectedRange == 2, onTap: () => onRangeChanged(2)),
        ])),
      ]),
    );
  }
}

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 220), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: active ? AppColors.of(context).surfaceLight : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: active ? Colors.white12 : Colors.transparent)), child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.of(context).textSecondary)))));
  }
}

class _AiGoalPanel extends StatelessWidget {
  const _AiGoalPanel({required this.repository, required this.onOpenProfile});
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
                final cadenceLabel = cadence == 'daily' ? 'Günlük' : cadence == 'weekly' ? 'Haftalık' : 'Aylık';
                final displayValue = targets[cadence];
                return GlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  radius: BorderRadius.circular(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.of(context).primary.withOpacity(0.18), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.auto_awesome, color: AppColors.of(context).primary)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('AI Hedef Panosu', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(updatedAt == null ? 'Henüz hedef oluşturulmadı.' : 'Son güncelleme: ${_formatDateTime(updatedAt)}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.of(context).textSecondary)),
                      ])),
                      TextButton(onPressed: onOpenProfile, child: const Text('Düzenle')),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _AiGoalValueCard(label: cadenceLabel, value: displayValue?.toString() ?? '—')),
                      const SizedBox(width: 12),
                      Expanded(child: _AiGoalValueCard(label: 'Günlük', value: targets['daily']?.toString() ?? '—', isMuted: cadence != 'daily')),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _AiGoalValueCard(label: 'Haftalık', value: targets['weekly']?.toString() ?? '—', isMuted: cadence != 'weekly')),
                      const SizedBox(width: 12),
                      Expanded(child: _AiGoalValueCard(label: 'Aylık', value: targets['monthly']?.toString() ?? '—', isMuted: cadence != 'monthly')),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _requestAiPlan(context, repository), icon: const Icon(Icons.psychology_alt), label: const Text('AI Program Hazırla'))),
                  ]),
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
  const _AiGoalValueCard({required this.label, required this.value, this.isMuted = false});
  final String label;
  final String value;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(isMuted ? 0.04 : 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.of(context).textSecondary)),
        const SizedBox(height: 4),
        Text('$value soru', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StreakDetailScreen())),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(20),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.of(context).primary.withOpacity(0.18), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.local_fire_department, color: AppColors.of(context).primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Çalışma Serisi', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            Text(streak == 0 ? 'Bugün başla' : '$streak gün üst üste', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary)),
          ])),
          Text(streak.toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _FocusTimerCard extends StatelessWidget {
  const _FocusTimerCard({required this.remainingSeconds, required this.running, required this.onStart, required this.onPause, required this.onReset, required this.onOpen});
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
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(20),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.of(context).primary.withOpacity(0.18), borderRadius: BorderRadius.circular(12)), child: Icon(running ? Icons.hourglass_top : Icons.timer, color: AppColors.of(context).primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Odaklan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            Text(_formatTimer(remainingSeconds), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ])),
          if (!running) IconButton(onPressed: onStart, icon: Icon(Icons.play_arrow_rounded, color: AppColors.of(context).primary, size: 32))
          else IconButton(onPressed: onPause, icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 32)),
          IconButton(onPressed: onReset, icon: const Icon(Icons.replay_rounded, color: Colors.white38, size: 24)),
        ]),
      ),
    );
  }
}

class _FocusPresetChip extends StatelessWidget {
  const _FocusPresetChip({required this.minutes, required this.selected, required this.onTap});
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: selected ? AppColors.of(context).primary.withOpacity(0.25) : Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.of(context).primary.withOpacity(0.4) : Colors.white.withOpacity(0.08))),
        child: Text('$minutes dk', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: selected ? Colors.white : Colors.white70, fontWeight: FontWeight.w700)),
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
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Son Aktiviteler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        TextButton(onPressed: onShowAll, child: Text('Tümü', style: TextStyle(color: AppColors.of(context).primary))),
      ]),
      const SizedBox(height: 6),
      if (activity.isEmpty) Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.of(context).surfaceLight, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.timeline, color: Colors.white54)),
        const SizedBox(width: 12),
        Expanded(child: Text('Henüz etkinlik yok. İlk kaydın burada görünecek.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary))),
      ]))
      else Column(children: activity.map((item) => _ActivityCard(item: item)).toList()),
    ]);
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
      decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.of(context).surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: item.accentColor.withOpacity(0.5))), child: Icon(item.icon, color: item.accentColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(item.timeLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.of(context).textSecondary)),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: item.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Text(item.badge, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: item.accentColor, fontWeight: FontWeight.w700))),
        ]),
      ]),
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
      decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.of(context).surfaceLight, borderRadius: BorderRadius.circular(18)), child: Icon(Icons.insights, color: AppColors.of(context).primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Henüz veri yok', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('İlk soru veya denemeni ekleyerek dashboardu doldur.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: onQuickAdd, icon: Icon(Icons.bolt, color: AppColors.of(context).primary), label: Text('Hızlı Ekle', style: TextStyle(color: AppColors.of(context).primary))),
        ])),
      ]),
    );
  }
}

class _ExamCountdownCard extends StatelessWidget {
  const _ExamCountdownCard({required this.examDate});
  final DateTime examDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = examDate.difference(now);
    final days = max(0, difference.inDays);
    final isPassed = difference.isNegative;
    Color statusColor = AppColors.of(context).primary;
    if (days < 30) statusColor = AppColors.of(context).danger;
    else if (days < 60) statusColor = Colors.orangeAccent;

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: BorderRadius.circular(20),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.event_available, color: statusColor)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sınav Takvimi', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(isPassed ? 'Sınav Tamamlandı' : '$days Gün Kaldı', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        ])),
        if (!isPassed) _MiniProgressIndicator(total: 365, remaining: 365 - days, color: statusColor),
      ]),
    );
  }
}

class _MiniProgressIndicator extends StatelessWidget {
  const _MiniProgressIndicator({required this.total, required this.remaining, required this.color});
  final int total;
  final int remaining;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = (remaining / total).clamp(0.0, 1.0);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: ratio, strokeWidth: 4, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(color))),
      Text('%${(ratio * 100).round()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }
}

class _ActivityItem {
  _ActivityItem({required this.title, required this.subtitle, required this.timeLabel, required this.badge, required this.icon, required this.accentColor, required this.timestamp});
  final String title;
  final String subtitle;
  final String timeLabel;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final DateTime timestamp;
}

List<_ActivityItem> _buildActivity(BuildContext context, List<QuestionEntry> questionEntries, List<MockExam> mockExams) {
  final items = <_ActivityItem>[];
  for (final entry in questionEntries) {
    items.add(_ActivityItem(title: entry.bookName.isNotEmpty ? entry.bookName : (entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic), subtitle: '${entry.subject} • ${entry.total} soru', timeLabel: _formatTime(entry.createdAt), badge: '${entry.correct} doğru', icon: Icons.quiz, accentColor: AppColors.of(context).primary, timestamp: entry.createdAt));
  }
  for (final exam in mockExams) {
    items.add(_ActivityItem(title: exam.title.isEmpty ? 'Deneme' : exam.title, subtitle: '${exam.totalNet.toStringAsFixed(1)} net', timeLabel: _formatTime(exam.createdAt), badge: '${exam.totalNet.toStringAsFixed(1)} net', icon: Icons.school, accentColor: AppColors.of(context).success, timestamp: exam.createdAt));
  }
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(3).toList();
}

void _showActivitySheet(BuildContext context, List<QuestionEntry> questionEntries, List<MockExam> mockExams) {
  final items = <_ActivityItem>[];
  for (final entry in questionEntries) {
    items.add(_ActivityItem(title: entry.bookName.isNotEmpty ? entry.bookName : (entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic), subtitle: '${entry.subject} • ${entry.total} soru', timeLabel: _formatTime(entry.createdAt), badge: '${entry.correct} doğru', icon: Icons.quiz, accentColor: AppColors.of(context).primary, timestamp: entry.createdAt));
  }
  for (final exam in mockExams) {
    items.add(_ActivityItem(title: exam.title.isEmpty ? 'Deneme' : exam.title, subtitle: '${exam.totalNet.toStringAsFixed(1)} net', timeLabel: _formatTime(exam.createdAt), badge: '${exam.totalNet.toStringAsFixed(1)} net', icon: Icons.school, accentColor: AppColors.of(context).success, timestamp: exam.createdAt));
  }
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(color: AppColors.of(context).surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: Column(children: [
              const SizedBox(height: 8),
              Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 12),
              Text('Tüm Aktiviteler', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(child: items.isEmpty ? Center(child: Text('Henüz kayıt yok.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54))) : ListView.builder(controller: controller, padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (_, index) => _ActivityCard(item: items[index]))),
            ]),
          );
        },
      );
    },
  );
}

int _countTodayQuestions(List<QuestionEntry> entries) {
  final now = DateTime.now();
  return entries.where((entry) => _isSameDay(entry.createdAt, now)).fold(0, (sum, entry) => sum + entry.total);
}

double? _averageNet(List<MockExam> exams) {
  if (exams.isEmpty) return null;
  return exams.fold<double>(0, (sum, item) => sum + item.totalNet) / exams.length;
}

double? _overallAccuracy(List<QuestionEntry> entries) {
  if (entries.isEmpty) return null;
  final correct = entries.fold<int>(0, (sum, entry) => sum + entry.effectiveCorrect);
  final total = entries.fold<int>(0, (sum, entry) => sum + entry.total);
  return total == 0 ? null : correct / total;
}

int _totalQuestions(List<QuestionEntry> entries) => entries.fold<int>(0, (sum, entry) => sum + entry.total);

TopicProgress? _pickFocusTopic(AppRepository repository, List<QuestionEntry> entries) {
  if (entries.isEmpty) return null;
  final progress = repository.buildTopicProgress();
  progress.sort((a, b) {
    if (a.lastStudied == null && b.lastStudied == null) return 0;
    if (a.lastStudied == null) return 1;
    if (b.lastStudied == null) return -1;
    return b.lastStudied!.compareTo(a.lastStudied!);
  });
  return progress.firstWhere((item) => item.totalQuestions > 0, orElse: () => progress.first);
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _formatToday(DateTime date) {
  final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
  return 'Bugün, ${date.day} ${months[date.month - 1]}';
}

String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _formatDateTime(DateTime dateTime) => '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

String _formatTimer(int totalSeconds) {
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

void _showNotificationsSheet(BuildContext context, AppRepository repository) {
  showModalBottomSheet<void>(
    context: context, backgroundColor: AppColors.of(context).surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return ValueListenableBuilder(
        valueListenable: repository.notifications,
        builder: (context, notifications, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SvgPicture.asset('assets/images/KISTAS.svg', height: 28),
                const SizedBox(width: 16),
                Text('Bildirimler', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                TextButton(onPressed: notifications.isEmpty ? null : () => repository.markAllNotificationsRead(), child: const Text('Okundu Yap')),
                const SizedBox(width: 8),
                TextButton(onPressed: notifications.isEmpty ? null : () => repository.clearNotifications(), child: const Text('Temizle')),
              ]),
              const SizedBox(height: 12),
              if (notifications.isEmpty) Text('Henüz bildirim yok.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary))
              else Flexible(child: ListView.separated(shrinkWrap: true, itemCount: notifications.length, separatorBuilder: (_, __) => const Divider(color: Colors.white12), itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  onTap: () => repository.markNotificationRead(item.id),
                  contentPadding: EdgeInsets.zero,
                  leading: item.unread ? Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.of(context).primary)) : const SizedBox(width: 8),
                  title: Text(item.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(item.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary)),
                  trailing: Text(_formatTime(item.createdAt), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.of(context).textSecondary)),
                );
              })),
            ]),
          );
        },
      );
    },
  );
}

Future<void> _requestAiPlan(BuildContext context, AppRepository repository) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) { InAppNotice.show(context, 'Gemini anahtarını profilden ekle.'); return; }
  final userNeed = await showDialog<String>(context: context, builder: (context) {
    final controller = TextEditingController();
    return AlertDialog(title: const Text('Derdi Anlat'), content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: 'Örn: Matematikte zorlanıyorum...')), actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
      ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Program İste')),
    ]);
  });
  if (userNeed == null || userNeed.trim().isEmpty) return;

  final closeLoading = _showLoadingDialog(context, 'AI program hazırlanıyor...');
  try {
    final result = await GeminiClient().generateText(apiKey: apiKey, prompt: 'Kullanıcı derdi: $userNeed. 7 günlük KPSS programı yap.', model: repository.geminiModel.value.isEmpty ? 'gemini-1.5-flash-latest' : repository.geminiModel.value);
    await repository.setAiProgram(result);
    closeLoading();
    if (context.mounted) AiResponseDialog.show(context, 'AI Programı', result);
  } catch (_) { closeLoading(); InAppNotice.show(context, 'AI program alınamadı.'); }
}

Future<void> Function() _showLoadingDialog(BuildContext context, String title) {
  bool isOpen = false;
  AiLoadingDialog.show(context, status: title).then((_) {
    isOpen = false;
  });
  isOpen = true;

  return () async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (isOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      isOpen = false;
    }
  };
}

int _calculateStreak(List<QuestionEntry> entries, List<MockExam> exams) {
  final activityDates = <DateTime>{};
  for (final entry in entries) { activityDates.add(DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day)); }
  for (final exam in exams) { activityDates.add(DateTime(exam.createdAt.year, exam.createdAt.month, exam.createdAt.day)); }
  if (activityDates.isEmpty) return 0;
  var streak = 0;
  var current = DateTime.now();
  while (true) {
    if (!activityDates.contains(DateTime(current.year, current.month, current.day))) break;
    streak++;
    current = current.subtract(const Duration(days: 1));
  }
  return streak;
}
