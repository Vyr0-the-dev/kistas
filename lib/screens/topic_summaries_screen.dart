import 'package:flutter/material.dart';

import '../services/app_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_background.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import 'analysis_screen.dart';
import 'entry_wizard_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'quick_add_screen.dart';
import 'topic_detail_screen.dart';

class TopicSummariesScreen extends StatefulWidget {
  const TopicSummariesScreen({super.key});

  @override
  State<TopicSummariesScreen> createState() => _TopicSummariesScreenState();
}

class _TopicSummariesScreenState extends State<TopicSummariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Tümü';
  bool _weakOnly = false;
  bool _staleOnly = false;
  TopicSort _activeSort = TopicSort.recent;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: repository.questionEntries,
            builder: (context, _, __) {
              final progress = repository.buildTopicProgress();
              final filtered = _applyFilters(progress);
              return Column(
                children: [
                  _Header(
                    controller: _searchController,
                    onFilterChanged: (value) => setState(() {
                      _activeFilter = value;
                    }),
                    activeFilter: _activeFilter,
                    weakOnly: _weakOnly,
                    staleOnly: _staleOnly,
                    onToggleWeak: () => setState(() {
                      _weakOnly = !_weakOnly;
                    }),
                    onToggleStale: () => setState(() {
                      _staleOnly = !_staleOnly;
                    }),
                    onOpenSort: () => _openSortSheet(context),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _TopicCard(
                            progress: item,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TopicDetailScreen(
                                    topic: item.topic,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: 1,
        onSelect: (index) => _navigateFromNav(context, index),
      ),
    );
  }

  List<TopicProgress> _applyFilters(List<TopicProgress> items) {
    final query = _searchController.text.trim().toLowerCase();
    var filtered = [...items];
    if (_activeFilter != 'Tümü') {
      filtered = filtered
          .where((item) => item.topic.subject == _activeFilter)
          .toList();
    }
    if (_weakOnly) {
      filtered = filtered
          .where((item) => item.totalQuestions > 0 && item.accuracy < 0.5)
          .toList();
    }
    if (_staleOnly) {
      final now = DateTime.now();
      filtered = filtered
          .where((item) =>
              item.lastStudied != null &&
              now.difference(item.lastStudied!).inDays >= 7)
          .toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.topic.title.toLowerCase().contains(query) ||
              item.topic.subject.toLowerCase().contains(query))
          .toList();
    }
    filtered.sort((a, b) => _sortByActive(a, b, _activeSort));
    return filtered;
  }

  void _navigateFromNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        return;
      case 1:
        return;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => QuickAddScreen()),
        );
        return;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AnalysisScreen()),
        );
        return;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        return;
    }
  }

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Sıralama',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 12),
              _SortOption(
                label: 'En son çalışılan',
                active: _activeSort == TopicSort.recent,
                onTap: () => _selectSort(context, TopicSort.recent),
              ),
              _SortOption(
                label: 'Doğruluk düşükten yükseğe',
                active: _activeSort == TopicSort.accuracyLow,
                onTap: () => _selectSort(context, TopicSort.accuracyLow),
              ),
              _SortOption(
                label: 'Doğruluk yüksekten düşüğe',
                active: _activeSort == TopicSort.accuracyHigh,
                onTap: () => _selectSort(context, TopicSort.accuracyHigh),
              ),
              _SortOption(
                label: 'Toplam soru (yüksekten)',
                active: _activeSort == TopicSort.totalQuestions,
                onTap: () => _selectSort(context, TopicSort.totalQuestions),
              ),
              _SortOption(
                label: 'Alfabetik',
                active: _activeSort == TopicSort.alphabetical,
                onTap: () => _selectSort(context, TopicSort.alphabetical),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectSort(BuildContext context, TopicSort sort) {
    setState(() => _activeSort = sort);
    Navigator.of(context).pop();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.onFilterChanged,
    required this.activeFilter,
    required this.weakOnly,
    required this.staleOnly,
    required this.onToggleWeak,
    required this.onToggleStale,
    required this.onOpenSort,
  });

  final TextEditingController controller;
  final ValueChanged<String> onFilterChanged;
  final String activeFilter;
  final bool weakOnly;
  final bool staleOnly;
  final VoidCallback onToggleWeak;
  final VoidCallback onToggleStale;
  final VoidCallback onOpenSort;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.only(bottom: 12),
      radius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(
                'Konular',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: AppColors.of(context).textSecondary),
              hintText: 'Konu, ders veya etiket ara...'
            ),
            onChanged: (_) => onFilterChanged(activeFilter),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ChipButton(
                label: 'Tümü',
                active: activeFilter == 'Tümü',
                onTap: () => onFilterChanged('Tümü'),
              ),
              _ChipButton(
                label: 'Matematik',
                active: activeFilter == 'Matematik',
                onTap: () => onFilterChanged('Matematik'),
              ),
              _ChipButton(
                label: 'Türkçe',
                active: activeFilter == 'Türkçe',
                onTap: () => onFilterChanged('Türkçe'),
              ),
              _ChipButton(
                label: 'Tarih',
                active: activeFilter == 'Tarih',
                onTap: () => onFilterChanged('Tarih'),
              ),
              _ChipButton(
                label: 'Coğrafya',
                active: activeFilter == 'Coğrafya',
                onTap: () => onFilterChanged('Coğrafya'),
              ),
              _ChipButton(
                label: 'Vatandaşlık',
                active: activeFilter == 'Vatandaşlık',
                onTap: () => onFilterChanged('Vatandaşlık'),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: onOpenSort,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sort, color: Colors.white70, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Sırala',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                width: 1,
                height: 24,
                color: Colors.white12,
              ),
              SizedBox(width: 12),
              _FilterToggle(
                label: 'Zayıf',
                color: AppColors.of(context).danger,
                active: weakOnly,
                onTap: onToggleWeak,
              ),
              SizedBox(width: 8),
              _FilterToggle(
                label: 'Uzun süre önce',
                color: AppColors.of(context).warning,
                icon: Icons.history,
                active: staleOnly,
                onTap: onToggleStale,
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.of(context).primary : AppColors.of(context).surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active ? Theme.of(context).colorScheme.onPrimary : AppColors.of(context).textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.label,
    required this.color,
    this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(active ? 0.5 : 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: color),
              SizedBox(width: 4),
            ] else
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.progress, required this.onTap});

  final TopicProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusFromProgress(context, progress);
    final statusColor = status.color;
    final timeLabel = progress.lastStudied == null
        ? 'Hiç çalışılmadı'
        : '${_daysAgo(progress.lastStudied!)} gün önce';

    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.topic.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${progress.topic.subject} • KPSS',
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(status.icon, color: statusColor, size: 14),
                          SizedBox(width: 4),
                          Text(
                            progress.totalQuestions == 0
                                ? '—'
                                : '%${progress.progressPercent}',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.of(context).textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İlerleme',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
                Text(
                  progress.totalQuestions == 0
                      ? '0%'
                      : '%${progress.progressPercent}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.progressRatio,
                minHeight: 6,
                backgroundColor: AppColors.of(context).surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

_StatusInfo _statusFromProgress(BuildContext context, TopicProgress progress) {
  if (progress.totalQuestions == 0) {
    return const _StatusInfo(icon: Icons.remove, color: Colors.white54);
  }
  if (progress.accuracy < 0.5) {
    return _StatusInfo(icon: Icons.warning, color: AppColors.of(context).danger);
  }
  if (progress.accuracy >= 0.8) {
    return _StatusInfo(icon: Icons.check_circle, color: AppColors.of(context).success);
  }
  return _StatusInfo(icon: Icons.trending_up, color: AppColors.of(context).warning);
}

int _daysAgo(DateTime date) {
  final now = DateTime.now();
  return now.difference(date).inDays;
}

int _sortByActive(TopicProgress a, TopicProgress b, TopicSort sort) {
  switch (sort) {
    case TopicSort.recent:
      return _compareDatesDesc(a.lastStudied, b.lastStudied);
    case TopicSort.accuracyLow:
      return a.accuracy.compareTo(b.accuracy);
    case TopicSort.accuracyHigh:
      return b.accuracy.compareTo(a.accuracy);
    case TopicSort.totalQuestions:
      return b.totalQuestions.compareTo(a.totalQuestions);
    case TopicSort.alphabetical:
      return a.topic.title.compareTo(b.topic.title);
  }
}

int _compareDatesDesc(DateTime? a, DateTime? b) {
  if (a == null && b == null) {
    return 0;
  }
  if (a == null) {
    return 1;
  }
  if (b == null) {
    return -1;
  }
  return b.compareTo(a);
}

enum TopicSort {
  recent,
  accuracyLow,
  accuracyHigh,
  totalQuestions,
  alphabetical,
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

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
      ),
      trailing: active
          ? Icon(Icons.check_circle, color: AppColors.of(context).primary)
          : Icon(Icons.circle_outlined, color: Colors.white38),
    );
  }
}
