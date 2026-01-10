import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/models/mock_exam.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/in_app_notice.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../dashboard/screens/home_screen.dart';
import '../../settings/screens/profile_screen.dart';
import 'topic_summaries_screen.dart';

enum EntryType { question, mockExam }

class EntryWizardScreen extends StatefulWidget {
  const EntryWizardScreen({
    super.key,
    required this.type,
    this.preselectedTopic,
    this.initialData,
  });

  final EntryType type;
  final TopicSummary? preselectedTopic;
  final Map<String, dynamic>? initialData;

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
  final Map<String, double> _examSubjectNets = {};
  final Map<String, int> _examSubjectMinutes = {};
  final Set<String> _errorTags = {};
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();

  static const List<String> _examSubjects = [
    'Türkçe',
    'Matematik',
    'Tarih',
    'Coğrafya',
    'Vatandaşlık',
    'Güncel Bilgiler',
  ];

  static const List<String> _errorTagOptions = [
    'İşlem Hatası',
    'Dikkat',
    'Bilgi Eksikliği',
    'Süre',
  ];

  static const List<String> _examTypes = [
    'Genel Deneme',
    'Branş Denemesi',
    'Türkiye Geneli',
    'Çıkmış Sorular',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedTopic != null) {
      _selectedSubject = widget.preselectedTopic!.subject;
      _selectedTopic = widget.preselectedTopic!.title;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final subjects = repository.topics.map((e) => e.subject).toSet().toList();
    final topics = repository.topics
        .where((item) =>
            _selectedSubject.isEmpty || item.subject == _selectedSubject)
        .toList();

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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(subjects, topics),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _BottomActions(
        isLastStep: _currentStep == 3,
        onNext: _nextStep,
        onBack: _backStep,
        onSave: () => _save(repository),
        onSaveAndAdd: () => _save(repository, keepOpen: true),
      ),
      bottomNavigationBar: AppBottomNav(
        activeIndex: 2,
        onSelect: (index) => _navigateFromNav(context, index),
      ),
    );
  }

  Widget _buildStepContent(List<String> subjects, List<TopicSummary> topics) {
    if (widget.type == EntryType.question) {
      switch (_currentStep) {
        case 0:
          return Column(
            key: const ValueKey(0),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 1, title: 'Ders seç'),
              _SubjectGrid(
                subjects: subjects,
                selected: _selectedSubject,
                onSelect: (value) {
                  setState(() => _selectedSubject = value);
                  _nextStep();
                },
              ),
            ],
          );
        case 1:
          return Column(
            key: const ValueKey(1),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 2, title: 'Konu belirle'),
              _TopicSelector(
                topics: topics,
                selected: _selectedTopic,
                onSelect: (value) {
                  setState(() => _selectedTopic = value);
                  _nextStep();
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
              _DurationPicker(
                minutes: _minutes,
                onChanged: (value) => setState(() => _minutes = value),
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
              const Text(
                'Yanlış Türleri',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
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
              _DatePickerRow(
                selectedDate: _selectedDate,
                onPickDate: _pickDate,
              ),
              const SizedBox(height: 20),
              const Text(
                'Notlar',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _NoteField(controller: _noteController),
            ],
          );
      }
    } else {
      // Mock Exam steps
      switch (_currentStep) {
        case 0:
          return Column(
            key: const ValueKey(0),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 1, title: 'Deneme türü seç'),
              _SubjectGrid(
                subjects: _examTypes,
                selected: _titleController.text,
                onSelect: (value) {
                  setState(() => _titleController.text = value);
                  _nextStep();
                },
              ),
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
                child: Text(
                  '${(_correct - (_wrong / 4)).toStringAsFixed(2)} Net',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.of(context).primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              _DurationPicker(
                minutes: _minutes,
                onChanged: (value) => setState(() => _minutes = value),
              ),
            ],
          );
        case 3:
          return Column(
            key: const ValueKey(3),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(index: 4, title: 'Detaylar'),
              const Text(
                'Ders Dağılımı (Opsiyonel)',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _ExamSubjectBreakdown(
                subjects: _examSubjects,
                onNetChanged: (subject, value) {
                  setState(() => _examSubjectNets[subject] = value);
                },
                onMinutesChanged: (subject, value) {
                  setState(() => _examSubjectMinutes[subject] = value);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Notlar',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
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
      _selectedDate = DateTime.now();
      _examSubjectNets.clear();
      _examSubjectMinutes.clear();
      _errorTags.clear();
    });
    _titleController.clear();
    _noteController.clear();
    _bookController.clear();
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
        ),
      );
    } else {
      final title = _titleController.text.trim();
      await repository.addMockExam(
        MockExam(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.isEmpty ? 'Deneme' : title,
          dateLabel: _formatDate(_selectedDate),
          correct: _correct,
          wrong: _wrong,
          blank: _blank,
          totalNet: _correct - (_wrong / 4),
          minutes: _minutes,
          note: _noteController.text.trim(),
          createdAt: createdAt,
          subjectNets: Map<String, double>.from(_examSubjectNets)
            ..removeWhere((_, value) => value <= 0),
          subjectMinutes: Map<String, int>.from(_examSubjectMinutes)
            ..removeWhere((_, value) => value <= 0),
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
                  : Colors.white.withOpacity(0.1),
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
    required this.isLastStep,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onSaveAndAdd,
  });

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
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (!isLastStep)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Geri'),
                  ),
                ),
              if (!isLastStep) const SizedBox(width: 12),
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
            icon: Icon(Icons.close, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
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
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              index.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
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
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book,
                      color: active ? AppColors.of(context).primary : Colors.white54),
                ),
                const Spacer(),
                Text(
                  subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                color: Colors.white54,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Örn: Yediiklim Türkçe SB',
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
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? AppColors.of(context).primary
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Text(
              topic.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: active ? Colors.white : Colors.white70,
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                      color: Colors.white,
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
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: AppColors.of(context).primary),
          const SizedBox(width: 10),
          Text(
            'Süre',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
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
                  color: Colors.white,
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(Icons.event, color: AppColors.of(context).primary),
            const SizedBox(width: 10),
            Text(
              'Tarih',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const Spacer(),
            Text(
              '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, color: Colors.white54),
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
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
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
      children: tags
          .map(
            (tag) => InkWell(
              onTap: () => onToggle(tag),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected.contains(tag)
                      ? AppColors.of(context).primary.withOpacity(0.18)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected.contains(tag)
                        ? AppColors.of(context).primary
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected.contains(tag)
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          )
          .toList(),
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