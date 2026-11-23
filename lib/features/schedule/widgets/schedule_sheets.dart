import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/study_schedule_block.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/delete_helpers.dart';
import '../../../core/widgets/in_app_notice.dart';

const List<String> scheduleShortWeekdays = [
  'Pzt',
  'Sal',
  'Çar',
  'Per',
  'Cum',
  'Cmt',
  'Paz',
];

const List<String> scheduleFullWeekdays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

Future<void> syncWeeklyScheduleNotification(AppRepository repository) async {
  if (!repository.weeklyPlanEnabled.value) return;
  await NotificationService.scheduleWeeklyPlanWithBody(
    time: repository.weeklyPlanTime.value,
    weekday: repository.weeklyPlanWeekday.value,
    body: repository.buildWeeklyScheduleSummary(),
  );
}

Future<void> openScheduleVideoUrl(BuildContext context, String rawUrl) async {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return;
  final normalized =
      trimmed.startsWith('http://') || trimmed.startsWith('https://')
          ? trimmed
          : 'https://$trimmed';
  final uri = Uri.tryParse(normalized);
  if (uri == null) {
    InAppNotice.show(context, 'Geçersiz video bağlantısı.');
    return;
  }
  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      InAppNotice.show(context, 'Video bağlantısı açılamadı.');
    }
  } catch (e) {
    debugPrint('ScheduleSheets: Video launch failed: $e');
    if (context.mounted) {
      InAppNotice.show(context, 'Video bağlantısı açılamadı.');
    }
  }
}

void openScheduleImageGallery(
  BuildContext context,
  List<String> imagePaths,
  String title,
) {
  if (imagePaths.isEmpty) return;
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => SchedulePhotoViewerScreen(
        title: title,
        imagePaths: imagePaths,
      ),
    ),
  );
}

Future<String?> pickAndSaveSchedulePhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final colors = AppColors.of(sheetContext);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: colors.textPrimary),
              title: Text(
                'Kameradan Çek',
                style: TextStyle(color: colors.textPrimary),
              ),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading:
                  Icon(Icons.photo_library_outlined, color: colors.textPrimary),
              title: Text(
                'Galeriden Seç',
                style: TextStyle(color: colors.textPrimary),
              ),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );
  if (source == null) return null;
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final name = 'schedule_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${dir.path}/$name');
    return saved.path;
  } catch (e) {
    debugPrint('ScheduleSheets: Photo pick failed: $e');
    if (context.mounted) {
      InAppNotice.show(context, 'Fotoğraf eklenemedi.');
    }
    return null;
  }
}

Future<int> showCopyScheduleBlockSheet(
  BuildContext context,
  AppRepository repository, {
  required StudyScheduleBlock source,
  required DateTime currentWeekMonday,
}) async {
  final normalizedCurrent = StudyScheduleBlock.mondayOf(currentWeekMonday);
  final nextWeekMonday = normalizedCurrent.add(const Duration(days: 7));
  final currentWeekKey = StudyScheduleBlock.weekKeyFor(normalizedCurrent);
  final nextWeekKey = StudyScheduleBlock.weekKeyFor(nextWeekMonday);

  var copyToNextWeek = false;
  final selectedDays = <int>{};

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final colors = AppColors.of(context);
          final targetMonday =
              copyToNextWeek ? nextWeekMonday : normalizedCurrent;
          final existingDaysInTarget = {
            for (var d = DateTime.monday; d <= DateTime.sunday; d++)
              if (source.occursOnDay(targetMonday, d)) d,
          };

          void selectAllTargetDays() {
            final otherDays = {
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                if (!existingDaysInTarget.contains(d)) d,
            };
            setModalState(() {
              selectedDays
                ..clear()
                ..addAll(
                  otherDays.isNotEmpty
                      ? otherDays
                      : const {1, 2, 3, 4, 5, 6, 7},
                );
            });
          }

          void selectWeekdaysOnly() {
            final weekdays = {
              for (var d = DateTime.monday; d <= DateTime.friday; d++)
                if (!existingDaysInTarget.contains(d)) d,
            };
            setModalState(() {
              selectedDays
                ..clear()
                ..addAll(
                  weekdays.isNotEmpty ? weekdays : const {1, 2, 3, 4, 5},
                );
            });
          }

          final label = source.topic.isNotEmpty
              ? '${source.subject} • ${source.topic}'
              : source.subject;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.textMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Görevi Kopyala',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Bu Hafta')),
                          selected: !copyToNextWeek,
                          onSelected: (_) => setModalState(() {
                            copyToNextWeek = false;
                            selectedDays.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Gelecek Hafta')),
                          selected: copyToNextWeek,
                          onSelected: (_) => setModalState(() {
                            copyToNextWeek = true;
                            selectedDays.clear();
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Hedef Günler',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: selectAllTargetDays,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Tüm Günler'),
                      ),
                      TextButton(
                        onPressed: selectWeekdaysOnly,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Hafta İçi'),
                      ),
                      if (selectedDays.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              setModalState(selectedDays.clear),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: colors.danger,
                          ),
                          child: const Text('Temizle'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = selectedDays.contains(day);
                      final alreadyExists = existingDaysInTarget.contains(day);
                      return FilterChip(
                        label: Text(
                          alreadyExists
                              ? '${scheduleShortWeekdays[index]} •'
                              : scheduleShortWeekdays[index],
                        ),
                        selected: isSelected,
                        onSelected: (checked) {
                          setModalState(() {
                            if (checked) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  if (existingDaysInTarget.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Noktalı günler bu görevin zaten bulunduğu günlerdir.',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selectedDays.isEmpty
                          ? null
                          : () => Navigator.of(sheetContext).pop(true),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(
                        selectedDays.isEmpty
                            ? 'Kopyalanacak Gün Seç'
                            : '${selectedDays.length} Güne Kopyala',
                      ),
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

  if (confirmed != true || selectedDays.isEmpty) return 0;

  final targetWeekKey = copyToNextWeek ? nextWeekKey : currentWeekKey;
  final copiedCount = await repository.copyScheduleBlockToDays(
    source,
    targetWeekdays: selectedDays,
    targetWeekKey: targetWeekKey,
  );
  await syncWeeklyScheduleNotification(repository);

  if (context.mounted && copiedCount > 0) {
    final label = source.topic.isNotEmpty
        ? '${source.subject} (${source.topic})'
        : source.subject;
    InAppNotice.show(
      context,
      '$label → $copiedCount güne kopyalandı.',
    );
  }
  return copiedCount;
}

Future<int?> showScheduleBlockEditorSheet(
  BuildContext context,
  AppRepository repository, {
  required int weekday,
  required DateTime weekMonday,
  StudyScheduleBlock? existing,
  String? initialSubject,
  String? initialTopic,
  String? initialTag,
}) async {
  final outcome =
      await showModalBottomSheet<({int? savedDay, bool openCopy})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _ScheduleBlockEditorSheet(
      repository: repository,
      weekday: weekday,
      weekMonday: weekMonday,
      existing: existing,
      initialSubject: initialSubject,
      initialTopic: initialTopic,
      initialTag: initialTag,
    ),
  );

  if (outcome?.openCopy == true && existing != null && context.mounted) {
    await showCopyScheduleBlockSheet(
      context,
      repository,
      source: existing,
      currentWeekMonday: weekMonday,
    );
  }

  return outcome?.savedDay;
}

class _ScheduleBlockEditorSheet extends StatefulWidget {
  const _ScheduleBlockEditorSheet({
    required this.repository,
    required this.weekday,
    required this.weekMonday,
    this.existing,
    this.initialSubject,
    this.initialTopic,
    this.initialTag,
  });

  final AppRepository repository;
  final int weekday;
  final DateTime weekMonday;
  final StudyScheduleBlock? existing;
  final String? initialSubject;
  final String? initialTopic;
  final String? initialTag;

  @override
  State<_ScheduleBlockEditorSheet> createState() =>
      _ScheduleBlockEditorSheetState();
}

class _ScheduleBlockEditorSheetState extends State<_ScheduleBlockEditorSheet> {
  late final List<TopicSummary> _allTopics;
  late final List<String> _subjects;
  late final String _resolvedWeekKey;

  late int _selectedDay;
  late ScheduleRecurrence _selectedRecurrence;
  late final List<String> _attachedImages;

  late final TextEditingController _subjectCtrl;
  late final TextEditingController _topicCtrl;
  late final TextEditingController _tagCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _questionsCtrl;
  late final TextEditingController _videoCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _allTopics = widget.repository.userTopics.value;
    _subjects = _allTopics.map((e) => e.subject).toSet().toList()..sort();
    _resolvedWeekKey = StudyScheduleBlock.weekKeyFor(widget.weekMonday);

    final existing = widget.existing;
    _selectedDay = existing?.weekday ?? widget.weekday;
    _selectedRecurrence = existing?.recurrence ?? ScheduleRecurrence.weekly;
    _attachedImages = List<String>.from(existing?.imagePaths ?? const []);

    _subjectCtrl = TextEditingController(
      text: existing?.subject ??
          widget.initialSubject ??
          (_subjects.isNotEmpty ? _subjects.first : ''),
    );
    _topicCtrl = TextEditingController(
      text: existing?.topic ?? widget.initialTopic ?? '',
    );
    _tagCtrl = TextEditingController(
      text: existing?.tag ?? widget.initialTag ?? 'Genel',
    );
    _timeCtrl = TextEditingController(text: existing?.startTime ?? '');
    _durationCtrl = TextEditingController(
      text: (existing?.durationMinutes ?? 45).toString(),
    );
    _questionsCtrl = TextEditingController(
      text: (existing?.targetQuestions ?? 30).toString(),
    );
    _videoCtrl = TextEditingController(text: existing?.videoUrl ?? '');
    _noteCtrl = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _topicCtrl.dispose();
    _tagCtrl.dispose();
    _timeCtrl.dispose();
    _durationCtrl.dispose();
    _questionsCtrl.dispose();
    _videoCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final existing = widget.existing;
    final matchingTopics = _allTopics
        .where(
          (t) =>
              t.subject.toLowerCase() ==
              _subjectCtrl.text.trim().toLowerCase(),
        )
        .map((t) => t.title)
        .toSet()
        .toList();

    final previewDays = StudyScheduleBlock.weekdaysForRecurrence(
      _selectedDay,
      _selectedRecurrence,
    );
    final previewDayNames =
        previewDays.map((d) => scheduleShortWeekdays[d - 1]).join(', ');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              existing == null ? 'Çalışma Görevi Ekle' : 'Görevi Düzenle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            if (_selectedRecurrence.isWeekScopedMultiDay) ...[
              Text(
                'Başlangıç Günü',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(7, (i) {
                final day = i + 1;
                return ChoiceChip(
                  label: Text(scheduleShortWeekdays[i]),
                  selected: _selectedDay == day,
                  onSelected: (_) => setState(() => _selectedDay = day),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              'Tekrar / Periyot',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ScheduleRecurrence.values.map((rec) {
                return ChoiceChip(
                  label: Text(rec.label),
                  selected: _selectedRecurrence == rec,
                  onSelected: (_) =>
                      setState(() => _selectedRecurrence = rec),
                );
              }).toList(),
            ),
            if (_selectedRecurrence.isWeekScopedMultiDay) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(
                    alpha: colors.isDark ? 0.16 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Bu haftaya özel günler (${previewDays.length}): $previewDayNames',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _subjectCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Ders',
                hintText: 'Örn: Matematik, YDS, Fizik',
              ),
            ),
            if (_subjects.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, idx) {
                    final subj = _subjects[idx];
                    return ActionChip(
                      label: Text(
                        subj,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        final matchTopic = _allTopics.firstWhere(
                          (t) => t.subject == subj,
                          orElse: () => TopicSummary(
                            id: '',
                            subject: subj,
                            title: '',
                            nextReview: '',
                          ),
                        );
                        setState(() {
                          _subjectCtrl.text = subj;
                          _tagCtrl.text = matchTopic.tag;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _topicCtrl,
              decoration: const InputDecoration(
                labelText: 'Konu (Konu bazlı görev için)',
                hintText: 'Örn: Limit ve Süreklilik, Paragraf',
              ),
            ),
            if (matchingTopics.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: matchingTopics.take(14).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, idx) {
                    final title = matchingTopics[idx];
                    return ActionChip(
                      label: Text(
                        title,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () =>
                          setState(() => _topicCtrl.text = title),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Saat',
                      hintText: '09:00',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Süre (dk)',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _questionsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hedef Soru',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _videoCtrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Ders Videosu Linki (Opsiyonel)',
                hintText: 'https://youtube.com/watch?v=...',
                prefixIcon: const Icon(Icons.play_circle_outline),
                suffixIcon: _videoCtrl.text.trim().isNotEmpty
                    ? IconButton(
                        tooltip: 'Videoyu Aç',
                        icon: const Icon(Icons.open_in_new, size: 18),
                        onPressed: () =>
                            openScheduleVideoUrl(context, _videoCtrl.text),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ekli Fotoğraflar (Not / Soru / Kaynak)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    final path = await pickAndSaveSchedulePhoto(context);
                    if (path != null && mounted) {
                      setState(() => _attachedImages.add(path));
                    }
                  },
                  icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                  label: const Text('Fotoğraf Ekle'),
                ),
              ],
            ),
            if (_attachedImages.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final path = _attachedImages[idx];
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => openScheduleImageGallery(
                            context,
                            _attachedImages,
                            _subjectCtrl.text.trim().isEmpty
                                ? 'Ekli Fotoğraf'
                                : _subjectCtrl.text.trim(),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(path),
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 84,
                                height: 84,
                                color: colors.subtleFill,
                                child: Icon(
                                  Icons.broken_image,
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _attachedImages.removeAt(idx),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Not (Opsiyonel)',
                hintText: 'Örn: Süre tutarak çöz',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (existing != null) ...[
                  OutlinedButton(
                    onPressed: () async {
                      final deleted = await deleteScheduleBlockWithUndo(
                        context,
                        existing,
                      );
                      if (deleted && context.mounted) {
                        Navigator.of(context).pop(
                          (savedDay: null, openCopy: false),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      side: BorderSide(color: colors.danger),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Sil'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(
                      (savedDay: null, openCopy: true),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Kopyala'),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final subject = _subjectCtrl.text.trim();
                      if (subject.isEmpty) {
                        InAppNotice.show(context, 'Ders adı boş olamaz.');
                        return;
                      }
                      final reanchorWeek = existing == null ||
                          (_selectedRecurrence.isWeekScopedMultiDay &&
                              existing.recurrence != _selectedRecurrence) ||
                          existing.startWeekKey.isEmpty;
                      final block = StudyScheduleBlock(
                        id: existing?.id ??
                            'blk-${DateTime.now().microsecondsSinceEpoch}',
                        weekday: _selectedDay,
                        subject: subject,
                        topic: _topicCtrl.text.trim(),
                        tag: _tagCtrl.text.trim().isEmpty
                            ? 'Genel'
                            : _tagCtrl.text.trim(),
                        startTime: _timeCtrl.text.trim(),
                        durationMinutes:
                            (int.tryParse(_durationCtrl.text.trim()) ?? 45)
                                .clamp(5, 600),
                        targetQuestions:
                            (int.tryParse(_questionsCtrl.text.trim()) ?? 0)
                                .clamp(0, 1000),
                        isCompleted: existing?.isCompleted ?? false,
                        sortOrder: existing?.sortOrder ?? 0,
                        note: _noteCtrl.text.trim(),
                        recurrence: _selectedRecurrence,
                        startWeekKey: reanchorWeek
                            ? _resolvedWeekKey
                            : existing.startWeekKey,
                        completedWeeks: existing?.completedWeeks ?? const [],
                        videoUrl: _videoCtrl.text.trim(),
                        imagePaths: List<String>.from(_attachedImages),
                      );
                      if (existing == null) {
                        await widget.repository.addScheduleBlock(block);
                      } else {
                        await widget.repository.updateScheduleBlock(block);
                      }
                      await syncWeeklyScheduleNotification(widget.repository);
                      if (context.mounted) {
                        Navigator.of(context).pop(
                          (savedDay: _selectedDay, openCopy: false),
                        );
                      }
                    },
                    child: Text(existing == null ? 'Ekle' : 'Kaydet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulePhotoViewerScreen extends StatelessWidget {
  const SchedulePhotoViewerScreen({
    super.key,
    required this.title,
    required this.imagePaths,
  });

  final String title;
  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('$title (${imagePaths.length})'),
      ),
      body: PageView.builder(
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.file(
                File(imagePaths[index]),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white38,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Görsel bulunamadı',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
