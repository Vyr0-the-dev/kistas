import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../models/topic_summary.dart';
import '../services/app_repository.dart';
import '../services/gemini_client.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_loading_dialog.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import '../widgets/in_app_notice.dart';
import 'analysis_screen.dart';
import 'entry_wizard_screen.dart';
import 'home_screen.dart';
import 'topic_detail_screen.dart';
import 'topic_summaries_screen.dart';

class QuickAddScreen extends StatelessWidget {
  const QuickAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final topics = repository.topics;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: ValueListenableBuilder<List<QuestionEntry>>(
          valueListenable: repository.questionEntries,
          builder: (context, questionEntries, _) {
            return ValueListenableBuilder<List<MockExam>>(
              valueListenable: repository.mockExams,
              builder: (context, mockExams, __) {
                final recentEntry = questionEntries.isNotEmpty
                    ? questionEntries.last
                    : null;
                final recentExam =
                    mockExams.isNotEmpty ? mockExams.last : null;
                final todayItems = _buildTodayItems(
                  context,
                  questionEntries,
                  mockExams,
                );

                return Stack(
                  children: [
                    const _AmbientOrbs(),
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Header(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: _AiSmartAddButton(
                              onTap: () => _openSmartAdd(context),
                            ),
                          ),
                          SizedBox(height: 14),
                          _ActionCards(
                            onQuestionAdd: () => _openEntry(
                              context,
                              EntryType.question,
                            ),
                            onExamAdd: () => _openEntry(
                              context,
                              EntryType.mockExam,
                            ),
                          ),
                          SizedBox(height: 18),
                      _SectionHeader(
                        title: 'Hızlı Seçimler',
                        actionLabel: 'Tümü',
                        onAction: () => _showQuickSelectionsSheet(
                          context,
                          questionEntries,
                          mockExams,
                          topics,
                        ),
                      ),
                          SizedBox(height: 8),
                          _SuggestionsRow(
                            recentEntry: recentEntry,
                            recentExam: recentExam,
                            onQuestionTap: (entry) =>
                                _openQuestionFromEntry(context, entry, topics),
                            onExamTap: (exam) => _openExamFromEntry(
                              context,
                              exam,
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Bugün',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _TodayList(items: todayItems),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: 2,
        onSelect: (index) => _navigateFromNav(context, index),
      ),
    );
  }

  void _openEntry(BuildContext context, EntryType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EntryWizardScreen(type: type),
      ),
    );
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
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        return;
    }
  }
}

class _AiSmartAddButton extends StatelessWidget {
  const _AiSmartAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.of(context).primary.withOpacity(0.8),
              AppColors.of(context).primary.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onPrimary),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Hızlı Ekle',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '"Bugün matematikten 30 soru çözdüm..."',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

Future<void> _openSmartAdd(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('AI ile Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Çalışmanı doğal dille anlat, AI verileri ayıklayıp forma doldursun.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Örn: Tarih çalışmamda 40 soru çözdüm, 35 doğru 5 yanlış çıktı. 50 dakika sürdü.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(controller.text),
            icon: Icon(Icons.auto_awesome),
            label: Text('Analiz Et'),
          ),
        ],
      );
    },
  );

  if (result == null || result.trim().isEmpty) {
    return;
  }

  final repository = AppRepositoryScope.of(context);
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  final closeLoading = _showLoadingDialog(context, 'Veriler işleniyor...');

  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;

    final prompt = '''
Extract study data from this text into JSON: "$result".
JSON Schema:
{
  "topic": "string (infer closest topic name, e.g. Matematik, Tarih, Coğrafya)",
  "total": int (total questions),
  "correct": int (if mentioned),
  "wrong": int (if mentioned),
  "blank": int (if mentioned),
  "minutes": int (duration in minutes)
}
If 'total' is missing but correct/wrong are present, sum them. If 'correct' is missing but total/wrong are present, calculate it.
Return ONLY raw JSON.
''';

    final response = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );

    await repository.incrementAiRequestCount();
    
    closeLoading();

    if (!context.mounted) return;
    // Navigator.of(context).pop(); // Close loading

    final data = _parseAiJson(response);
    if (data == null) {
      _showSnack(context, 'Veri çıkarılamadı. Lütfen tekrar dene.');
      return;
    }

    // Try to match topic
    final topics = repository.topics;
    TopicSummary? matchedTopic;
    if (data['topic'] != null) {
      final topicName = data['topic'].toString().toLowerCase();
      try {
        matchedTopic = topics.firstWhere(
          (t) => t.title.toLowerCase().contains(topicName) || t.subject.toLowerCase().contains(topicName),
        );
      } catch (_) {}
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryWizardScreen(
          type: EntryType.question,
          preselectedTopic: matchedTopic,
          initialData: {
            'total': data['total'] ?? 0,
            'correct': data['correct'] ?? 0,
            'wrong': data['wrong'] ?? 0,
            'blank': data['blank'] ?? 0,
            'minutes': data['minutes'] ?? 0,
          },
        ),
      ),
    );

  } catch (e) {
    closeLoading();
    if (!context.mounted) return;
    // Navigator.of(context).pop();
    _showSnack(context, 'Bir hata oluştu: $e');
  }
}

Map<String, dynamic>? _parseAiJson(String raw) {
  try {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
    if (match == null) return null;
    return jsonDecode(match.group(0)!);
  } catch (_) {
    return null;
  }
}

void _showSnack(BuildContext context, String message) {
  InAppNotice.show(context, message);
}

Future<void> Function() _showLoadingDialog(BuildContext context, String title) {
  bool isOpen = true;
  AiLoadingDialog.show(context, status: title).then((_) => isOpen = false);
  return () async {
    if (isOpen && context.mounted) {
      Navigator.of(context).pop();
    }
  };
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş geldin, Öğrenci',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Bugünkü hedeflerini\ntamamla.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionCards extends StatelessWidget {
  const _ActionCards({
    required this.onQuestionAdd,
    required this.onExamAdd,
  });

  final VoidCallback onQuestionAdd;
  final VoidCallback onExamAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _QuickCard(
              title: 'Soru\nEkle',
              subtitle: 'Konu ve soru sayısı gir',
              icon: Icons.edit_note,
              accent: AppColors.of(context).primary,
              onTap: onQuestionAdd,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: _QuickCard(
              title: 'Deneme\nEkle',
              subtitle: 'Net ve puan hesapla',
              icon: Icons.timer,
              accent: AppColors.of(context).primaryLight,
              onTap: onExamAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(24),
        child: SizedBox(
          height: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: TextStyle(color: AppColors.of(context).primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  const _SuggestionsRow({
    required this.recentEntry,
    required this.recentExam,
    required this.onQuestionTap,
    required this.onExamTap,
  });

  final QuestionEntry? recentEntry;
  final MockExam? recentExam;
  final ValueChanged<QuestionEntry> onQuestionTap;
  final ValueChanged<MockExam> onExamTap;

  @override
  Widget build(BuildContext context) {
    final items = <_SuggestionItem>[];
    if (recentEntry != null) {
      items.add(
        _SuggestionItem(
          title: recentEntry!.topic.isEmpty
              ? 'Son Çalışılan'
              : recentEntry!.topic,
          subtitle: recentEntry!.subject.isEmpty
              ? 'Devam et'
              : recentEntry!.subject,
          label: 'Son Çalışılan',
          accent: AppColors.of(context).primary,
          onTap: () => onQuestionTap(recentEntry!),
        ),
      );
    }
    if (recentExam != null) {
      items.add(
        _SuggestionItem(
          title: recentExam!.title.isEmpty
              ? 'Son Deneme'
              : recentExam!.title,
          subtitle: '${recentExam!.totalNet.toStringAsFixed(1)} net',
          label: 'Son Deneme',
          accent: AppColors.of(context).primaryLight,
          onTap: () => onExamTap(recentExam!),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        const _SuggestionItem(
          title: 'Henüz kayıt yok',
          subtitle: 'İlk kaydın burada görünecek.',
          label: 'Başlangıç',
          accent: Colors.white54,
          onTap: null,
        ),
      );
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _SuggestionCard(
          item: items[index],
        ),
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _SuggestionItem {
  const _SuggestionItem({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String label;
  final Color accent;
  final VoidCallback? onTap;
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.item});

  final _SuggestionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_awesome, color: item.accent),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: item.accent,
                          letterSpacing: 1,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.of(context).primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.items});

  final List<_TodayItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        radius: BorderRadius.circular(18),
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bugün henüz kayıt yok.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              )
            : Column(
                children: items
                    .map(
                      (item) => _TodayTile(item: item),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

enum _TodayItemType { question, exam }

class _TodayItem {
  _TodayItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.accent,
    required this.timestamp,
    required this.type,
    this.questionEntry,
    this.mockExam,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final Color accent;
  final DateTime timestamp;
  final _TodayItemType type;
  final QuestionEntry? questionEntry;
  final MockExam? mockExam;
}

class _TodayTile extends StatelessWidget {
  const _TodayTile({required this.item});

  final _TodayItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTodayDetailSheet(context, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.accent, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              item.timeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                  ),
            ),
          ],
        ),
      ),
    );
  }
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

class _AmbientOrbs extends StatelessWidget {
  const _AmbientOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: -30,
            child: _Orb(color: AppColors.of(context).primaryLight, size: 96),
          ),
          Positioned(
            bottom: 140,
            left: -20,
            child: _Orb(color: AppColors.of(context).primary, size: 110),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: SizedBox.shrink(),
      ),
    );
  }
}

List<_TodayItem> _buildTodayItems(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
) {
  final now = DateTime.now();
  final items = <_TodayItem>[];

  for (final entry in questionEntries) {
    if (_isSameDay(entry.createdAt, now)) {
      items.add(
        _TodayItem(
          title: entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic,
          subtitle: '${entry.total} soru çözüldü',
          timeLabel: _formatTime(entry.createdAt),
          icon: Icons.school,
          accent: AppColors.of(context).primary,
          timestamp: entry.createdAt,
          type: _TodayItemType.question,
          questionEntry: entry,
        ),
      );
    }
  }

  for (final exam in mockExams) {
    if (_isSameDay(exam.createdAt, now)) {
      items.add(
        _TodayItem(
          title: exam.title.isEmpty ? 'Deneme' : exam.title,
          subtitle: '${exam.totalNet.toStringAsFixed(1)} net',
          timeLabel: _formatTime(exam.createdAt),
          icon: Icons.assignment,
          accent: AppColors.of(context).primaryLight,
          timestamp: exam.createdAt,
          type: _TodayItemType.exam,
          mockExam: exam,
        ),
      );
    }
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

void _openQuestionFromEntry(
  BuildContext context,
  QuestionEntry entry,
  List<TopicSummary> topics,
) {
  final matched = _findTopic(topics, entry);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => EntryWizardScreen(
        type: EntryType.question,
        preselectedTopic: matched,
      ),
    ),
  );
}

void _openExamFromEntry(BuildContext context, MockExam exam) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const EntryWizardScreen(type: EntryType.mockExam),
    ),
  );
}

TopicSummary? _findTopic(List<TopicSummary> topics, QuestionEntry entry) {
  for (final topic in topics) {
    if (topic.title == entry.topic &&
        (entry.subject.isEmpty || topic.subject == entry.subject)) {
      return topic;
    }
  }
  return null;
}

void _showQuickSelectionsSheet(
  BuildContext context,
  List<QuestionEntry> questionEntries,
  List<MockExam> mockExams,
  List<TopicSummary> topics,
) {
  final recentQuestions = [...questionEntries]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final recentExams = [...mockExams]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Hızlı Seçimler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Soru Ekle',
                        icon: Icons.edit_note,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EntryWizardScreen(
                                type: EntryType.question,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Deneme Ekle',
                        icon: Icons.timer,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EntryWizardScreen(
                                type: EntryType.mockExam,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _QuickSectionTitle(title: 'Son Soru Kayıtları'),
                if (recentQuestions.isEmpty)
                  _EmptyHint(text: 'Henüz soru kaydı yok.')
                else
                  ...recentQuestions.take(6).map(
                        (entry) => _QuickSelectionTile(
                          title: entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic,
                          subtitle: '${entry.subject} • ${entry.total} soru',
                          trailing: _formatTime(entry.createdAt),
                          icon: Icons.school,
                          accent: AppColors.of(context).primary,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openQuestionFromEntry(context, entry, topics);
                          },
                        ),
                      ),
                SizedBox(height: 18),
                _QuickSectionTitle(title: 'Son Denemeler'),
                if (recentExams.isEmpty)
                  _EmptyHint(text: 'Henüz deneme kaydı yok.')
                else
                  ...recentExams.take(6).map(
                        (exam) => _QuickSelectionTile(
                          title: exam.title.isEmpty ? 'Deneme' : exam.title,
                          subtitle:
                              '${exam.totalNet.toStringAsFixed(1)} net • ${exam.minutes} dk',
                          trailing: _formatTime(exam.createdAt),
                          icon: Icons.assignment,
                          accent: AppColors.of(context).primaryLight,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openExamFromEntry(context, exam);
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.of(context).primary),
            SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSectionTitle extends StatelessWidget {
  const _QuickSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
            ),
      ),
    );
  }
}

class _QuickSelectionTile extends StatelessWidget {
  const _QuickSelectionTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),
        trailing: Text(
          trailing,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white38,
              ),
        ),
      ),
    );
  }
}

void _showTodayDetailSheet(BuildContext context, _TodayItem item) {
  final repository = AppRepositoryScope.of(context);
  final topics = repository.topics;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6),
                Text(
                  '${item.subtitle} • ${item.timeLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
                SizedBox(height: 16),
                if (item.type == _TodayItemType.question &&
                    item.questionEntry != null)
                  _QuestionDetailBlock(
                    entry: item.questionEntry!,
                    onOpenTopic: () {
                      final matched =
                          _findTopic(topics, item.questionEntry!);
                      if (matched == null) {
                        return;
                      }
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TopicDetailScreen(topic: matched),
                        ),
                      );
                    },
                  ),
                if (item.type == _TodayItemType.exam && item.mockExam != null)
                  _ExamDetailBlock(exam: item.mockExam!),
              ],
            ),
          );
        },
      );
    },
  );
}

class _QuestionDetailBlock extends StatelessWidget {
  const _QuestionDetailBlock({
    required this.entry,
    required this.onOpenTopic,
  });

  final QuestionEntry entry;
  final VoidCallback onOpenTopic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DetailStat(label: 'Doğru', value: entry.correct.toString()),
            _DetailStat(label: 'Yanlış', value: entry.wrong.toString()),
            _DetailStat(label: 'Boş', value: entry.blank.toString()),
            _DetailStat(label: 'Süre', value: '${entry.minutes} dk'),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onOpenTopic,
                child: Text('Konu Analizi'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EntryWizardScreen(
                        type: EntryType.question,
                        preselectedTopic: _findTopic(
                          AppRepositoryScope.of(context).topics,
                          entry,
                        ),
                      ),
                    ),
                  );
                },
                child: Text('Soru Ekle'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExamDetailBlock extends StatelessWidget {
  const _ExamDetailBlock({required this.exam});

  final MockExam exam;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DetailStat(label: 'Net', value: exam.totalNet.toStringAsFixed(1)),
            _DetailStat(label: 'Doğru', value: exam.correct.toString()),
            _DetailStat(label: 'Yanlış', value: exam.wrong.toString()),
            _DetailStat(label: 'Boş', value: exam.blank.toString()),
            _DetailStat(label: 'Süre', value: '${exam.minutes} dk'),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AnalysisScreen()),
              );
            },
            child: Text('Analize Git'),
          ),
        ),
      ],
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          SizedBox(height: 4),
          Text(
            value,
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
