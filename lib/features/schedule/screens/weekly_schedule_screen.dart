import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/study_schedule_block.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/gemini_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/subject_colors.dart';
import '../../../core/widgets/ai_loading_dialog.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/delete_helpers.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/in_app_notice.dart';
import '../../curriculum/screens/curriculum_hub_screen.dart';
import '../../questions/screens/entry_wizard_screen.dart';
import '../widgets/schedule_sheets.dart';

sealed class _ScheduleDragPayload {
  const _ScheduleDragPayload();
}

class _NewCourseDrag extends _ScheduleDragPayload {
  const _NewCourseDrag({
    required this.subject,
    required this.tag,
    this.topic = '',
  });
  final String subject;
  final String tag;
  final String topic;
}

class _MoveBlockDrag extends _ScheduleDragPayload {
  const _MoveBlockDrag(this.block);
  final StudyScheduleBlock block;
}

const List<String> _shortWeekdays = [
  'Pzt',
  'Sal',
  'Çar',
  'Per',
  'Cum',
  'Cmt',
  'Paz',
];

const List<String> _fullWeekdays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

const List<String> _shortMonths = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key, this.initialWeekday});

  final int? initialWeekday;

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  late int _selectedWeekday;
  late DateTime _selectedWeekMonday;
  bool _overviewMode = false;
  bool _paletteOpen = false;
  bool _topicPaletteMode = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedWeekMonday = StudyScheduleBlock.mondayOf(now);
    _selectedWeekday = (widget.initialWeekday ?? now.weekday)
        .clamp(DateTime.monday, DateTime.sunday);
  }

  String get _selectedWeekKey =>
      StudyScheduleBlock.weekKeyFor(_selectedWeekMonday);

  int get _weekOffsetFromCurrent {
    final currentMonday = StudyScheduleBlock.mondayOf(DateTime.now());
    return _selectedWeekMonday.difference(currentMonday).inDays ~/ 7;
  }

  void _shiftWeek(int deltaWeeks) {
    setState(() {
      _selectedWeekMonday =
          _selectedWeekMonday.add(Duration(days: 7 * deltaWeeks));
    });
  }

  void _jumpToCurrentWeek() {
    final now = DateTime.now();
    setState(() {
      _selectedWeekMonday = StudyScheduleBlock.mondayOf(now);
      _selectedWeekday = now.weekday;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: AmbientBackground(
        child: SafeArea(
          child: ValueListenableBuilder<List<TopicSummary>>(
            valueListenable: repository.userTopics,
            builder: (context, topics, _) {
              return ValueListenableBuilder<List<StudyScheduleBlock>>(
                valueListenable: repository.weeklySchedule,
                builder: (context, _, __) {
                  final weekBlocks =
                      repository.scheduleForWeek(_selectedWeekMonday);
                  final paletteSubjects = _extractSubjectPalette(topics);
                  final showPalette = _paletteOpen || weekBlocks.isEmpty;
                  return Column(
                    children: [
                      _buildHeader(context, repository, weekBlocks, showPalette),
                      const SizedBox(height: 8),
                      _buildWeekNavigator(context),
                      const SizedBox(height: 8),
                      _buildDayTabs(context, repository, weekBlocks),
                      const SizedBox(height: 10),
                      if (showPalette) ...[
                        _buildPaletteSection(
                          context,
                          repository,
                          paletteSubjects,
                          topics,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Expanded(
                        child: _overviewMode
                            ? _buildWeeklyOverview(
                                context,
                                repository,
                                topics,
                              )
                            : _buildDayDetail(
                                context,
                                repository,
                                topics,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBlockEditor(
          context,
          repository,
          weekday: _selectedWeekday,
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text(
          'Görev Ekle',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppRepository repository,
    List<StudyScheduleBlock> weekBlocks,
    bool showPalette,
  ) {
    final colors = AppColors.of(context);
    final weekKey = _selectedWeekKey;
    var totalTasks = 0;
    var completedCount = 0;
    for (final block in weekBlocks) {
      for (final day in block.activeWeekdaysInWeek()) {
        totalTasks++;
        if (block.isCompletedForWeek(weekKey, weekday: day)) {
          completedCount++;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Program',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  totalTasks == 0
                      ? 'Ders veya konu sürükleyip günlere bırak'
                      : '$completedCount / $totalTasks görev tamamlandı',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (weekBlocks.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _paletteOpen = !_paletteOpen),
              style: TextButton.styleFrom(
                backgroundColor: showPalette
                    ? colors.primary.withValues(alpha: 0.14)
                    : colors.subtleFill,
                foregroundColor:
                    showPalette ? colors.primary : colors.textPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                showPalette ? Icons.check_rounded : Icons.drag_indicator_rounded,
                size: 16,
              ),
              label: Text(
                showPalette ? 'Bitti' : 'Sürükle',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          IconButton(
            tooltip: _overviewMode ? 'Gün Görünümü' : '7 Gün Genel Bakış',
            onPressed: () => setState(() => _overviewMode = !_overviewMode),
            icon: Icon(
              _overviewMode ? Icons.view_day_outlined : Icons.calendar_view_week,
              color: colors.primary,
            ),
          ),
          IconButton(
            tooltip: 'AI ile Haftalık Program Hazırla',
            onPressed: () => _openAiScheduleDialog(context, repository),
            icon: Icon(Icons.auto_awesome, color: colors.primary),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colors.textPrimary),
            color: colors.surface,
            onSelected: (action) async {
              if (action == 'reset_checks') {
                await repository.resetWeeklyCompletion(weekKey: weekKey);
                if (context.mounted) {
                  InAppNotice.show(
                    context,
                    'Bu haftanın tamamlama işaretleri sıfırlandı.',
                  );
                }
              } else if (action == 'clear_all') {
                await _confirmClearSchedule(context, repository);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_checks',
                child: Text('Bu Haftanın Tiklerini Sıfırla'),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Text(
                  'Tüm Programı Temizle',
                  style: TextStyle(color: colors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigator(BuildContext context) {
    final colors = AppColors.of(context);
    final sunday = _selectedWeekMonday.add(const Duration(days: 6));
    final rangeLabel =
        '${_selectedWeekMonday.day} ${_shortMonths[_selectedWeekMonday.month - 1]} – '
        '${sunday.day} ${_shortMonths[sunday.month - 1]}';
    final offset = _weekOffsetFromCurrent;
    final offsetLabel = offset == 0
        ? 'Bu Hafta'
        : offset == 1
            ? 'Gelecek Hafta'
            : offset > 1
                ? '+$offset Hafta Sonra'
                : offset == -1
                    ? 'Geçen Hafta'
                    : '${offset.abs()} Hafta Önce';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Önceki Hafta',
              visualDensity: VisualDensity.compact,
              onPressed: () => _shiftWeek(-1),
              icon: Icon(Icons.chevron_left, color: AppColors.of(context).textSecondary),
            ),
            Expanded(
              child: GestureDetector(
                onTap: offset != 0 ? _jumpToCurrentWeek : null,
                child: Column(
                  children: [
                    Text(
                      rangeLabel,
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      offset == 0 ? offsetLabel : '$offsetLabel • Bugüne dön',
                      style: TextStyle(
                        color: offset == 0
                            ? colors.primaryLight
                            : colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Sonraki Hafta',
              visualDensity: VisualDensity.compact,
              onPressed: () => _shiftWeek(1),
              icon: Icon(Icons.chevron_right, color: AppColors.of(context).textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTabs(
    BuildContext context,
    AppRepository repository,
    List<StudyScheduleBlock> weekBlocks,
  ) {
    final colors = AppColors.of(context);
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(7, (index) {
          final weekday = index + 1;
          final dayDate = _selectedWeekMonday.add(Duration(days: index));
          final isSelected = !_overviewMode && _selectedWeekday == weekday;
          final isToday = dayDate.year == now.year &&
              dayDate.month == now.month &&
              dayDate.day == now.day;
          final dayCount = weekBlocks
              .where((b) => b.occursOnDay(_selectedWeekMonday, weekday))
              .length;

          return Expanded(
            child: DragTarget<_ScheduleDragPayload>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) =>
                  _handleDropOnDay(repository, details.data, weekday),
              builder: (context, candidateData, _) {
                final isHovering = candidateData.isNotEmpty;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedWeekday = weekday;
                    _overviewMode = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isHovering
                          ? colors.primary.withValues(alpha: 0.35)
                          : isSelected
                              ? colors.primary
                              : colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isHovering
                            ? colors.primaryLight
                            : isToday && !isSelected
                                ? colors.primary.withValues(alpha: 0.65)
                                : AppColors.of(context).subtleFill,
                        width: isHovering ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _shortWeekdays[index],
                          style: TextStyle(
                            color: isSelected
                                ? colors.onPrimary
                                : AppColors.of(context).textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dayDate.day}',
                          style: TextStyle(
                            color: isSelected
                                ? colors.onPrimary.withValues(alpha: 0.85)
                                : AppColors.of(context).textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.onPrimary.withValues(alpha: 0.16)
                                : dayCount > 0
                                    ? colors.primary.withValues(alpha: 0.2)
                                    : AppColors.of(context).subtleFill,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$dayCount',
                            style: TextStyle(
                              color: isSelected
                                  ? colors.onPrimary
                                  : dayCount > 0
                                      ? colors.primaryLight
                                      : AppColors.of(context).textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPaletteSection(
    BuildContext context,
    AppRepository repository,
    List<({String subject, String tag})> paletteSubjects,
    List<TopicSummary> allTopics,
  ) {
    final colors = AppColors.of(context);

    if (paletteSubjects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CurriculumHubScreen()),
          ),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            radius: BorderRadius.circular(14),
            child: Row(
              children: [
                Icon(Icons.library_add, color: colors.primaryLight, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Henüz dersin yok. Müfredat Merkezinden ders ekle.',
                    style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.of(context).textMuted, size: 18),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _isDragging
                      ? 'Günün üstüne veya listeye bırak'
                      : _topicPaletteMode
                          ? 'Konu Paleti (Tut & sürükle veya dokun)'
                          : 'Ders Paleti (Tut & sürükle veya dokun)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _isDragging ? colors.primaryLight : AppColors.of(context).textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.of(context).border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniModePill(
                      label: 'Ders',
                      active: !_topicPaletteMode,
                      onTap: () => setState(() => _topicPaletteMode = false),
                    ),
                    _MiniModePill(
                      label: 'Konu',
                      active: _topicPaletteMode,
                      onTap: () => setState(() => _topicPaletteMode = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: _topicPaletteMode
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: allTopics.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final topic = allTopics[index];
                    final payload = _NewCourseDrag(
                      subject: topic.subject,
                      tag: topic.tag,
                      topic: topic.title,
                    );
                    final chip = _PaletteChip(
                      label: '${topic.subject} • ${topic.title}',
                    );
                    return LongPressDraggable<_ScheduleDragPayload>(
                      data: payload,
                      delay: const Duration(milliseconds: 160),
                      onDragStarted: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isDragging = true);
                      },
                      onDragEnd: (_) {
                        if (mounted) setState(() => _isDragging = false);
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: _PaletteChip(
                          label: '${topic.subject} • ${topic.title}',
                          elevated: true,
                        ),
                      ),
                      childWhenDragging: Opacity(opacity: 0.35, child: chip),
                      child: GestureDetector(
                        onTap: () => _openBlockEditor(
                          context,
                          repository,
                          weekday: _selectedWeekday,
                          initialSubject: topic.subject,
                          initialTopic: topic.title,
                          initialTag: topic.tag,
                        ),
                        child: chip,
                      ),
                    );
                  },
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: paletteSubjects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = paletteSubjects[index];
                    final payload = _NewCourseDrag(
                      subject: item.subject,
                      tag: item.tag,
                    );
                    final chip = _PaletteChip(label: item.subject);

                    return LongPressDraggable<_ScheduleDragPayload>(
                      data: payload,
                      delay: const Duration(milliseconds: 160),
                      onDragStarted: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isDragging = true);
                      },
                      onDragEnd: (_) {
                        if (mounted) setState(() => _isDragging = false);
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: _PaletteChip(
                          label: item.subject,
                          elevated: true,
                        ),
                      ),
                      childWhenDragging: Opacity(opacity: 0.35, child: chip),
                      child: GestureDetector(
                        onTap: () => _openBlockEditor(
                          context,
                          repository,
                          weekday: _selectedWeekday,
                          initialSubject: item.subject,
                          initialTag: item.tag,
                        ),
                        child: chip,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDayDetail(
    BuildContext context,
    AppRepository repository,
    List<TopicSummary> allTopics,
  ) {
    final colors = AppColors.of(context);
    final weekKey = _selectedWeekKey;
    final dayBlocks = repository.scheduleForDay(
      _selectedWeekday,
      weekMonday: _selectedWeekMonday,
    );
    final dayDate =
        _selectedWeekMonday.add(Duration(days: _selectedWeekday - 1));
    final totalMinutes =
        dayBlocks.fold<int>(0, (sum, b) => sum + b.durationMinutes);
    final totalQuestions =
        dayBlocks.fold<int>(0, (sum, b) => sum + b.targetQuestions);

    return DragTarget<_ScheduleDragPayload>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) =>
          _handleDropOnDay(repository, details.data, _selectedWeekday),
      builder: (context, candidateData, _) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isHovering ? colors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
                child: Row(
                  children: [
                    Text(
                      '${_fullWeekdays[_selectedWeekday - 1]}, ${dayDate.day} ${_shortMonths[dayDate.month - 1]}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${dayBlocks.length} görev • $totalMinutes dk • $totalQuestions s.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: dayBlocks.isEmpty
                    ? _buildEmptyDayDropZone(context, isHovering)
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        buildDefaultDragHandles: false,
                        itemCount: dayBlocks.length,
                        onReorder: (oldIndex, newIndex) {
                          HapticFeedback.selectionClick();
                          repository.reorderScheduleDay(
                            _selectedWeekday,
                            oldIndex,
                            newIndex,
                            weekMonday: _selectedWeekMonday,
                          );
                        },
                        itemBuilder: (context, index) {
                          final block = dayBlocks[index];
                          final completed = block.isCompletedForWeek(
                            weekKey,
                            weekday: _selectedWeekday,
                          );
                          return Padding(
                            key: ValueKey(block.id),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: LongPressDraggable<_ScheduleDragPayload>(
                              data: _MoveBlockDrag(block),
                              delay: const Duration(milliseconds: 220),
                              onDragStarted: () {
                                HapticFeedback.mediumImpact();
                                setState(() => _isDragging = true);
                              },
                              onDragEnd: (_) {
                                if (mounted) setState(() => _isDragging = false);
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 48,
                                  child: _ScheduleBlockCard(
                                    block: block,
                                    completed: completed,
                                    index: index,
                                    isFeedback: true,
                                    onToggleComplete: () {},
                                    onEdit: () {},
                                    onLogStudy: () {},
                                    onOpenVideo: () {},
                                    onOpenImages: () {},
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _ScheduleBlockCard(
                                  block: block,
                                  completed: completed,
                                  index: index,
                                  onToggleComplete: () {},
                                  onEdit: () {},
                                  onLogStudy: () {},
                                  onOpenVideo: () {},
                                  onOpenImages: () {},
                                ),
                              ),
                              child: _ScheduleBlockCard(
                                block: block,
                                completed: completed,
                                index: index,
                                onToggleComplete: () =>
                                    repository.toggleScheduleBlockCompleted(
                                  block.id,
                                  weekKey: weekKey,
                                  weekday: _selectedWeekday,
                                ),
                                onEdit: () => _openBlockEditor(
                                  context,
                                  repository,
                                  weekday: block.weekday,
                                  existing: block,
                                ),
                                onLogStudy: () => _openEntryForBlock(
                                  context,
                                  block,
                                  allTopics,
                                ),
                                onCopy: () => showCopyScheduleBlockSheet(
                                  context,
                                  repository,
                                  source: block,
                                  currentWeekMonday: _selectedWeekMonday,
                                ),
                                onOpenVideo: () =>
                                    openScheduleVideoUrl(context, block.videoUrl),
                                onOpenImages: () => openScheduleImageGallery(
                                  context,
                                  block.imagePaths,
                                  block.subject,
                                ),
                                onDelete: () =>
                                    deleteScheduleBlockWithUndo(context, block),
                              ),
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
  }

  Widget _buildEmptyDayDropZone(BuildContext context, bool isHovering) {
    final colors = AppColors.of(context);
    return Center(
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        radius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHovering ? Icons.download_done : Icons.drag_indicator,
              size: 42,
              color: isHovering ? colors.primary : AppColors.of(context).textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isHovering
                  ? '${_fullWeekdays[_selectedWeekday - 1]} gününe bırak!'
                  : '${_fullWeekdays[_selectedWeekday - 1]} için plan yok',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.of(context).textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Yukarıdaki Ders/Konu paletinden sürükle-bırak yap, video/fotoğraflı periyodik görev ekle ya da AI ile doldur.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyOverview(
    BuildContext context,
    AppRepository repository,
    List<TopicSummary> allTopics,
  ) {
    final colors = AppColors.of(context);
    final weekKey = _selectedWeekKey;
    final now = DateTime.now();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: 7,
      itemBuilder: (context, index) {
        final weekday = index + 1;
        final dayDate = _selectedWeekMonday.add(Duration(days: index));
        final dayBlocks = repository.scheduleForDay(
          weekday,
          weekMonday: _selectedWeekMonday,
        );
        final isToday = dayDate.year == now.year &&
            dayDate.month == now.month &&
            dayDate.day == now.day;

        return DragTarget<_ScheduleDragPayload>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) =>
              _handleDropOnDay(repository, details.data, weekday),
          builder: (context, candidateData, _) {
            final isHovering = candidateData.isNotEmpty;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isHovering
                    ? colors.primary.withValues(alpha: 0.16)
                    : colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isHovering
                      ? colors.primary
                      : isToday
                          ? colors.primary.withValues(alpha: 0.45)
                          : AppColors.of(context).subtleFill,
                  width: isHovering ? 1.8 : 1,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedWeekday = weekday;
                          _overviewMode = false;
                        }),
                        child: Text(
                          '${_fullWeekdays[index]} • ${dayDate.day} ${_shortMonths[dayDate.month - 1]}',
                          style: TextStyle(
                            color: isToday ? colors.primaryLight : AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Bugün',
                            style: TextStyle(
                              color: colors.primaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _openBlockEditor(
                          context,
                          repository,
                          weekday: weekday,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.add, color: AppColors.of(context).textSecondary, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dayBlocks.isEmpty)
                    Text(
                      isHovering ? 'Buraya bırak…' : 'Boş gün — ders veya konu sürükle',
                      style: TextStyle(
                        color: isHovering ? colors.primaryLight : AppColors.of(context).textMuted,
                        fontSize: 12,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dayBlocks.map((block) {
                        final completed = block.isCompletedForWeek(
                          weekKey,
                          weekday: weekday,
                        );
                        final pill = _OverviewBlockChip(
                          block: block,
                          completed: completed,
                          onTap: () => _openBlockEditor(
                            context,
                            repository,
                            weekday: block.weekday,
                            existing: block,
                          ),
                        );
                        return LongPressDraggable<_ScheduleDragPayload>(
                          data: _MoveBlockDrag(block),
                          delay: const Duration(milliseconds: 180),
                          onDragStarted: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isDragging = true);
                          },
                          onDragEnd: (_) {
                            if (mounted) setState(() => _isDragging = false);
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            child: _OverviewBlockChip(
                              block: block,
                              completed: completed,
                              elevated: true,
                              onTap: () {},
                            ),
                          ),
                          childWhenDragging: Opacity(opacity: 0.35, child: pill),
                          child: pill,
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDropOnDay(
    AppRepository repository,
    _ScheduleDragPayload payload,
    int targetWeekday,
  ) async {
    HapticFeedback.mediumImpact();
    switch (payload) {
      case _NewCourseDrag(:final subject, :final tag, :final topic):
        final newBlock = StudyScheduleBlock(
          id: 'blk-${DateTime.now().microsecondsSinceEpoch}',
          weekday: targetWeekday,
          subject: subject,
          topic: topic,
          tag: tag,
          durationMinutes: 45,
          targetQuestions: 30,
          recurrence: ScheduleRecurrence.weekly,
          startWeekKey: _selectedWeekKey,
        );
        await repository.addScheduleBlock(newBlock);
        await _syncWeeklyNotification(repository);
        if (mounted) {
          final label = topic.isNotEmpty ? '$subject ($topic)' : subject;
          InAppNotice.show(
            context,
            '$label → ${_fullWeekdays[targetWeekday - 1]} gününe eklendi.',
          );
        }
      case _MoveBlockDrag(:final block):
        if (block.weekday == targetWeekday) return;
        await repository.moveScheduleBlock(block.id, targetWeekday);
        await _syncWeeklyNotification(repository);
        if (mounted) {
          InAppNotice.show(
            context,
            '${block.subject} → ${_fullWeekdays[targetWeekday - 1]} gününe taşındı.',
          );
        }
    }
  }

  Future<void> _syncWeeklyNotification(AppRepository repository) =>
      syncWeeklyScheduleNotification(repository);

  void _openEntryForBlock(
    BuildContext context,
    StudyScheduleBlock block,
    List<TopicSummary> allTopics,
  ) {
    TopicSummary? matched;
    if (block.topic.isNotEmpty) {
      for (final t in allTopics) {
        if (t.subject == block.subject && t.title == block.topic) {
          matched = t;
          break;
        }
      }
    }
    matched ??= allTopics
        .where((t) => t.subject == block.subject)
        .cast<TopicSummary?>()
        .firstWhere((t) => t != null, orElse: () => null);

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => EntryWizardScreen(
          type: EntryType.question,
          preselectedTopic: matched,
          initialData: {'minutes': block.durationMinutes},
        ),
      ),
    );
  }

  Future<void> _openBlockEditor(
    BuildContext context,
    AppRepository repository, {
    required int weekday,
    StudyScheduleBlock? existing,
    String? initialSubject,
    String? initialTopic,
    String? initialTag,
  }) async {
    final savedDay = await showScheduleBlockEditorSheet(
      context,
      repository,
      weekday: weekday,
      weekMonday: _selectedWeekMonday,
      existing: existing,
      initialSubject: initialSubject,
      initialTopic: initialTopic,
      initialTag: initialTag,
    );
    if (savedDay != null && mounted) {
      setState(() => _selectedWeekday = savedDay);
    }
  }

  Future<void> _openAiScheduleDialog(
    BuildContext context,
    AppRepository repository,
  ) async {
    final apiKey = repository.geminiApiKey.value;
    if (apiKey.isEmpty) {
      InAppNotice.show(
          context, 'Gemini API anahtarını Profil sekmesinden ekle.');
      return;
    }

    final noteController = TextEditingController();
    final preference = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('AI ile Haftalık Program'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mevcut derslerin ve zayıf konuların analiz edilip 7 günlük periyodik konu bazlı program oluşturulur.',
              style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Örn: Hafta içi akşam 2 saat, Cumartesi konu denemesi, Pazar tekrar olsun.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(
              noteController.text.trim().isEmpty
                  ? 'Dengeli ve konu bazlı haftalık çalışma programı oluştur.'
                  : noteController.text.trim(),
            ),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Oluştur'),
          ),
        ],
      ),
    );
    noteController.dispose();

    if (preference == null || !context.mounted) return;

    var loadingOpen = true;
    AiLoadingDialog.show(context, status: 'AI haftalık program hazırlıyor...')
        .then((_) => loadingOpen = false);

    void closeLoading() {
      if (loadingOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingOpen = false;
      }
    }

    try {
      final subjects = repository.subjectsForTag(null);
      final weak = repository.weakestTopics(limit: 5);
      final model = repository.geminiModel.value.isEmpty
          ? 'gemini-1.5-flash-latest'
          : repository.geminiModel.value;

      final prompt = '''
Kullanıcı için 7 günlük gerçekçi, konu bazlı ve periyodik haftalık çalışma programı oluştur.
Aktif dersler: ${subjects.isEmpty ? 'Genel Çalışma' : subjects.join(', ')}
Zayıf konular: ${weak.isEmpty ? 'Yok' : weak.map((w) => '${w.topic.subject}: ${w.topic.title}').join(', ')}
Günlük soru hedefi: ${repository.dailyGoal.value}
Kullanıcı tercihi: "$preference"

SADECE ham JSON dizisi döndür (açıklama veya markdown olmadan).
Şema:
[
  {
    "weekday": 1,
    "subject": "Ders adı",
    "topic": "Konu adı",
    "tag": "Genel",
    "startTime": "19:00",
    "durationMinutes": 45,
    "targetQuestions": 30,
    "recurrence": "weekly",
    "note": "Kısa ipucu"
  }
]
weekday 1=Pazartesi .. 7=Pazar. recurrence: "weekly", "biweekly" veya "once". Toplam 10 ile 18 arası blok üret.
''';

      final raw = await GeminiClient().generateText(
        apiKey: apiKey,
        prompt: prompt,
        model: model,
      );
      await repository.incrementAiRequestCount();
      closeLoading();

      final match = RegExp(r'\[[\s\S]*\]').firstMatch(raw);
      if (match == null) throw const FormatException('JSON dizisi bulunamadı');
      final decoded = jsonDecode(match.group(0)!) as List<dynamic>;
      final now = DateTime.now().microsecondsSinceEpoch;
      final generated = <StudyScheduleBlock>[];
      for (var i = 0; i < decoded.length; i++) {
        final item = decoded[i];
        if (item is! Map) continue;
        final subject = (item['subject'] as String? ?? '').trim();
        if (subject.isEmpty) continue;
        generated.add(
          StudyScheduleBlock(
            id: 'ai-blk-$now-$i',
            weekday: ((item['weekday'] as num?)?.toInt() ?? 1).clamp(1, 7),
            subject: subject,
            topic: (item['topic'] as String? ?? '').trim(),
            tag: (item['tag'] as String? ?? 'Genel').trim(),
            startTime: (item['startTime'] as String? ?? '').trim(),
            durationMinutes:
                ((item['durationMinutes'] as num?)?.toInt() ?? 45)
                    .clamp(10, 300),
            targetQuestions:
                ((item['targetQuestions'] as num?)?.toInt() ?? 25)
                    .clamp(0, 500),
            note: (item['note'] as String? ?? '').trim(),
            recurrence: ScheduleRecurrence.fromString(
              item['recurrence'] as String?,
            ),
            startWeekKey: _selectedWeekKey,
          ),
        );
      }

      if (generated.isEmpty) {
        if (mounted) {
          InAppNotice.show(
              context, 'AI geçerli program üretemedi, tekrar dene.');
        }
        return;
      }

      await repository.replaceWeeklySchedule(generated);
      await _syncWeeklyNotification(repository);
      if (mounted) {
        InAppNotice.show(
          context,
          '${generated.length} görevlik haftalık program takvime yerleştirildi.',
        );
      }
    } catch (e) {
      debugPrint('WeeklyScheduleScreen: AI schedule failed: $e');
      closeLoading();
      if (mounted) {
        InAppNotice.show(context, 'AI program oluşturulamadı.');
      }
    }
  }

  Future<void> _confirmClearSchedule(
    BuildContext context,
    AppRepository repository,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Programı Temizle'),
        content: const Text(
          'Haftalık programdaki tüm görevler silinecek. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repository.replaceWeeklySchedule(const []);
      if (mounted) InAppNotice.show(context, 'Haftalık program temizlendi.');
    }
  }

  List<({String subject, String tag})> _extractSubjectPalette(
    List<TopicSummary> topics,
  ) {
    final seen = <String>{};
    final result = <({String subject, String tag})>[];
    for (final t in topics) {
      final key = t.subject.trim().toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      result.add((subject: t.subject.trim(), tag: t.tag.trim()));
    }
    result.sort((a, b) => a.subject.compareTo(b.subject));
    return result;
  }
}

class _MiniModePill extends StatelessWidget {
  const _MiniModePill({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? colors.onPrimary : AppColors.of(context).textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PaletteChip extends StatelessWidget {
  const _PaletteChip({
    required this.label,
    this.elevated = false,
  });

  final String label;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: elevated ? colors.primary : colors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: elevated
              ? colors.primaryLight
              : AppColors.of(context).subtleFill,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator,
            size: 14,
            color: elevated ? colors.onPrimary : colors.primaryLight,
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: elevated ? colors.onPrimary : AppColors.of(context).textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleBlockCard extends StatelessWidget {
  const _ScheduleBlockCard({
    required this.block,
    required this.completed,
    required this.index,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onLogStudy,
    required this.onOpenVideo,
    required this.onOpenImages,
    this.onCopy,
    this.onDelete,
    this.isFeedback = false,
  });

  final StudyScheduleBlock block;
  final bool completed;
  final int index;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onLogStudy;
  final VoidCallback onOpenVideo;
  final VoidCallback onOpenImages;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final bool isFeedback;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final subjectStyle = SubjectColors.of(
      block.subject,
      isDark: colors.isDark,
    );
    final accent = completed ? colors.success : subjectStyle.accent;
    final hasVideo = block.videoUrl.trim().isNotEmpty;
    final hasImages = block.imagePaths.isNotEmpty;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        decoration: BoxDecoration(
          color: isFeedback ? colors.surfaceLight : colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFeedback
                ? colors.primary
                : completed
                    ? colors.success.withValues(alpha: 0.35)
                    : colors.border,
          ),
          boxShadow: colors.isDark
              ? const []
              : [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isFeedback)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: colors.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: completed ? colors.success : colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: completed ? colors.success : subjectStyle.accent,
                        width: 1.8,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check_rounded,
                            size: 15, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (block.startTime.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: subjectStyle.tint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                block.startTime,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              block.topic.isNotEmpty
                                  ? '${block.subject} • ${block.topic}'
                                  : block.subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: completed
                                    ? colors.textMuted
                                    : colors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${block.durationMinutes} dk'
                        '${block.targetQuestions > 0 ? ' • ${block.targetQuestions} soru' : ''}'
                        ' • ${block.recurrence.label}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isFeedback) ...[
                  IconButton(
                    tooltip: 'Soru Kaydı Ekle',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    padding: const EdgeInsets.all(4),
                    onPressed: onLogStudy,
                    icon: Icon(
                      Icons.add_task_rounded,
                      color: colors.primary,
                      size: 19,
                    ),
                  ),
                  if (onCopy != null)
                    IconButton(
                      tooltip: 'Görevi Kopyala',
                      visualDensity: VisualDensity.compact,
                      constraints:
                          const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: const EdgeInsets.all(4),
                      onPressed: onCopy,
                      icon: Icon(
                        Icons.copy_rounded,
                        color: colors.textSecondary,
                        size: 18,
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Görevi Sil',
                      visualDensity: VisualDensity.compact,
                      constraints:
                          const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: const EdgeInsets.all(4),
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.textMuted,
                        size: 19,
                      ),
                    ),
                ],
              ],
            ),
            if ((hasVideo || hasImages) && !isFeedback) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (hasVideo)
                      InkWell(
                        onTap: onOpenVideo,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.danger.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill_rounded,
                                  size: 14, color: colors.danger),
                              const SizedBox(width: 5),
                              Text(
                                'Ders Videosunu Aç',
                                style: TextStyle(
                                  color: colors.danger,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasImages)
                      InkWell(
                        onTap: onOpenImages,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_library_outlined,
                                  size: 14, color: colors.primary),
                              const SizedBox(width: 5),
                              Text(
                                '${block.imagePaths.length} Fotoğraf',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverviewBlockChip extends StatelessWidget {
  const _OverviewBlockChip({
    required this.block,
    required this.completed,
    required this.onTap,
    this.elevated = false,
  });

  final StudyScheduleBlock block;
  final bool completed;
  final VoidCallback onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: elevated
              ? colors.primary
              : completed
                  ? colors.success.withValues(alpha: 0.16)
                  : colors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: completed
                ? colors.success.withValues(alpha: 0.4)
                : AppColors.of(context).subtleFill,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (block.startTime.isNotEmpty)
              Text(
                '${block.startTime} ',
                style: TextStyle(
                  color: elevated ? colors.onPrimary : colors.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                block.topic.isNotEmpty
                    ? '${block.subject} • ${block.topic}'
                    : block.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: elevated
                      ? colors.onPrimary
                      : completed
                          ? colors.success
                          : AppColors.of(context).textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (block.videoUrl.isNotEmpty) ...[
              const SizedBox(width: 4),
              const Icon(Icons.play_circle_outline,
                  size: 13, color: Colors.redAccent),
            ],
            if (block.imagePaths.isNotEmpty) ...[
              const SizedBox(width: 4),
              Icon(Icons.photo_outlined, size: 13, color: colors.primaryLight),
            ],
          ],
        ),
      ),
    );
  }
}
