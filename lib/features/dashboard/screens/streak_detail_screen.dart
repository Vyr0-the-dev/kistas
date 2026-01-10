import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/models/mock_exam.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_panel.dart';

class StreakDetailScreen extends StatelessWidget {
  const StreakDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: SafeArea(
          child: ValueListenableBuilder<List<QuestionEntry>>(
            valueListenable: repository.questionEntries,
            builder: (context, questions, _) {
              return ValueListenableBuilder<List<MockExam>>(
                valueListenable: repository.mockExams,
                builder: (context, exams, __) {
                  final streakData = _calculateStreakData(questions, exams);
                  final heatmapData = _buildHeatmapData(questions, exams);
                  
                  return CustomScrollView(
                    slivers: [
                      _buildHeader(context, streakData.currentStreak),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStreakHero(context, streakData),
                              const SizedBox(height: 24),
                              _buildSectionTitle(context, 'Çalışma Yoğunluğu', Icons.grid_view),
                              const SizedBox(height: 12),
                              _HeatmapWidget(data: heatmapData),
                              const SizedBox(height: 24),
                              _buildSectionTitle(context, 'Haftalık İlerleme', Icons.bar_chart),
                              const SizedBox(height: 12),
                              _WeeklyBarChart(questions: questions),
                              const SizedBox(height: 24),
                              _buildSectionTitle(context, 'İstatistikler', Icons.analytics),
                              const SizedBox(height: 12),
                              _StreakStatsRow(data: streakData),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int streak) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Çalışma Serisi',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      floating: true,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.of(context).primaryLight),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }

  Widget _buildStreakHero(BuildContext context, _StreakData data) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      radius: BorderRadius.circular(28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harikasın!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.currentStreak} gündür hiç aksatmadan çalışıyorsun.',
                  style: const TextStyle(color: Colors.white60, height: 1.4),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.local_fire_department, size: 80, color: Colors.orange),
              Positioned(
                bottom: 10,
                child: Text(
                  '${data.currentStreak}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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

class _HeatmapWidget extends StatelessWidget {
  const _HeatmapWidget({required this.data});
  final Map<DateTime, int> data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final startDate = mondayOfThisWeek.subtract(const Duration(days: 17 * 7));
    
    return SizedBox(
      width: double.infinity,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(20),
        child: Row(
          children: [
            _buildDayLabels(),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: List.generate(18, (weekIndex) {
                    return Column(
                      children: List.generate(7, (dayIndex) {
                        final date = startDate.add(Duration(days: (weekIndex * 7) + dayIndex));
                        if (date.isAfter(now)) return const SizedBox(width: 14, height: 14);
                        
                        final count = data[DateTime(date.year, date.month, date.day)] ?? 0;
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _getColorForCount(context, count),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayLabels() {
    return Column(
      children: [
        _dayLabel('Pzt'),
        _dayLabel(''),
        _dayLabel('Çar'),
        _dayLabel(''),
        _dayLabel('Cum'),
        _dayLabel(''),
        _dayLabel('Pzr'),
      ],
    );
  }

  Widget _dayLabel(String label) {
    return Container(
      height: 12,
      margin: const EdgeInsets.all(2),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getColorForCount(BuildContext context, int count) {
    if (count == 0) return Colors.white.withOpacity(0.05);
    if (count < 50) return AppColors.of(context).primary.withOpacity(0.3);
    if (count < 150) return AppColors.of(context).primary.withOpacity(0.6);
    return AppColors.of(context).primary;
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.questions});
  final List<QuestionEntry> questions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    
    final List<int> weeklyCounts = List.generate(7, (index) {
      final date = mondayOfThisWeek.add(Duration(days: index));
      return questions
          .where((e) => _isSameDay(e.createdAt, date))
          .fold(0, (sum, e) => sum + e.total);
    });

    final maxCount = weeklyCounts.reduce(max).toDouble().clamp(1.0, double.infinity);

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      radius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final height = (weeklyCounts[index] / maxCount) * 100;
          final date = mondayOfThisWeek.add(Duration(days: index));
          final isToday = _isSameDay(date, now);

          return Column(
            children: [
              Text(
                '${weeklyCounts[index]}',
                style: TextStyle(
                  fontSize: 10,
                  color: isToday ? AppColors.of(context).primaryLight : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 24,
                height: height.clamp(4.0, 100.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isToday ? AppColors.of(context).primaryLight : AppColors.of(context).primary,
                      AppColors.of(context).primary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getWeekdayInitial(date.weekday),
                style: TextStyle(
                  fontSize: 10,
                  color: isToday ? Colors.white : Colors.white38,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getWeekdayInitial(int weekday) {
    switch (weekday) {
      case 1: return 'Pzt';
      case 2: return 'Sal';
      case 3: return 'Çar';
      case 4: return 'Per';
      case 5: return 'Cum';
      case 6: return 'Cmt';
      case 7: return 'Paz';
      default: return '';
    }
  }
}

class _StreakStatsRow extends StatelessWidget {
  const _StreakStatsRow({required this.data});
  final _StreakData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(label: 'En Uzun Seri', value: '${data.bestStreak} Gün', icon: Icons.emoji_events),
        const SizedBox(width: 12),
        _StatItem(label: 'Toplam Gün', value: '${data.totalActiveDays} Gün', icon: Icons.calendar_today),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.of(context).primaryLight),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StreakData {
  final int currentStreak;
  final int bestStreak;
  final int totalActiveDays;
  _StreakData({required this.currentStreak, required this.bestStreak, required this.totalActiveDays});
}

_StreakData _calculateStreakData(List<QuestionEntry> questions, List<MockExam> exams) {
  final dates = <DateTime>{};
  for (var q in questions) {
    dates.add(DateTime(q.createdAt.year, q.createdAt.month, q.createdAt.day));
  }
  for (var e in exams) {
    dates.add(DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day));
  }
  
  if (dates.isEmpty) return _StreakData(currentStreak: 0, bestStreak: 0, totalActiveDays: 0);
  
  int current = 0;
  DateTime checkDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
  // Bugünü kontrol et, eğer bugün yoksa dünle başla
  if (!dates.contains(checkDate)) {
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  while (dates.contains(checkDate)) {
    current++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  // Best streak
  int best = 0;
  int temp = 0;
  final allSorted = dates.toList()..sort();
  if (allSorted.isNotEmpty) {
    best = 1;
    temp = 1;
    for (int i = 0; i < allSorted.length - 1; i++) {
      if (allSorted[i+1].difference(allSorted[i]).inDays == 1) {
        temp++;
        best = max(best, temp);
      } else {
        temp = 1;
      }
    }
  }

  return _StreakData(
    currentStreak: current,
    bestStreak: best,
    totalActiveDays: dates.length,
  );
}

Map<DateTime, int> _buildHeatmapData(List<QuestionEntry> questions, List<MockExam> exams) {
  final Map<DateTime, int> data = {};
  for (var q in questions) {
    final d = DateTime(q.createdAt.year, q.createdAt.month, q.createdAt.day);
    data[d] = (data[d] ?? 0) + q.total;
  }
  for (var e in exams) {
    final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    data[d] = (data[d] ?? 0) + 120; // Denemeyi 120 soru sayalım heatmap için
  }
  return data;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
