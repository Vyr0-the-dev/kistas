import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/data/exam_presets.dart';
import '../../../core/models/exam_profile.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/gemini_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_loading_dialog.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/in_app_notice.dart';

class CurriculumHubScreen extends StatefulWidget {
  const CurriculumHubScreen({super.key, this.initialTab = 0});

  /// 0: Hazır Paketler, 1: Özel Ders, 2: AI Oluşturucu
  final int initialTab;

  @override
  State<CurriculumHubScreen> createState() => _CurriculumHubScreenState();
}

class _CurriculumHubScreenState extends State<CurriculumHubScreen> {
  late int _activeTab;
  String _presetCategory = 'Tümü';

  // Manual form controllers
  final TextEditingController _manualTagController = TextEditingController(text: 'Genel');
  final TextEditingController _manualSubjectController = TextEditingController();
  final TextEditingController _manualTopicsController = TextEditingController();
  int _manualImportance = 3;

  // AI builder state
  final TextEditingController _aiPromptController = TextEditingController();
  final TextEditingController _aiTagController = TextEditingController();
  List<_GeneratedTopicDraft> _aiDrafts = [];
  String _aiSuggestedTag = 'Özel';
  double _aiSuggestedPenalty = 0.0;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.clamp(0, 2);
  }

  @override
  void dispose() {
    _manualTagController.dispose();
    _manualSubjectController.dispose();
    _manualTopicsController.dispose();
    _aiPromptController.dispose();
    _aiTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: _buildTabBar(context),
              ),
              Expanded(
                child: ValueListenableBuilder<List<TopicSummary>>(
                  valueListenable: repository.userTopics,
                  builder: (context, existingTopics, _) {
                    return switch (_activeTab) {
                      0 => _buildPresetsTab(context, repository, existingTopics),
                      1 => _buildManualTab(context, repository, existingTopics),
                      _ => _buildAiTab(context, repository),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      radius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: AppColors.of(context).textSecondary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ders & Müfredat Merkezi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'İstediğin sınav paketlerini ve özel dersleri bir arada kullan',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colors = AppColors.of(context);
    const tabs = [
      (label: 'Hazır Paketler', icon: Icons.auto_stories_outlined),
      (label: 'Özel Ders', icon: Icons.edit_note),
      (label: 'AI Oluştur', icon: Icons.auto_awesome),
    ];

    return GlassPanel(
      padding: const EdgeInsets.all(6),
      radius: BorderRadius.circular(18),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = _activeTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: active ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index].icon,
                      size: 16,
                      color: active ? colors.onPrimary : AppColors.of(context).textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tabs[index].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: active ? colors.onPrimary : AppColors.of(context).textSecondary,
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
    );
  }

  // --- TAB 0: BUILT-IN EXAM PRESETS ---

  Widget _buildPresetsTab(
    BuildContext context,
    AppRepository repository,
    List<TopicSummary> existingTopics,
  ) {
    const categories = ['Tümü', 'Maarif', 'YKS', 'KPSS', 'Dil', 'Akademik'];
    final filtered = _presetCategory == 'Tümü'
        ? examCatalogPresets
        : examCatalogPresets
            .where((preset) => preset.category == _presetCategory)
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final active = cat == _presetCategory;
              return GestureDetector(
                onTap: () => setState(() => _presetCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.of(context).primary
                        : AppColors.of(context).surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active
                          ? Colors.transparent
                          : AppColors.of(context).subtleFill,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: active
                              ? AppColors.of(context).onPrimary
                              : AppColors.of(context).textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        ...filtered.map((preset) {
          final loadedCount = existingTopics
              .where((t) => t.tag.toLowerCase() == preset.name.toLowerCase())
              .length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PresetCard(
              preset: preset,
              loadedTopicCount: loadedCount,
              onImportAll: () async {
                final added = await repository.importExamPreset(preset);
                if (!context.mounted) return;
                InAppNotice.show(
                  context,
                  added > 0
                      ? '${preset.name}: $added konu eklendi.'
                      : '${preset.name} konuları zaten listenizde.',
                );
              },
              onPickSubjects: () => _openSubjectPickerSheet(
                context,
                repository,
                preset,
                existingTopics,
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _openSubjectPickerSheet(
    BuildContext context,
    AppRepository repository,
    ExamPreset preset,
    List<TopicSummary> existingTopics,
  ) async {
    final selected = preset.subjects.keys.toSet();
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          color: AppColors.of(context).textMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${preset.name} — Ders Seç',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yalnızca çalışmak istediğin dersleri seçip diğer planlarınla birleştirebilirsin.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.of(context).textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: preset.subjects.entries.map((entry) {
                          final isChecked = selected.contains(entry.key);
                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: AppColors.of(context).primary,
                            checkColor: AppColors.of(context).onPrimary,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                color: AppColors.of(context).textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${entry.value.length} konu',
                              style: TextStyle(
                                color: AppColors.of(context).textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selected.add(entry.key);
                                } else {
                                  selected.remove(entry.key);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () => Navigator.of(sheetContext).pop(selected),
                        child: Text('Seçili ${selected.length} Dersi Ekle'),
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

    if (result != null && result.isNotEmpty && context.mounted) {
      final added = await repository.importExamPreset(
        preset,
        selectedSubjects: result,
      );
      if (!context.mounted) return;
      InAppNotice.show(
        context,
        added > 0
            ? '${preset.name} içinden $added konu eklendi.'
            : 'Seçilen derslerin tüm konuları zaten yüklü.',
      );
    }
  }

  // --- TAB 1: MANUAL COURSE & TOPIC BUILDER + CSV ---

  Widget _buildManualTab(
    BuildContext context,
    AppRepository repository,
    List<TopicSummary> existingTopics,
  ) {
    final colors = AppColors.of(context);
    final existingTags = {
      'Genel',
      'Üniversite',
      'Kişisel',
      ...repository.availableTags,
    }.toList();
    final existingSubjects = existingTopics
        .map((e) => e.subject)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(18),
          radius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni Ders veya Konu Ekle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sınav / Kategori Etiketi',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _manualTagController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Üniversite, YKS, Almanca, Genel',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: existingTags.take(8).map((tag) {
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: colors.surfaceLight,
                    onPressed: () {
                      setState(() => _manualTagController.text = tag);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Ders Adı',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _manualSubjectController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Veri Yapıları, İngilizce, Fizik',
                ),
              ),
              if (existingSubjects.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: existingSubjects.take(8).map((subj) {
                    return ActionChip(
                      label: Text(subj, style: const TextStyle(fontSize: 12)),
                      backgroundColor: colors.surface,
                      onPressed: () {
                        setState(() => _manualSubjectController.text = subj);
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Konular (Her satıra bir konu — boş bırakırsan "Genel Çalışma" açılır)',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _manualTopicsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Bağlı Listeler\nYığın ve Kuyruk\nİkili Arama Ağaçları',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Önem Derecesi',
                    style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  ...List.generate(5, (i) {
                    final value = i + 1;
                    final selected = _manualImportance == value;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _manualImportance = value),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? colors.primary : colors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$value',
                            style: TextStyle(
                              color: selected ? colors.onPrimary : AppColors.of(context).textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _saveManualCourse(repository),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Dersi ve Konuları Ekle'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          padding: const EdgeInsets.all(18),
          radius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.upload_file, color: colors.primaryLight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'CSV / Metin Dosyasından Toplu Yükle',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Her satır "Ders,Konu" veya "Ders;Konu" formatında olmalıdır (UTF-8 destekli). Yukarıdaki Etiket alanını kullanır.',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickAndImportCsv(repository),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('CSV / TXT Dosyası Seç'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveManualCourse(AppRepository repository) async {
    final subject = _manualSubjectController.text.trim();
    if (subject.isEmpty) {
      InAppNotice.show(context, 'Lütfen bir ders adı gir.');
      return;
    }

    final tag = _manualTagController.text.trim().isEmpty
        ? 'Genel'
        : _manualTagController.text.trim();
    final lines = _manualTopicsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final added = await repository.addCourseTopics(
      subject: subject,
      topicTitles: lines,
      tag: tag,
      importance: _manualImportance,
    );

    if (!mounted) return;
    _manualSubjectController.clear();
    _manualTopicsController.clear();
    InAppNotice.show(
      context,
      added > 0
          ? '$subject için $added konu eklendi.'
          : 'Bu konular zaten mevcut.',
    );
  }

  Future<void> _pickAndImportCsv(AppRepository repository) async {
    final tag = _manualTagController.text.trim().isEmpty
        ? 'Genel'
        : _manualTagController.text.trim();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      String content = '';
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!, allowMalformed: true);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString(encoding: utf8);
      }

      if (content.trim().isEmpty) {
        if (mounted) InAppNotice.show(context, 'Dosya içeriği boş.');
        return;
      }

      final bySubject = <String, List<String>>{};
      for (final rawLine in content.split(RegExp(r'\r?\n'))) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;
        final sep = line.contains(';') ? ';' : ',';
        if (!line.contains(sep)) continue;
        final parts = line.split(sep);
        if (parts.length < 2) continue;
        final subject = parts[0].trim();
        final title = parts.sublist(1).join(sep).trim();
        if (subject.isEmpty || title.isEmpty) continue;
        // Skip common CSV header row
        if (subject.toLowerCase() == 'ders' && title.toLowerCase() == 'konu') {
          continue;
        }
        bySubject.putIfAbsent(subject, () => []).add(title);
      }

      var totalAdded = 0;
      for (final entry in bySubject.entries) {
        totalAdded += await repository.addCourseTopics(
          subject: entry.key,
          topicTitles: entry.value,
          tag: tag,
        );
      }

      if (!mounted) return;
      InAppNotice.show(
        context,
        totalAdded > 0
            ? '$totalAdded konu ($tag) başarıyla içe aktarıldı.'
            : 'Yeni eklenecek geçerli satır bulunamadı.',
      );
    } catch (e) {
      debugPrint('CurriculumHubScreen: CSV import failed: $e');
      if (mounted) {
        InAppNotice.show(context, 'Dosya okunurken hata oluştu.');
      }
    }
  }

  // --- TAB 2: AI CURRICULUM GENERATOR ---

  Widget _buildAiTab(BuildContext context, AppRepository repository) {
    final colors = AppColors.of(context);
    const examples = [
      'Bilgisayar Mühendisliği Veri Yapıları final konuları',
      'B1-B2 Almanca çalışma müfredatı',
      'TUS Temel Bilimler ders ve konuları',
      'LGS 8. sınıf tüm dersler',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(18),
          radius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.auto_awesome, color: colors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Ders & Konu Oluşturucu',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.of(context).textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Ne çalışacağını yaz, Gemini ders ve konu ağacını otomatik kursun.',
                          style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _aiPromptController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Örn: Hukuk Fakültesi 2. sınıf Ceza Hukuku Genel Hükümler konuları',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _aiTagController,
                decoration: const InputDecoration(
                  hintText: 'Etiket / Sınav Adı (Opsiyonel — boşsa AI belirler)',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: examples.map((sample) {
                  return ActionChip(
                    label: Text(sample, style: const TextStyle(fontSize: 11)),
                    backgroundColor: colors.surfaceLight,
                    onPressed: () {
                      setState(() => _aiPromptController.text = sample);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generateAiCurriculum(repository),
                  icon: const Icon(Icons.psychology),
                  label: const Text('AI ile Müfredat Oluştur'),
                ),
              ),
            ],
          ),
        ),
        if (_aiDrafts.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassPanel(
            padding: const EdgeInsets.all(18),
            radius: BorderRadius.circular(22),
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
                            'Önerilen Müfredat ($_aiSuggestedTag)',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.of(context).textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            '${_aiDrafts.where((d) => d.selected).length} / ${_aiDrafts.length} konu seçili',
                            style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final allSelected = _aiDrafts.every((d) => d.selected);
                        setState(() {
                          for (final d in _aiDrafts) {
                            d.selected = !allSelected;
                          }
                        });
                      },
                      child: Text(
                        _aiDrafts.every((d) => d.selected)
                            ? 'Seçimi Kaldır'
                            : 'Tümünü Seç',
                      ),
                    ),
                  ],
                ),
                Divider(color: AppColors.of(context).divider, height: 18),
                ..._aiDrafts.map((draft) {
                  return CheckboxListTile(
                    value: draft.selected,
                    activeColor: colors.primary,
                    checkColor: colors.onPrimary,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      draft.title,
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      draft.summary.isNotEmpty
                          ? '${draft.subject} • ${draft.summary}'
                          : draft.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                    ),
                    onChanged: (v) => setState(() => draft.selected = v ?? false),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _aiDrafts.any((d) => d.selected)
                        ? () => _commitAiDrafts(repository)
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      'Seçili ${_aiDrafts.where((d) => d.selected).length} Konuyu Ekle',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _generateAiCurriculum(AppRepository repository) async {
    final request = _aiPromptController.text.trim();
    if (request.isEmpty) {
      InAppNotice.show(context, 'Lütfen oluşturmak istediğin dersi veya sınavı yaz.');
      return;
    }

    final apiKey = repository.geminiApiKey.value;
    if (apiKey.isEmpty) {
      InAppNotice.show(context, 'Önce Profil sekmesinden Gemini API anahtarını ekle.');
      return;
    }

    var dialogOpen = true;
    AiLoadingDialog.show(context, status: 'AI müfredat hazırlıyor...')
        .then((_) => dialogOpen = false);

    void closeLoading() {
      if (dialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
    }

    try {
      final model = repository.geminiModel.value.isEmpty
          ? 'gemini-1.5-flash-latest'
          : repository.geminiModel.value;
      final forcedTag = _aiTagController.text.trim();

      final prompt = '''
Kullanıcının çalışma isteğine göre Türkçe, gerçekçi ve yapılandırılmış bir ders/konu müfredatı hazırla.
İstek: "$request"
${forcedTag.isNotEmpty ? 'Kategori etiketi olarak kesinlikle "$forcedTag" kullan.' : ''}

Sadece geçerli ham JSON döndür (markdown blokları veya açıklama ekleme).
Şema:
{
  "tag": "Kısa sınav/kategori adı (örn: Üniversite, Almanca, LGS)",
  "wrongPenalty": 0.0 veya 0.25 veya 0.33,
  "courses": [
    {
      "subject": "Ders adı",
      "topics": [
        {"title": "Konu adı", "importance": 4, "summary": "Kısa 1 cümle özet"}
      ]
    }
  ]
}
En fazla 4 ders ve toplamda en fazla 25 net, öz konu üret.
''';

      final raw = await GeminiClient().generateText(
        apiKey: apiKey,
        prompt: prompt,
        model: model,
      );
      await repository.incrementAiRequestCount();
      closeLoading();

      final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
      if (match == null) {
        throw const FormatException('JSON bulunamadı');
      }
      final decoded = jsonDecode(match.group(0)!) as Map<String, dynamic>;
      final tag = forcedTag.isNotEmpty
          ? forcedTag
          : (decoded['tag'] as String? ?? 'Özel').trim();
      final penalty = (decoded['wrongPenalty'] as num?)?.toDouble() ?? 0.0;
      final courses = decoded['courses'] as List<dynamic>? ?? const [];

      final drafts = <_GeneratedTopicDraft>[];
      for (final course in courses) {
        if (course is! Map) continue;
        final subject = (course['subject'] as String? ?? '').trim();
        final topics = course['topics'] as List<dynamic>? ?? const [];
        if (subject.isEmpty) continue;
        for (final topic in topics) {
          if (topic is Map) {
            final title = (topic['title'] as String? ?? '').trim();
            if (title.isEmpty) continue;
            drafts.add(
              _GeneratedTopicDraft(
                subject: subject,
                title: title,
                importance: ((topic['importance'] as num?)?.toInt() ?? 3).clamp(1, 5),
                summary: (topic['summary'] as String? ?? '').trim(),
              ),
            );
          } else if (topic is String && topic.trim().isNotEmpty) {
            drafts.add(_GeneratedTopicDraft(subject: subject, title: topic.trim()));
          }
        }
      }

      if (!mounted) return;
      if (drafts.isEmpty) {
        InAppNotice.show(context, 'AI konu listesi üretemedi, isteği detaylandırıp tekrar dene.');
        return;
      }

      setState(() {
        _aiSuggestedTag = tag.isEmpty ? 'Özel' : tag;
        _aiSuggestedPenalty = penalty;
        _aiDrafts = drafts;
      });
    } catch (e) {
      debugPrint('CurriculumHubScreen: AI curriculum generation failed: $e');
      closeLoading();
      if (mounted) {
        InAppNotice.show(context, 'AI müfredat oluşturulamadı. API anahtarını ve modeli kontrol et.');
      }
    }
  }

  Future<void> _commitAiDrafts(AppRepository repository) async {
    final selected = _aiDrafts.where((d) => d.selected).toList();
    if (selected.isEmpty) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final tag = _aiTagController.text.trim().isNotEmpty
        ? _aiTagController.text.trim()
        : _aiSuggestedTag;

    final topics = <TopicSummary>[];
    for (var i = 0; i < selected.length; i++) {
      final d = selected[i];
      topics.add(
        TopicSummary(
          id: 'ai-$now-$i',
          subject: d.subject,
          title: d.title,
          nextReview: '',
          summary: d.summary,
          importance: d.importance,
          tag: tag,
        ),
      );
    }

    await repository.upsertExamProfile(
      ExamProfile(name: tag, wrongPenalty: _aiSuggestedPenalty),
    );
    await repository.addUserTopics(topics);

    if (!mounted) return;
    setState(() => _aiDrafts = []);
    _aiPromptController.clear();
    InAppNotice.show(context, '${topics.length} AI konusu ($tag) eklendi.');
  }
}

class _GeneratedTopicDraft {
  _GeneratedTopicDraft({
    required this.subject,
    required this.title,
    this.importance = 3,
    this.summary = '',
  });

  final String subject;
  final String title;
  final int importance;
  final String summary;
  bool selected = true;
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.loadedTopicCount,
    required this.onImportAll,
    required this.onPickSubjects,
  });

  final ExamPreset preset;
  final int loadedTopicCount;
  final VoidCallback onImportAll;
  final VoidCallback onPickSubjects;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final penaltyText = preset.defaultWrongPenalty <= 0.001
        ? 'Cezasız'
        : '4Y = 1D';

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            preset.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.of(context).textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            penaltyText,
                            style: TextStyle(
                              color: colors.primaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.subtitle,
                      style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (loadedTopicCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$loadedTopicCount yüklü',
                    style: TextStyle(
                      color: colors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: preset.subjects.keys.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.of(context).subtleFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subject,
                  style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 11),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPickSubjects,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: BorderSide(color: AppColors.of(context).border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Ders Seç'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onImportAll,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Tümünü Ekle (${preset.totalTopics})'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
