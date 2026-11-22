import 'dart:io';
import 'dart:math';
import 'dart:ui'; // Add for FontFeature

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/models/mock_exam.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/in_app_notice.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../curriculum/screens/curriculum_hub_screen.dart';
import '../../dashboard/screens/home_screen.dart';
import '../../settings/screens/profile_screen.dart'; // Import ProfileScreen
import 'topic_summaries_screen.dart'; // Import TopicSummariesScreen

enum EntryType { question, mockExam }

class EntryWizardScreen extends StatefulWidget {
  const EntryWizardScreen({
    super.key,
    required this.type,
    this.preselectedTopic,
    this.initialData,
    this.initialImagePath,
  });

  final EntryType type;
  final TopicSummary? preselectedTopic;
  final Map<String, dynamic>? initialData;
  final String? initialImagePath;

  @override
  State<EntryWizardScreen> createState() => _EntryWizardScreenState();
}

class _EntryWizardScreenState extends State<EntryWizardScreen> {
  int _currentStep = 0;
  int _correct = 0;
  int _wrong = 0;
  int _blank = 0;
  int _minutes = 25;
  String _selectedSubject = '';
  String _selectedTopic = '';
  DateTime _selectedDate = DateTime.now();
  final List<File> _selectedImages = [];
  
  final Map<String, double> _examSubjectNets = {};
  final Map<String, int> _examSubjectMinutes = {};
  final Set<String> _errorTags = {};
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _examTypeController = TextEditingController(text: 'Genel');
  final TextEditingController _examFocusSubjectController = TextEditingController();
  final TextEditingController _examFocusTopicController = TextEditingController();
  String _examScope = 'Genel Deneme';
  String _subjectTagFilter = 'Tümü';
  final List<String> _extraExamSubjects = [];

  static const List<String> _errorTagOptions = [
    'İşlem Hatası',
    'Dikkat',
    'Bilgi Eksikliği',
    'Süre',
  ];

  static const List<String> _examTypes = [
    'Genel Deneme',
    'Branş Denemesi',
    'Konu Denemesi',
    'Türkiye Geneli',
    'Çıkmış Sorular',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _selectedImages.add(File(widget.initialImagePath!));
    }
    if (widget.preselectedTopic != null) {
      _selectedSubject = widget.preselectedTopic!.subject;
      _selectedTopic = widget.preselectedTopic!.title;
      _examTypeController.text = widget.preselectedTopic!.tag;
      _examFocusSubjectController.text = widget.preselectedTopic!.subject;
      _examFocusTopicController.text = widget.preselectedTopic!.title;
      if (widget.type == EntryType.mockExam) {
        _examScope = 'Konu Denemesi';
      }
      _currentStep = 2; // Start at results if topic is preselected
    }
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _correct = data['correct'] as int? ?? 0;
      _wrong = data['wrong'] as int? ?? 0;
      _blank = data['blank'] as int? ?? 0;
      _minutes = data['minutes'] as int? ?? 25;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _bookController.dispose();
    _examTypeController.dispose();
    _examFocusSubjectController.dispose();
    _examFocusTopicController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.of(context).textPrimary),
              title: Text('Kameradan Çek', style: TextStyle(color: AppColors.of(context).textPrimary)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.of(context).textPrimary),
              title: Text('Galeriden Seç', style: TextStyle(color: AppColors.of(context).textPrimary)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        final dir = await getApplicationDocumentsDirectory();
        final name = 'question_${DateTime.now().millisecondsSinceEpoch}_${_selectedImages.length}.jpg';
        final savedImage = await File(picked.path).copy('${dir.path}/$name');
        setState(() {
          _selectedImages.add(savedImage);
        });
      }
    } catch (e) {
      _showSnack('Fotoğraf seçilemedi: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _openStopwatch() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _StopwatchDialog(
        initialMinutes: 0,
        onStop: (elapsedMinutes) {
           setState(() {
             _minutes = elapsedMinutes;
           });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    return ValueListenableBuilder<List<TopicSummary>>(
      valueListenable: repository.userTopics,
      builder: (context, allTopics, _) {
        final availableTags = repository.availableTags;
        final effectiveTagFilter =
            (_subjectTagFilter != 'Tümü' && availableTags.contains(_subjectTagFilter))
                ? _subjectTagFilter
                : 'Tümü';
        final subjects = repository.subjectsForTag(
          effectiveTagFilter == 'Tümü' ? null : effectiveTagFilter,
        );

        final enteredTag = _examTypeController.text.trim();
        final topics = allTopics
            .where((item) =>
                (_selectedSubject.isEmpty || item.subject == _selectedSubject) &&
                (effectiveTagFilter == 'Tümü' || item.tag == effectiveTagFilter))
            .toList()
          ..sort((a, b) {
            if (enteredTag.isEmpty) return 0;
            final aMatches = a.tag.toLowerCase().contains(enteredTag.toLowerCase());
            final bMatches = b.tag.toLowerCase().contains(enteredTag.toLowerCase());
            if (aMatches && !bMatches) return -1;
            if (!aMatches && bMatches) return 1;
            return 0;
          });

        return Scaffold(
          backgroundColor: AppColors.of(context).background,
          body: AmbientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _WizardHeader(
                    title: widget.type == EntryType.question
                        ? 'Soru Kaydı'
                        : 'Deneme Kaydı',
                    onClear: _reset,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: _StepProgress(currentStep: _currentStep, totalSteps: 4),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildStepContent(
                              repository,
                              availableTags,
                              effectiveTagFilter,
                              subjects,
                              topics,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _BottomActions(
                            canGoBack: _currentStep > 0,
                            isLastStep: _currentStep == 3,
                            onNext: _nextStep,
                            onBack: _backStep,
                            onSave: () => _save(repository),
                            onSaveAndAdd: () => _save(repository, keepOpen: true),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _quickCreateCourse(AppRepository repository) async {
    final subjectCtrl = TextEditingController();
    final topicCtrl = TextEditingController();
    final tagCtrl = TextEditingController(
      text: _subjectTagFilter == 'Tümü' ? 'Genel' : _subjectTagFilter,
    );

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hızlı Ders & Konu Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tagCtrl,
              decoration: const InputDecoration(labelText: 'Kategori / Sınav'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Ders Adı',
                hintText: 'Örn: Veri Yapıları, İngilizce',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: topicCtrl,
              decoration: const InputDecoration(
                labelText: 'Konu Adı (Opsiyonel)',
                hintText: 'Örn: Ağaçlar',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ekle ve Seç'),
          ),
        ],
      ),
    );

    final subject = subjectCtrl.text.trim();
    final topic = topicCtrl.text.trim();
    final tag = tagCtrl.text.trim().isEmpty ? 'Genel' : tagCtrl.text.trim();
    subjectCtrl.dispose();
    topicCtrl.dispose();
    tagCtrl.dispose();

    if (created == true && subject.isNotEmpty) {
      final effectiveTopic = topic.isEmpty ? 'Genel Çalışma' : topic;
      await repository.addCourseTopics(
        subject: subject,
        topicTitles: [effectiveTopic],
        tag: tag,
      );
      if (mounted) {
        setState(() {
          _selectedSubject = subject;
          _selectedTopic = effectiveTopic;
          _examTypeController.text = tag;
        });
      }
    }
  }

  Future<void> _quickCreateTopic(AppRepository repository) async {
    final topicCtrl = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$_selectedSubject — Yeni Konu'),
        content: TextField(
          controller: topicCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Konu Adı',
            hintText: 'Yeni konu başlığı',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, topicCtrl.text.trim()),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    topicCtrl.dispose();

    if (title != null && title.isNotEmpty) {
      final tag = _examTypeController.text.trim().isEmpty
          ? 'Genel'
          : _examTypeController.text.trim();
      await repository.addCourseTopics(
        subject: _selectedSubject,
        topicTitles: [title],
        tag: tag,
      );
      if (mounted) {
        setState(() => _selectedTopic = title);
      }
    }
  }

  Widget _buildStepContent(
    AppRepository repository,
    List<String> availableTags,
    String effectiveTagFilter,
    List<String> subjects,
    List<TopicSummary> topics,
  ) {
    if (widget.type == EntryType.question) {
      switch (_currentStep) {
        case 0:
          return Column(
            key: const ValueKey(0),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: _SectionTitle(index: 1, title: 'Ders seç')),
                  TextButton.icon(
                    onPressed: () => _quickCreateCourse(repository),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Yeni Ders'),
                  ),
                ],
              ),
              if (availableTags.length > 1) ...[
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Tümü', ...availableTags].map((tag) {
                      final active = effectiveTagFilter == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: active,
                          onSelected: (_) => setState(() {
                            _subjectTagFilter = tag;
                            if (tag != 'Tümü') _examTypeController.text = tag;
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (subjects.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.of(context).border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Henüz ders eklemedin.',
                        style: TextStyle(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hazır sınav paketlerinden seçebilir veya özel ders oluşturabilirsin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CurriculumHubScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.auto_stories_outlined),
                        label: const Text('Müfredat Merkezini Aç'),
                      ),
                    ],
                  ),
                )
              else
                _SubjectGrid(
                  subjects: subjects,
                  selected: _selectedSubject,
                  onSelect: (value) {
                    final matchedTag = repository.userTopics.value
                        .where((t) => t.subject == value)
                        .map((t) => t.tag)
                        .firstOrNull;
                    setState(() {
                      if (_selectedSubject != value) _selectedTopic = '';
                      _selectedSubject = value;
                      if (matchedTag != null && matchedTag.isNotEmpty) {
                        _examTypeController.text = matchedTag;
                      }
                    });
                  },
                ),
            ],
          );
        case 1:
          return Column(
            key: const ValueKey(1),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: _SectionTitle(index: 2, title: 'Konu belirle')),
                  if (_selectedSubject.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _quickCreateTopic(repository),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Konu Ekle'),
                    ),
                ],
              ),
              _TopicSelector(
                topics: topics,
                selected: _selectedTopic,
                onSelect: (value) {
                  setState(() => _selectedTopic = value);
                },
              ),
            ],
          );
        case 2:
          return Column(
            key: const ValueKey(2),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 3, title: 'Sonuçlar'),
              _ResultPicker(
                correct: _correct,
                wrong: _wrong,
                blank: _blank,
                onChanged: _updateResults,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                    Expanded(
                        child: _DurationPicker(
                        minutes: _minutes,
                        onChanged: (value) => setState(() => _minutes = value),
                        ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                        onTap: _openStopwatch,
                        child: Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                                color: AppColors.of(context).primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.of(context).primary.withOpacity(0.5),
                                ),
                            ),
                            child: Icon(Icons.timer, color: AppColors.of(context).primary),
                        ),
                    ),
                ],
              ),
            ],
          );
        case 3:
          return Column(
            key: const ValueKey(3),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 4, title: 'Detaylar'),
              _SourceField(controller: _bookController),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sınav Türü / Etiket',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.of(context).textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _examTypeController,
                    decoration: const InputDecoration(
                      hintText: 'Örn: KPSS, YKS, DGS',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Yanlış Türleri',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _ErrorTagSelector(
                tags: _errorTagOptions,
                selected: _errorTags,
                onToggle: (tag) {
                  setState(() {
                    if (_errorTags.contains(tag)) {
                      _errorTags.remove(tag);
                    } else {
                      _errorTags.add(tag);
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Hata Defteri İçin Fotoğraflar',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_selectedImages.isNotEmpty)
                 SizedBox(
                   height: 120,
                   child: ListView.builder(
                     scrollDirection: Axis.horizontal,
                     itemCount: _selectedImages.length + 1,
                     itemBuilder: (context, index) {
                       if (index == _selectedImages.length) {
                         return GestureDetector(
                           onTap: _pickImage,
                           child: Container(
                             width: 100,
                             margin: const EdgeInsets.only(right: 12),
                             decoration: BoxDecoration(
                               color: AppColors.of(context).subtleFill,
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: AppColors.of(context).border),
                             ),
                             child: Icon(Icons.add_a_photo, color: AppColors.of(context).textSecondary),
                           ),
                         );
                       }
                       final img = _selectedImages[index];
                       return Stack(
                         children: [
                           Container(
                             width: 100,
                             margin: const EdgeInsets.only(right: 12),
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(16),
                               child: Image.file(img, fit: BoxFit.cover),
                             ),
                           ),
                           Positioned(
                             top: 4,
                             right: 16,
                             child: GestureDetector(
                               onTap: () => _removeImage(index),
                               child: Container(
                                 padding: const EdgeInsets.all(4),
                                 decoration: const BoxDecoration(
                                   color: Colors.black54,
                                   shape: BoxShape.circle,
                                 ),
                                 child: Icon(Icons.close, color: AppColors.of(context).textPrimary, size: 14),
                               ),
                             ),
                           ),
                         ],
                       );
                     },
                   ),
                 )
              else
                 GestureDetector(
                     onTap: _pickImage,
                     child: Container(
                         height: 100,
                         width: double.infinity,
                         decoration: BoxDecoration(
                             color: AppColors.of(context).subtleFill,
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: AppColors.of(context).border, style: BorderStyle.solid),
                         ),
                         child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                                 Icon(Icons.add_a_photo, color: AppColors.of(context).textSecondary, size: 32),
                                 const SizedBox(height: 8),
                                 Text(
                                     'Hatalı Soru Fotoğraflarını Ekle',
                                     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary),
                                 ),
                             ],
                         ),
                     ),
                 ),
              
              const SizedBox(height: 20),
              _DatePickerRow(
                selectedDate: _selectedDate,
                onPickDate: _pickDate,
              ),
              const SizedBox(height: 20),
              Text(
                'Notlar',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _NoteField(controller: _noteController),
            ],
          );
      }
    } else {
      // Mock Exam steps
      final currentExamTag = _examTypeController.text.trim().isEmpty
          ? 'Genel'
          : _examTypeController.text.trim();
      final computedNet = repository.calculateNet(
        _correct,
        _wrong,
        tag: currentExamTag,
      );
      final dynamicBranches = <String>{
        ...repository.subjectsForTag(
          currentExamTag == 'Genel' ? null : currentExamTag,
        ),
        if (repository.subjectsForTag(currentExamTag).isEmpty)
          ...repository.subjectsForTag(null),
        ..._extraExamSubjects,
      }.toList()
        ..sort();

      switch (_currentStep) {
        case 0:
          final isTopicScope = _examScope == 'Konu Denemesi';
          final isBranchScope = _examScope == 'Branş Denemesi';
          final focusSubjectText = _examFocusSubjectController.text.trim();
          final matchingFocusTopics = repository.userTopics.value
              .where((t) =>
                  focusSubjectText.isEmpty ||
                  t.subject.toLowerCase() == focusSubjectText.toLowerCase())
              .map((t) => t.title)
              .toSet()
              .toList();

          return Column(
            key: const ValueKey(0),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 1, title: 'Deneme türü ve bilgileri'),
              Text(
                'Deneme Türü',
                style: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _examTypes.map((scope) {
                  final active = _examScope == scope;
                  return ChoiceChip(
                    label: Text(scope),
                    selected: active,
                    onSelected: (_) => setState(() {
                      _examScope = scope;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: isTopicScope
                      ? 'Boş bırakırsan Ders • Konu Denemesi olur'
                      : 'Örn: Deneme 1, Haftalık Tarama',
                  labelText: 'Deneme Adı (Opsiyonel)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _examTypeController,
                decoration: const InputDecoration(
                  labelText: 'Sınav / Kategori',
                  hintText: 'Örn: KPSS Lisans, TYT (Maarif), AYT, YDS',
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (availableTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: availableTags.map((tag) {
                    return ChoiceChip(
                      label: Text(tag),
                      selected: _examTypeController.text.trim() == tag,
                      onSelected: (_) => setState(() {
                        _examTypeController.text = tag;
                      }),
                    );
                  }).toList(),
                ),
              ],
              if (isTopicScope || isBranchScope) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _examFocusSubjectController,
                  decoration: const InputDecoration(
                    labelText: 'Ders',
                    hintText: 'Örn: Matematik, Fizik, Tarih',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (dynamicBranches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dynamicBranches.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, idx) {
                        final subj = dynamicBranches[idx];
                        return ChoiceChip(
                          label: Text(subj, style: const TextStyle(fontSize: 12)),
                          selected: focusSubjectText == subj,
                          onSelected: (_) => setState(() {
                            _examFocusSubjectController.text = subj;
                            _examFocusTopicController.clear();
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ],
              if (isTopicScope) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _examFocusTopicController,
                  decoration: const InputDecoration(
                    labelText: 'Deneme Konusu',
                    hintText: 'Örn: Limit ve Süreklilik, Problemler',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (matchingFocusTopics.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: matchingFocusTopics.take(20).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, idx) {
                        final title = matchingFocusTopics[idx];
                        return ChoiceChip(
                          label: Text(title, style: const TextStyle(fontSize: 12)),
                          selected: _examFocusTopicController.text.trim() == title,
                          onSelected: (_) => setState(() {
                            _examFocusTopicController.text = title;
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          );
        case 1:
          return Column(
            key: const ValueKey(1),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 2, title: 'Tarih seç'),
              _CalendarPicker(
                selectedDate: _selectedDate,
                onChanged: (date) {
                  setState(() => _selectedDate = date);
                  _nextStep();
                },
              ),
            ],
          );
        case 2:
          final penaltyLabel =
              repository.profileForTag(currentExamTag)?.penaltyLabel ??
                  '4 Yanlış 1 Doğru';
          return Column(
            key: const ValueKey(2),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 3, title: 'Sonuçlar'),
              _ResultPicker(
                correct: _correct,
                wrong: _wrong,
                blank: _blank,
                onChanged: _updateResults,
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${computedNet.toStringAsFixed(2)} Net',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.of(context).primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentExamTag • $penaltyLabel',
                      style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DurationPicker(
                      minutes: _minutes,
                      onChanged: (value) => setState(() => _minutes = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _openStopwatch,
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.of(context).primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(Icons.timer, color: AppColors.of(context).primary),
                    ),
                  ),
                ],
              ),
            ],
          );
        case 3:
          final isTopicOrBranch = _examScope == 'Konu Denemesi' ||
              _examScope == 'Branş Denemesi';
          final focusSubj = _examFocusSubjectController.text.trim();
          final focusTop = _examFocusTopicController.text.trim();
          return Column(
            key: const ValueKey(3),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 4, title: 'Detaylar'),
              if (isTopicOrBranch)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.of(context).primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _examScope,
                        style: TextStyle(
                          color: AppColors.of(context).primaryLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (focusSubj.isNotEmpty) focusSubj,
                          if (focusTop.isNotEmpty) focusTop,
                        ].join(' • '),
                        style: TextStyle(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${computedNet.toStringAsFixed(2)} net ve $_minutes dk otomatik olarak bu derse işlenecek.',
                        style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ders Dağılımı (Opsiyonel)',
                        style: TextStyle(
                            color: AppColors.of(context).textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final ctrl = TextEditingController();
                        final added = await showDialog<String>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Branş / Ders Ekle'),
                            content: TextField(
                              controller: ctrl,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Örn: Fizik, Veri Yapıları',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Vazgeç'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(
                                    dialogContext, ctrl.text.trim()),
                                child: const Text('Ekle'),
                              ),
                            ],
                          ),
                        );
                        ctrl.dispose();
                        if (added != null && added.isNotEmpty) {
                          setState(() => _extraExamSubjects.add(added));
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Branş Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (dynamicBranches.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Henüz ders tanımlı değil. Yukarıdan "Branş Ekle" ile ders ekleyebilirsin.',
                      style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                    ),
                  )
                else
                  _ExamSubjectBreakdown(
                    subjects: dynamicBranches,
                    onNetChanged: (subject, value) {
                      setState(() => _examSubjectNets[subject] = value);
                    },
                    onMinutesChanged: (subject, value) {
                      setState(() => _examSubjectMinutes[subject] = value);
                    },
                  ),
              ],
              const SizedBox(height: 20),
              Text(
                'Notlar',
                style: TextStyle(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _NoteField(controller: _noteController),
            ],
          );
      }
    }
    return const SizedBox();
  }

  void _nextStep() {
    if (widget.type == EntryType.question) {
      if (_currentStep == 0 && _selectedSubject.isEmpty) {
        _showSnack('Devam etmek için bir ders seçin veya ekleyin.');
        return;
      }
      if (_currentStep == 1 && _selectedTopic.isEmpty) {
        _showSnack('Devam etmek için bir konu seçin veya ekleyin.');
        return;
      }
    } else if (_currentStep == 0) {
      if (_examScope == 'Konu Denemesi' &&
          _examFocusSubjectController.text.trim().isEmpty &&
          _examFocusTopicController.text.trim().isEmpty) {
        _showSnack('Konu denemesi için en az bir ders veya konu belirtin.');
        return;
      }
      if (_examScope == 'Branş Denemesi' &&
          _examFocusSubjectController.text.trim().isEmpty) {
        _showSnack('Branş denemesi için ders adını seçin veya yazın.');
        return;
      }
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _backStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _correct = 0;
      _wrong = 0;
      _blank = 0;
      _minutes = 25;
      _selectedSubject = '';
      _selectedTopic = '';
      _examScope = 'Genel Deneme';
      _selectedDate = DateTime.now();
      _selectedImages.clear();
      _examSubjectNets.clear();
      _examSubjectMinutes.clear();
      _errorTags.clear();
    });
    _titleController.clear();
    _noteController.clear();
    _bookController.clear();
    _examFocusSubjectController.clear();
    _examFocusTopicController.clear();
  }

  void _updateResults(int correct, int wrong, int blank) {
    setState(() {
      _correct = correct;
      _wrong = wrong;
      _blank = blank;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save(AppRepository repository, {bool keepOpen = false}) async {
    final now = DateTime.now();
    final createdAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
    );
    if (widget.type == EntryType.question) {
      if (_selectedSubject.isEmpty || _selectedTopic.isEmpty) {
        _showSnack('Lütfen ders ve konu seçin.');
        return;
      }
      await repository.addQuestionEntry(
        QuestionEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookName: _bookController.text.trim(),
          subject: _selectedSubject,
          topic: _selectedTopic,
          correct: _correct,
          wrong: _wrong,
          blank: _blank,
          minutes: _minutes,
          note: _noteController.text.trim(),
          createdAt: createdAt,
          errorTags: _errorTags.toList(),
          examType: _examTypeController.text.trim().isEmpty
              ? 'Genel'
              : _examTypeController.text.trim(),
          imagePaths: _selectedImages.map((e) => e.path).toList(),
        ),
      );
    } else {
      final resolvedExamType = _examTypeController.text.trim().isEmpty
          ? 'Genel'
          : _examTypeController.text.trim();
      final focusSubject = _examFocusSubjectController.text.trim();
      final focusTopic = _examFocusTopicController.text.trim();
      final totalNet =
          repository.calculateNet(_correct, _wrong, tag: resolvedExamType);

      final nets = Map<String, double>.from(_examSubjectNets)
        ..removeWhere((_, value) => value <= 0);
      final mins = Map<String, int>.from(_examSubjectMinutes)
        ..removeWhere((_, value) => value <= 0);

      if ((_examScope == 'Konu Denemesi' || _examScope == 'Branş Denemesi') &&
          focusSubject.isNotEmpty) {
        nets[focusSubject] = totalNet;
        if (_minutes > 0) mins[focusSubject] = _minutes;
      }

      var title = _titleController.text.trim();
      if (title.isEmpty) {
        if (_examScope == 'Konu Denemesi') {
          final labelParts = [
            if (focusSubject.isNotEmpty) focusSubject,
            if (focusTopic.isNotEmpty) focusTopic,
          ];
          title = labelParts.isEmpty
              ? 'Konu Denemesi'
              : '${labelParts.join(' • ')} Denemesi';
        } else if (_examScope == 'Branş Denemesi' && focusSubject.isNotEmpty) {
          title = '$focusSubject Branş Denemesi';
        } else {
          title = _examScope;
        }
      }

      await repository.addMockExam(
        MockExam(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          dateLabel: _formatDate(_selectedDate),
          correct: _correct,
          wrong: _wrong,
          blank: _blank,
          totalNet: totalNet,
          minutes: _minutes,
          note: _noteController.text.trim(),
          createdAt: createdAt,
          subjectNets: nets,
          subjectMinutes: mins,
          examType: resolvedExamType,
          examScope: _examScope,
          focusSubject: focusSubject,
          focusTopic: focusTopic,
        ),
      );
    }

    _showSnack('Kayıt eklendi.');
    if (keepOpen) {
      _reset();
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String message) {
    InAppNotice.show(context, message);
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}';
  }
}

// --- STOPWATCH DIALOG ---
class _StopwatchDialog extends StatefulWidget {
  const _StopwatchDialog({required this.initialMinutes, required this.onStop});
  final int initialMinutes;
  final ValueChanged<int> onStop;

  @override
  State<_StopwatchDialog> createState() => _StopwatchDialogState();
}

class _StopwatchDialogState extends State<_StopwatchDialog> {
  late Stopwatch _stopwatch;
  late int _baseMinutes;
  // Timer to refresh UI
  Stream<int>? _timerStream;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _baseMinutes = widget.initialMinutes;
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  void _finish() {
    _stopwatch.stop();
    final totalMinutes = _baseMinutes + _stopwatch.elapsed.inMinutes;
    widget.onStop(totalMinutes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: AppColors.of(context).background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text("Süre Tutuluyor", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.of(context).textPrimary)),
                    const SizedBox(height: 24),
                    StreamBuilder<int>(
                        stream: _timerStream,
                        builder: (context, snapshot) {
                            final elapsed = _stopwatch.elapsed;
                            final h = elapsed.inHours.toString().padLeft(2, '0');
                            final m = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
                            final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
                            return Text(
                                "$h:$m:$s",
                                style: TextStyle(
                                    fontSize: 48, 
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.of(context).primary,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                            );
                        },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Bitti, Süreyi Kaydet"),
                        ),
                    ),
                ],
            ),
        ),
    );
  }
}

// --- REST OF WIDGETS ---
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.of(context).primary
                  : AppColors.of(context).subtleFill,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.canGoBack,
    required this.isLastStep,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onSaveAndAdd,
  });

  final bool canGoBack;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onSaveAndAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.of(context).background,
        border: Border(top: BorderSide(color: AppColors.of(context).border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (canGoBack) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Geri'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLastStep ? onSave : onNext,
                  child: Text(isLastStep ? 'Kaydet' : 'İleri'),
                ),
              ),
            ],
          ),
          if (isLastStep)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton(
                onPressed: onSaveAndAdd,
                child: const Text('Kaydet ve Bir Tane Daha Ekle'),
              ),
            ),
        ],
      ),
    );
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.title, required this.onClear});

  final String title;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final popped = await Navigator.of(context).maybePop();
              if (!popped && context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              }
            },
            icon: Icon(Icons.close, color: AppColors.of(context).textSecondary),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.of(context).textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.of(context).subtleFill,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              index.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.of(context).textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid({
    required this.subjects,
    required this.selected,
    required this.onSelect,
  });

  final List<String> subjects;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final active = subject == selected;
        return GestureDetector(
          onTap: () => onSelect(subject),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? AppColors.of(context).primary.withOpacity(0.2) : AppColors.of(context).surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active
                    ? AppColors.of(context).primary
                    : AppColors.of(context).subtleFill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).subtleFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book,
                      color: active ? AppColors.of(context).primary : AppColors.of(context).textSecondary),
                ),
                const Spacer(),
                Text(
                  subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalendarPicker extends StatelessWidget {
  const _CalendarPicker({required this.selectedDate, required this.onChanged});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: CalendarDatePicker(
        initialDate: selectedDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 1),
        onDateChanged: onChanged,
      ),
    );
  }
}

class _SourceField extends StatelessWidget {
  const _SourceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kaynak / Kitap',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.of(context).textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Örn: Soru Bankası, Çıkmış Sorular, Ders Notu',
          ),
        ),
      ],
    );
  }
}

class _TopicSelector extends StatelessWidget {
  const _TopicSelector({
    required this.topics,
    required this.selected,
    required this.onSelect,
  });

  final List<TopicSummary> topics;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: topics.map((topic) {
        final active = topic.title == selected;
        return GestureDetector(
          onTap: () => onSelect(topic.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.of(context).primary.withOpacity(0.2)
                  : AppColors.of(context).subtleFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? AppColors.of(context).primary
                    : AppColors.of(context).subtleFill,
              ),
            ),
            child: Text(
              topic.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: active
                        ? AppColors.of(context).primary
                        : AppColors.of(context).textSecondary,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ResultPicker extends StatelessWidget {
  const _ResultPicker({
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.onChanged,
  });

  final int correct;
  final int wrong;
  final int blank;
  final void Function(int, int, int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CounterRow(
          label: 'Doğru',
          value: correct,
          color: AppColors.of(context).success,
          onChanged: (value) => onChanged(value, wrong, blank),
        ),
        const SizedBox(height: 12),
        _CounterRow(
          label: 'Yanlış',
          value: wrong,
          color: AppColors.of(context).danger,
          onChanged: (value) => onChanged(correct, value, blank),
        ),
        const SizedBox(height: 12),
        _CounterRow(
          label: 'Boş',
          value: blank,
          color: AppColors.of(context).warning,
          onChanged: (value) => onChanged(correct, wrong, value),
        ),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).textPrimary,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: () => onChanged(max(0, value - 1)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final controller = TextEditingController(text: value.toString());
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sayı Gir'),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Miktar girin'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                  if (result != null) onChanged(result);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).subtleFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CounterButton(
                icon: Icons.add,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.of(context).subtleFill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.of(context).textSecondary, size: 18),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: AppColors.of(context).primary),
          const SizedBox(width: 10),
          Text(
            'Süre',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.of(context).textPrimary,
                ),
          ),
          const Spacer(),
          _CounterButton(
            icon: Icons.remove,
            onTap: () => onChanged(max(0, minutes - 5)),
          ),
          const SizedBox(width: 8),
          Text(
            '$minutes dk',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          _CounterButton(
            icon: Icons.add,
            onTap: () => onChanged(minutes + 5),
          ),
        ],
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.selectedDate,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Row(
          children: [
            Icon(Icons.event, color: AppColors.of(context).primary),
            const SizedBox(width: 10),
            Text(
              'Tarih',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.of(context).textPrimary,
                  ),
            ),
            const Spacer(),
            Text(
              '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, color: AppColors.of(context).textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ExamSubjectBreakdown extends StatelessWidget {
  const _ExamSubjectBreakdown({
    required this.subjects,
    required this.onNetChanged,
    required this.onMinutesChanged,
  });

  final List<String> subjects;
  final void Function(String subject, double value) onNetChanged;
  final void Function(String subject, int value) onMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subjects
          .map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.of(context).border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.of(context).textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: TextField(
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Net',
                        ),
                        onChanged: (value) {
                          final parsed =
                              double.tryParse(value.replaceAll(',', '.'));
                          if (parsed != null) {
                            onNetChanged(subject, parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'dk',
                        ),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            onMinutesChanged(subject, parsed);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ErrorTagSelector extends StatelessWidget {
  const _ErrorTagSelector({
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  final List<String> tags;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...tags.map(
          (tag) => InkWell(
            onTap: () => onToggle(tag),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected.contains(tag)
                    ? AppColors.of(context).primary.withOpacity(0.18)
                    : AppColors.of(context).subtleFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected.contains(tag)
                      ? AppColors.of(context).primary
                      : AppColors.of(context).subtleFill,
                ),
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected.contains(tag) ? AppColors.of(context).textPrimary : AppColors.of(context).textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final controller = TextEditingController();
            final newTag = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Yeni Etiket'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Etiket adı'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                    child: const Text('Ekle'),
                  ),
                ],
              ),
            );
            if (newTag != null && newTag.isNotEmpty) {
              onToggle(newTag);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.of(context).subtleFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.of(context).border),
            ),
            child: Icon(Icons.add, size: 16, color: AppColors.of(context).textSecondary),
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'Not ekle (opsiyonel)',
      ),
    );
  }
}

void _navigateFromNav(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
      return;
    case 1:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TopicSummariesScreen()),
      );
      return;
    case 2:
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
