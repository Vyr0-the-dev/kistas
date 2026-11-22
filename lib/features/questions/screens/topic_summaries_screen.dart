import 'package:flutter/material.dart';

import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/subject_colors.dart';
import '../../../core/widgets/delete_helpers.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../curriculum/screens/curriculum_hub_screen.dart';
import '../../dashboard/screens/roadmap_screen.dart';
import '../../schedule/screens/weekly_schedule_screen.dart';
import 'topic_detail_screen.dart';

enum TopicSort { recent, accuracyLow, accuracyHigh, totalQuestions, alphabetical }

class TopicSummariesScreen extends StatefulWidget {
  const TopicSummariesScreen({super.key});

  @override
  State<TopicSummariesScreen> createState() => _TopicSummariesScreenState();
}

class _TopicSummariesScreenState extends State<TopicSummariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Tümü';
  String _activeTag = 'Tümü';
  bool _weakOnly = false;
  bool _staleOnly = false;
  TopicSort _activeSort = TopicSort.recent;
  final Set<String> _selectedIds = {};
  bool _manualSelectionMode = false;

  bool get _isSelectionMode => _manualSelectionMode || _selectedIds.isNotEmpty;

  bool get _hasSecondaryFilters =>
      _activeTag != 'Tümü' ||
      _weakOnly ||
      _staleOnly ||
      _activeSort != TopicSort.recent;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      _manualSelectionMode = true;
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _manualSelectionMode = false;
    });
  }

  void _selectAll(List<TopicProgress> items) {
    setState(() {
      _manualSelectionMode = true;
      if (_selectedIds.length == items.length) {
        _selectedIds.clear();
      } else {
        for (final item in items) {
          _selectedIds.add(item.topic.id);
        }
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await confirmDeleteDialog(
      context,
      title: '${_selectedIds.length} Konuyu Sil',
      message:
          'Seçili konuları müfredattan silmek istediğine emin misin? (Geçmiş soru kayıtların korunur.)',
    );
    if (confirmed && mounted) {
      final repository = AppRepositoryScope.of(context);
      await repository.deleteUserTopics(_selectedIds.toList());
      _clearSelection();
      if (mounted) {
        _showSnack(context, 'Seçili konular silindi.');
      }
    }
  }

  Future<void> _updateSelectedTag() async {
    final controller = TextEditingController(text: 'Genel');
    final newTag = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${_selectedIds.length} Konunun Etiketini Değiştir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Yeni Etiket (Örn: TYT, AYT, KPSS)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newTag != null && newTag.isNotEmpty && mounted) {
      final repository = AppRepositoryScope.of(context);
      final currentTopics = repository.userTopics.value;
      for (final id in _selectedIds) {
        final idx = currentTopics.indexWhere((t) => t.id == id);
        if (idx != -1) {
          await repository.updateUserTopic(
            currentTopics[idx].copyWith(tag: newTag),
          );
        }
      }
      _clearSelection();
      if (mounted) {
        _showSnack(context, 'Seçili konular "$newTag" olarak güncellendi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return ValueListenableBuilder<List<TopicSummary>>(
      valueListenable: repository.userTopics,
      builder: (context, currentTopics, _) {
        return ValueListenableBuilder(
          valueListenable: repository.questionEntries,
          builder: (context, _, __) {
            final progress = repository.buildTopicProgress();
            final filtered = _applyFilters(progress);

            final tags = currentTopics.map((e) => e.tag).toSet().toList()
              ..sort();
            final effectiveTag =
                (_activeTag != 'Tümü' && tags.contains(_activeTag))
                    ? _activeTag
                    : 'Tümü';
            final tagScopedTopics = effectiveTag == 'Tümü'
                ? currentTopics
                : currentTopics.where((t) => t.tag == effectiveTag).toList();
            final subjects = tagScopedTopics
                .map((e) => e.subject)
                .toSet()
                .toList()
              ..sort();
            final effectiveFilter =
                (_activeFilter != 'Tümü' && subjects.contains(_activeFilter))
                    ? _activeFilter
                    : 'Tümü';

            return PopScope(
              canPop: !_isSelectionMode,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop && _isSelectionMode) {
                  _clearSelection();
                }
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      if (_isSelectionMode)
                        _buildSelectionBar(context, filtered)
                      else
                        _buildCompactHeader(
                          context,
                          currentTopics: currentTopics,
                          tagScopedTopics: tagScopedTopics,
                          tags: tags,
                          subjects: subjects,
                          effectiveTag: effectiveTag,
                          effectiveFilter: effectiveFilter,
                          totalFiltered: filtered.length,
                        ),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState(
                                context,
                                hasAnyTopics: currentTopics.isNotEmpty,
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 120),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected =
                                      _selectedIds.contains(item.topic.id);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _TopicCard(
                                      progress: item,
                                      isSelected: isSelected,
                                      isSelectionMode: _isSelectionMode,
                                      onTap: () {
                                        if (_isSelectionMode) {
                                          _toggleSelection(item.topic.id);
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => TopicDetailScreen(
                                                topic: item.topic,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      onLongPress: () =>
                                          _toggleSelection(item.topic.id),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectionBar(
    BuildContext context,
    List<TopicProgress> filtered,
  ) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _clearSelection,
            icon: Icon(Icons.close_rounded, color: colors.onPrimary),
          ),
          Expanded(
            child: Text(
              '${_selectedIds.length} seçili',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            tooltip: 'Tümünü Seç',
            onPressed: () => _selectAll(filtered),
            icon: Icon(Icons.select_all_rounded, color: colors.onPrimary),
          ),
          IconButton(
            tooltip: 'Etiket Değiştir',
            onPressed: _updateSelectedTag,
            icon: Icon(Icons.label_outline_rounded, color: colors.onPrimary),
          ),
          IconButton(
            tooltip: 'Seçilileri Sil',
            onPressed: _deleteSelected,
            icon: Icon(Icons.delete_outline_rounded, color: colors.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(
    BuildContext context, {
    required List<TopicSummary> currentTopics,
    required List<TopicSummary> tagScopedTopics,
    required List<String> tags,
    required List<String> subjects,
    required String effectiveTag,
    required String effectiveFilter,
    required int totalFiltered,
  }) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Konular',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.subtleFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$totalFiltered',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              _CompactActionBtn(
                icon: Icons.add_rounded,
                tooltip: 'Ders & Müfredat Ekle',
                highlighted: true,
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const CurriculumHubScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CompactActionBtn(
                icon: Icons.tune_rounded,
                tooltip: 'Filtre & Sırala',
                showDot: _hasSecondaryFilters,
                onTap: () => _openFilterSheet(context, tags),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                tooltip: 'Diğer İşlemler',
                icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary),
                onSelected: (action) {
                  if (action == 'manage') {
                    _showManageTagsSheet(context, currentTopics);
                  } else if (action == 'schedule') {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => const WeeklyScheduleScreen(),
                      ),
                    );
                  } else if (action == 'roadmap') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'manage',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.label_outline_rounded, size: 20),
                      title: Text('Sınav & Ders Yönetimi'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'schedule',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_month_outlined, size: 20),
                      title: Text('Haftalık Program'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'roadmap',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.map_outlined, size: 20),
                      title: Text('Konu Yol Haritası'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clean single search bar
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colors.textMuted,
                size: 20,
              ),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colors.textMuted,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
              hintText: 'Konu veya ders ara...',
              fillColor: colors.surface,
            ),
          ),
          if (subjects.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SubjectFilterPill(
                    label: 'Tümü',
                    selected: effectiveFilter == 'Tümü',
                    dotColor: null,
                    onTap: () => setState(() => _activeFilter = 'Tümü'),
                  ),
                  ...subjects.map((subject) {
                    final style = SubjectColors.of(
                      subject,
                      isDark: colors.isDark,
                    );
                    return _SubjectFilterPill(
                      label: subject,
                      selected: effectiveFilter == subject,
                      dotColor: style.accent,
                      onTap: () => setState(() => _activeFilter = subject),
                      onLongPress: () => _openSubjectQuickActions(
                        context,
                        subject: subject,
                        scopedTopics: tagScopedTopics,
                        scopedTag:
                            effectiveTag == 'Tümü' ? null : effectiveTag,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          if (effectiveTag != 'Tümü' ||
              _weakOnly ||
              _staleOnly ||
              _activeSort != TopicSort.recent) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (effectiveTag != 'Tümü')
                  _ActiveFilterBadge(
                    label: effectiveTag,
                    onClear: () => setState(() {
                      _activeTag = 'Tümü';
                      _activeFilter = 'Tümü';
                    }),
                  ),
                if (_weakOnly)
                  _ActiveFilterBadge(
                    label: 'Zayıf Konular',
                    onClear: () => setState(() => _weakOnly = false),
                  ),
                if (_staleOnly)
                  _ActiveFilterBadge(
                    label: 'Tekrar Gereken',
                    onClear: () => setState(() => _staleOnly = false),
                  ),
                if (_activeSort != TopicSort.recent)
                  _ActiveFilterBadge(
                    label: _sortLabel(_activeSort),
                    onClear: () =>
                        setState(() => _activeSort = TopicSort.recent),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context, List<String> tags) {
    final colors = AppColors.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filtre & Sıralama',
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (_hasSecondaryFilters)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _activeTag = 'Tümü';
                                _activeFilter = 'Tümü';
                                _weakOnly = false;
                                _staleOnly = false;
                                _activeSort = TopicSort.recent;
                              });
                              setModalState(() {});
                            },
                            child: const Text('Sıfırla'),
                          ),
                      ],
                    ),
                    if (tags.length > 1) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Sınav / Kategori',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Tümü', ...tags].map((tag) {
                          return ChoiceChip(
                            label: Text(tag),
                            selected: _activeTag == tag,
                            onSelected: (_) {
                              setState(() {
                                _activeTag = tag;
                                _activeFilter = 'Tümü';
                              });
                              setModalState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      'Durum',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Zayıf (<%50)'),
                          selected: _weakOnly,
                          onSelected: (v) {
                            setState(() => _weakOnly = v);
                            setModalState(() {});
                          },
                        ),
                        FilterChip(
                          label: const Text('Tekrar Gereken (7g+)'),
                          selected: _staleOnly,
                          onSelected: (v) {
                            setState(() => _staleOnly = v);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sıralama',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    ...TopicSort.values.map((sort) {
                      final active = _activeSort == sort;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _sortLabel(sort),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          active
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: active ? colors.primary : colors.textMuted,
                          size: 20,
                        ),
                        onTap: () {
                          setState(() => _activeSort = sort);
                          setModalState(() {});
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Uygula'),
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

  Widget _buildEmptyState(BuildContext context, {required bool hasAnyTopics}) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: colors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              hasAnyTopics
                  ? 'Filtreye uygun konu bulunamadı.'
                  : 'Henüz ders veya konu eklenmedi.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasAnyTopics
                  ? 'Aramayı temizleyebilir veya filtreleri sıfırlayabilirsin.'
                  : 'Maarif TYT/AYT, KPSS, YDS gibi hazır paketleri tek dokunuşla ekleyebilir veya kendi dersini kurabilirsin.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            if (hasAnyTopics)
              OutlinedButton(
                onPressed: () => setState(() {
                  _searchController.clear();
                  _activeTag = 'Tümü';
                  _activeFilter = 'Tümü';
                  _weakOnly = false;
                  _staleOnly = false;
                  _activeSort = TopicSort.recent;
                }),
                child: const Text('Filtreleri Temizle'),
              )
            else
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const CurriculumHubScreen(),
                  ),
                ),
                icon: const Icon(Icons.auto_stories_outlined),
                label: const Text('Ders / Sınav Paketi Ekle'),
              ),
          ],
        ),
      ),
    );
  }

  List<TopicProgress> _applyFilters(List<TopicProgress> items) {
    final query = _searchController.text.trim().toLowerCase();
    var filtered = [...items];

    final availableTags = items.map((e) => e.topic.tag).toSet();
    final effectiveTag =
        (_activeTag != 'Tümü' && availableTags.contains(_activeTag))
            ? _activeTag
            : 'Tümü';

    if (effectiveTag != 'Tümü') {
      filtered =
          filtered.where((item) => item.topic.tag == effectiveTag).toList();
    }

    final availableSubjects = filtered.map((e) => e.topic.subject).toSet();
    final effectiveSubject =
        (_activeFilter != 'Tümü' && availableSubjects.contains(_activeFilter))
            ? _activeFilter
            : 'Tümü';

    if (effectiveSubject != 'Tümü') {
      filtered = filtered
          .where((item) => item.topic.subject == effectiveSubject)
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
              item.topic.subject.toLowerCase().contains(query) ||
              item.topic.tag.toLowerCase().contains(query))
          .toList();
    }
    filtered.sort((a, b) => _sortByActive(a, b, _activeSort));
    return filtered;
  }

  void _showManageTagsSheet(BuildContext context, List<TopicSummary> _) {
    final repository = AppRepositoryScope.of(context);
    var showSubjects = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          return ValueListenableBuilder<List<TopicSummary>>(
            valueListenable: repository.userTopics,
            builder: (sheetContext, liveTopics, __) {
              final tags = liveTopics.map((e) => e.tag).toSet().toList()..sort();
              final subjectEntriesMap = <String, ({String tag, String subject, int count})>{};
              for (final topic in liveTopics) {
                final key = '${topic.tag}||${topic.subject}';
                final existing = subjectEntriesMap[key];
                subjectEntriesMap[key] = (
                  tag: topic.tag,
                  subject: topic.subject,
                  count: (existing?.count ?? 0) + 1,
                );
              }
              final subjectEntries = subjectEntriesMap.values.toList()
                ..sort((a, b) {
                  final byTag = a.tag.compareTo(b.tag);
                  return byTag != 0 ? byTag : a.subject.compareTo(b.subject);
                });
              final colors = AppColors.of(sheetContext);

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Sınav & Ders Yönetimi',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Text('Sınavlar (${tags.length})'),
                              selected: !showSubjects,
                              onSelected: (_) =>
                                  setModalState(() => showSubjects = false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Text('Dersler (${subjectEntries.length})'),
                              selected: showSubjects,
                              onSelected: (_) =>
                                  setModalState(() => showSubjects = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!showSubjects) ...[
                        if (tags.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Henüz sınav etiketi yok.',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          )
                        else
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(sheetContext).size.height * 0.48,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: tags.length,
                              itemBuilder: (context, index) {
                                final tag = tags[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    tag,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${liveTopics.where((t) => t.tag == tag).length} konu',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Yeniden Adlandır',
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: colors.textSecondary,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _renameTag(sheetContext, tag, liveTopics),
                                      ),
                                      IconButton(
                                        tooltip: 'Sınavı ve Konularını Sil',
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colors.danger,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _deleteTag(sheetContext, tag, liveTopics),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ] else ...[
                        if (subjectEntries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Henüz ders yok.',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          )
                        else
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(sheetContext).size.height * 0.48,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: subjectEntries.length,
                              itemBuilder: (context, index) {
                                final entry = subjectEntries[index];
                                final style = SubjectColors.of(
                                  entry.subject,
                                  isDark: colors.isDark,
                                );
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: style.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  title: Text(
                                    entry.subject,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${entry.count} konu • ${entry.tag}',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Dersi Yeniden Adlandır',
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: colors.textSecondary,
                                          size: 20,
                                        ),
                                        onPressed: () => _renameSubject(
                                          sheetContext,
                                          entry.subject,
                                          tag: entry.tag,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Dersi ve Konularını Kaldır',
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colors.danger,
                                          size: 20,
                                        ),
                                        onPressed: () => _deleteSubject(
                                          sheetContext,
                                          entry.subject,
                                          entry.count,
                                          tag: entry.tag,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openSubjectQuickActions(
    BuildContext context, {
    required String subject,
    required List<TopicSummary> scopedTopics,
    required String? scopedTag,
  }) {
    final matching = scopedTopics.where((t) => t.subject == subject).toList();
    if (matching.isEmpty) return;

    final tagsForSubject = matching.map((t) => t.tag).toSet().toList()..sort();
    final effectiveTag = scopedTag ??
        (tagsForSubject.length == 1 ? tagsForSubject.first : null);
    final colors = AppColors.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetColors = AppColors.of(sheetContext);
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
                      color: sheetColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  subject,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        color: sheetColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  effectiveTag != null
                      ? '${matching.length} konu • $effectiveTag'
                      : '${matching.length} konu • ${tagsForSubject.join(', ')}',
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                        color: sheetColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.edit_outlined,
                    color: sheetColors.textPrimary,
                  ),
                  title: const Text('Dersi Yeniden Adlandır'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _renameSubject(context, subject, tag: effectiveTag);
                  },
                ),
                if (effectiveTag != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: sheetColors.danger,
                    ),
                    title: Text(
                      'Dersi Kaldır ($effectiveTag)',
                      style: TextStyle(
                        color: sheetColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _deleteSubject(
                        context,
                        subject,
                        matching.length,
                        tag: effectiveTag,
                      );
                    },
                  )
                else ...[
                  ...tagsForSubject.map((tag) {
                    final tagCount =
                        matching.where((t) => t.tag == tag).length;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.remove_circle_outline_rounded,
                        color: sheetColors.danger,
                      ),
                      title: Text(
                        '$tag paketinden kaldır',
                        style: TextStyle(
                          color: sheetColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text('$tagCount konu'),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _deleteSubject(
                          context,
                          subject,
                          tagCount,
                          tag: tag,
                        );
                      },
                    );
                  }),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: sheetColors.danger,
                    ),
                    title: Text(
                      'Tüm paketlerden kaldır',
                      style: TextStyle(
                        color: sheetColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text('${matching.length} konu'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _deleteSubject(context, subject, matching.length);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _renameSubject(
    BuildContext sheetContext,
    String oldSubject, {
    String? tag,
  }) async {
    final controller = TextEditingController(text: oldSubject);
    final newName = await showDialog<String>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dersi Yeniden Adlandır'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName != null &&
        newName.isNotEmpty &&
        newName != oldSubject &&
        mounted) {
      final repository = AppRepositoryScope.of(context);
      await repository.renameSubject(
        oldSubject: oldSubject,
        newSubject: newName,
        tag: tag,
      );
      if (mounted) {
        if (_activeFilter == oldSubject) {
          setState(() => _activeFilter = newName);
        }
        _showSnack(context, '"$oldSubject" dersinin adı "$newName" yapıldı.');
      }
    }
  }

  Future<void> _deleteSubject(
    BuildContext sheetContext,
    String subject,
    int topicCount, {
    String? tag,
  }) async {
    final scopeText = tag != null ? '$tag paketindeki "$subject"' : '"$subject"';
    final confirmed = await confirmDeleteDialog(
      sheetContext,
      title: 'Dersi Kaldır: $subject',
      message:
          '$scopeText dersine ait $topicCount konu müfredattan kaldırılacak (geçmiş soru kayıtların korunur). Emin misin?',
      confirmLabel: 'Dersi Kaldır',
    );
    if (confirmed && mounted) {
      final repository = AppRepositoryScope.of(context);
      await repository.deleteSubject(subject, tag: tag);
      if (mounted) {
        if (_activeFilter == subject) setState(() => _activeFilter = 'Tümü');
        _showSnack(context, '$scopeText dersi kaldırıldı.');
      }
    }
  }

  Future<void> _renameTag(
    BuildContext sheetContext,
    String oldTag,
    List<TopicSummary> allTopics,
  ) async {
    final controller = TextEditingController(text: oldTag);
    final newName = await showDialog<String>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Etiketi Düzenle'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName != null && newName.isNotEmpty && newName != oldTag && mounted) {
      final repository = AppRepositoryScope.of(context);
      await repository.renameExamProfile(oldTag, newName);
      if (mounted) {
        if (_activeTag == oldTag) setState(() => _activeTag = newName);
        _showSnack(context, 'Etiket güncellendi.');
      }
    }
  }

  Future<void> _deleteTag(
    BuildContext sheetContext,
    String tag,
    List<TopicSummary> allTopics,
  ) async {
    final confirmed = await confirmDeleteDialog(
      sheetContext,
      title: 'Kategoriyi Sil: $tag',
      message:
          'Bu kategoriye ait tüm konular listeden silinecek (geçmiş soru kayıtların korunur). Emin misin?',
      confirmLabel: 'Hepsini Sil',
    );
    if (confirmed && mounted) {
      final repository = AppRepositoryScope.of(context);
      final idsToDelete =
          allTopics.where((t) => t.tag == tag).map((t) => t.id).toList();
      await repository.deleteUserTopics(idsToDelete);
      await repository.deleteExamProfile(tag);
      if (mounted) {
        if (_activeTag == tag) setState(() => _activeTag = 'Tümü');
        _showSnack(context, '$tag kategorisi ve konuları silindi.');
      }
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CompactActionBtn extends StatelessWidget {
  const _CompactActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.highlighted = false,
    this.showDot = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlighted;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: highlighted ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: highlighted ? null : Border.all(color: colors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: highlighted ? colors.onPrimary : colors.textPrimary,
              ),
              if (showDot)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.primary,
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

class _SubjectFilterPill extends StatelessWidget {
  const _SubjectFilterPill({
    required this.label,
    required this.selected,
    required this.dotColor,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool selected;
  final Color? dotColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final activeBg = dotColor ?? colors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? activeBg.withValues(alpha: colors.isDark ? 0.24 : 0.14)
                : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? activeBg : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? activeBg : colors.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterBadge extends StatelessWidget {
  const _ActiveFilterBadge({required this.label, required this.onClear});
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InputChip(
      label: Text(label),
      onDeleted: onClear,
      visualDensity: VisualDensity.compact,
      backgroundColor: colors.primary.withValues(alpha: 0.12),
      deleteIconColor: colors.primary,
      labelStyle: TextStyle(
        color: colors.primary,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: colors.primary.withValues(alpha: 0.28)),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.progress,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final TopicProgress progress;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final subjectStyle = SubjectColors.of(
      progress.topic.subject,
      isDark: colors.isDark,
    );
    final hasData = progress.totalQuestions > 0;
    final accuracyPct = (progress.accuracy * 100).round();
    final progressVal = (progress.totalQuestions / 100).clamp(0.0, 1.0);
    final statusColor = !hasData
        ? colors.textMuted
        : progress.accuracy < 0.5
            ? colors.danger
            : progress.accuracy >= 0.8
                ? colors.success
                : colors.warning;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(18),
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        radius: BorderRadius.circular(18),
        borderColor: isSelected ? colors.primary : colors.border,
        color: isSelected
            ? colors.primary.withValues(alpha: colors.isDark ? 0.16 : 0.08)
            : colors.surface,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 46,
              decoration: BoxDecoration(
                color: subjectStyle.accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          progress.topic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSelectionMode)
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? colors.primary : colors.textMuted,
                          size: 20,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hasData ? '%$accuracyPct' : 'Yeni',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${progress.topic.subject} • ${progress.topic.tag}'
                    '${hasData ? ' • ${progress.totalQuestions} soru' : ''}'
                    '${progress.lastStudied != null ? ' • ${_daysAgoLabel(progress.lastStudied!)}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: hasData ? progressVal.clamp(0.06, 1.0) : 0,
                      minHeight: 4.5,
                      backgroundColor: colors.subtleFill,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(subjectStyle.accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _daysAgoLabel(DateTime date) {
  final days = DateTime.now().difference(date).inDays;
  if (days <= 0) return 'Bugün';
  if (days == 1) return 'Dün';
  return '$days gün önce';
}

String _sortLabel(TopicSort sort) {
  switch (sort) {
    case TopicSort.recent:
      return 'En son çalışılan';
    case TopicSort.accuracyLow:
      return 'Doğruluk: Düşükten yükseğe';
    case TopicSort.accuracyHigh:
      return 'Doğruluk: Yüksekten düşüğe';
    case TopicSort.totalQuestions:
      return 'En çok çözülen';
    case TopicSort.alphabetical:
      return 'Alfabetik (A–Z)';
  }
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
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}
