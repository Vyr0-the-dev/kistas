import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/models/mock_exam.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/gemini_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_loading_dialog.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/delete_helpers.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/in_app_notice.dart';
import '../../analysis/screens/analysis_screen.dart';
import 'entry_wizard_screen.dart';
import '../../dashboard/screens/home_screen.dart';
import 'topic_detail_screen.dart';
import 'topic_summaries_screen.dart';

class QuickAddScreen extends StatelessWidget {
  const QuickAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final topics = repository.topics;
    return SafeArea(
      child: ValueListenableBuilder<List<QuestionEntry>>(
        valueListenable: repository.questionEntries,
        builder: (context, questionEntries, _) {
          return ValueListenableBuilder<List<MockExam>>(
            valueListenable: repository.mockExams,
            builder: (context, mockExams, __) {
              final recentEntry = questionEntries.isNotEmpty
                  ? questionEntries.first
                  : null;
              final recentExam =
                  mockExams.isNotEmpty ? mockExams.first : null;
              final todayItems = _buildTodayItems(
                context,
                questionEntries,
                mockExams,
              );

              return SingleChildScrollView(
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
                              color: AppColors.of(context).textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _TodayList(items: todayItems),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openEntry(BuildContext context, EntryType type) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => EntryWizardScreen(type: type),
      ),
    );
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
              AppColors.of(context).primary,
              AppColors.of(context).primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).primary.withValues(alpha: 0.24),
              blurRadius: 14,
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
              style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13),
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
        ? 'gemini-1.5-flash-latest'
        : repository.geminiModel.value;

    final activeSubjects = repository.subjectsForTag(null);
    final activeTags = repository.availableTags;
    final prompt = '''
Extract study data from this text into JSON: "$result".
User's known subjects: ${activeSubjects.isEmpty ? 'Any' : activeSubjects.join(', ')}
User's known exam/category tags: ${activeTags.isEmpty ? 'Genel' : activeTags.join(', ')}
JSON Schema:
{
  "topic": "string (infer closest topic or subject name from user's known subjects or text)",
  "tag": "string (infer exam/category tag if mentioned or matching user's tags. Default to 'Genel')",
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
    final inferredTag = data['tag']?.toString().toLowerCase() ?? 'genel';
    
    if (data['topic'] != null) {
      final topicName = data['topic'].toString().toLowerCase();
      try {
        // Hem isme hem etikete göre en yakın eşleşmeyi bul
        matchedTopic = topics.firstWhere(
          (t) => (t.title.toLowerCase().contains(topicName) || t.subject.toLowerCase().contains(topicName)) &&
                 (t.tag.toLowerCase() == inferredTag),
        );
      } catch (_) {
        // Etiket tutmazsa sadece isme göre son bir şans
        try {
          matchedTopic = topics.firstWhere(
            (t) => t.title.toLowerCase().contains(topicName) || t.subject.toLowerCase().contains(topicName),
          );
        } catch (_) {}
      }
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
    final repository = AppRepositoryScope.of(context);
    return ValueListenableBuilder<String>(
      valueListenable: repository.userName,
      builder: (context, name, _) {
        final greeting =
            name.trim().isEmpty ? 'Çalışmaya hazır mısın?' : 'Hoş geldin, $name';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.of(context).textSecondary,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bugünkü hedeflerini\ntamamla.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.of(context).textPrimary,
                    ),
              ),
            ],
          ),
        );
      },
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
          height: 136,
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
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.of(context).textSecondary,
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
                  color: AppColors.of(context).textPrimary,
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
          title: recentEntry!.bookName.isNotEmpty
              ? recentEntry!.bookName
              : (recentEntry!.topic.isEmpty ? 'Son Çalışılan' : recentEntry!.topic),
          subtitle: recentEntry!.bookName.isNotEmpty
              ? '${recentEntry!.subject} • ${recentEntry!.topic}'
              : (recentEntry!.subject.isEmpty ? 'Devam et' : recentEntry!.subject),
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
          subtitle:
              '${recentExam!.scopeSummary} • ${recentExam!.totalNet.toStringAsFixed(1)} net',
          label: 'Son Deneme',
          accent: AppColors.of(context).primaryLight,
          onTap: () => onExamTap(recentExam!),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        _SuggestionItem(
          title: 'Henüz kayıt yok',
          subtitle: 'İlk kaydın burada görünecek.',
          label: 'Başlangıç',
          accent: AppColors.of(context).textSecondary,
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
          border: Border.all(color: AppColors.of(context).border),
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
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.of(context).textSecondary,
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
                        color: AppColors.of(context).textSecondary,
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
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.of(context).border),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.of(context).textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              item.timeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.of(context).textMuted,
                  ),
            ),
            IconButton(
              tooltip: 'Kaydı Sil',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.delete_outline,
                size: 19,
                color: AppColors.of(context).textMuted,
              ),
              onPressed: () {
                if (item.questionEntry != null) {
                  deleteQuestionEntryWithUndo(context, item.questionEntry!);
                } else if (item.mockExam != null) {
                  deleteMockExamWithUndo(context, item.mockExam!);
                }
              },
            ),
          ],
        ),
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
      final hasBook = entry.bookName.isNotEmpty;
      items.add(
        _TodayItem(
          title: hasBook
              ? entry.bookName
              : (entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic),
          subtitle: hasBook
              ? '${entry.subject} • ${entry.topic} • ${entry.total} soru'
              : '${entry.total} soru çözüldü',
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
          subtitle:
              '${exam.scopeSummary} • ${exam.totalNet.toStringAsFixed(1)} net',
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
  Navigator.of(context, rootNavigator: true).push(
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
  List<QuestionEntry> _,
  List<MockExam> __,
  List<TopicSummary> topics,
) {
  final repository = AppRepositoryScope.of(context);

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
          return ValueListenableBuilder<List<QuestionEntry>>(
            valueListenable: repository.questionEntries,
            builder: (context, liveQuestions, _) {
              return ValueListenableBuilder<List<MockExam>>(
                valueListenable: repository.mockExams,
                builder: (context, liveExams, __) {
                  final recentQuestions = [...liveQuestions]
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  final recentExams = [...liveExams]
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.of(context).surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: AppColors.of(context).subtleFill,
                      ),
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
                              color: AppColors.of(context).subtleFill,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Hızlı Seçimler',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppColors.of(context).textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                label: 'Soru Ekle',
                                icon: Icons.edit_note,
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (_) => const EntryWizardScreen(
                                        type: EntryType.question,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                label: 'Deneme Ekle',
                                icon: Icons.timer,
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
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
                        const SizedBox(height: 20),
                        const _QuickSectionTitle(title: 'Son Soru Kayıtları'),
                        if (recentQuestions.isEmpty)
                          const _EmptyHint(text: 'Henüz soru kaydı yok.')
                        else
                          ...recentQuestions.take(10).map(
                            (entry) {
                              final hasBook = entry.bookName.isNotEmpty;
                              return _QuickSelectionTile(
                                title: hasBook
                                    ? entry.bookName
                                    : (entry.topic.isEmpty
                                        ? 'Soru Kaydı'
                                        : entry.topic),
                                subtitle: hasBook
                                    ? '${entry.subject} • ${entry.topic} • ${entry.total} soru'
                                    : '${entry.subject} • ${entry.total} soru',
                                trailing: _formatTime(entry.createdAt),
                                icon: Icons.school,
                                accent: AppColors.of(context).primary,
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  _openQuestionFromEntry(
                                    context,
                                    entry,
                                    topics,
                                  );
                                },
                                onDelete: () =>
                                    deleteQuestionEntryWithUndo(context, entry),
                              );
                            },
                          ),
                        const SizedBox(height: 18),
                        const _QuickSectionTitle(title: 'Son Denemeler'),
                        if (recentExams.isEmpty)
                          const _EmptyHint(text: 'Henüz deneme kaydı yok.')
                        else
                          ...recentExams.take(10).map(
                            (exam) => _QuickSelectionTile(
                              title:
                                  exam.title.isEmpty ? 'Deneme' : exam.title,
                              subtitle:
                                  '${exam.scopeSummary} • ${exam.totalNet.toStringAsFixed(1)} net • ${exam.minutes} dk',
                              trailing: _formatTime(exam.createdAt),
                              icon: Icons.assignment,
                              accent: AppColors.of(context).primaryLight,
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                _openExamFromEntry(context, exam);
                              },
                              onDelete: () =>
                                  deleteMockExamWithUndo(context, exam),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
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
          color: AppColors.of(context).subtleFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.of(context).primary),
            SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.of(context).textPrimary,
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
              color: AppColors.of(context).textSecondary,
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
              color: AppColors.of(context).textSecondary,
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
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.of(context).subtleFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(14, 2, 8, 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.of(context).textSecondary,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailing,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.of(context).textMuted,
                  ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'Kaydı Sil',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: Colors.redAccent,
                ),
                onPressed: onDelete,
              ),
            ],
          ],
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
              border: Border.all(color: AppColors.of(context).border),
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
                      color: AppColors.of(context).subtleFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.subtitle} • ${item.timeLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
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
                    onDelete: () async {
                      final deleted = await deleteQuestionEntryWithUndo(
                        context,
                        item.questionEntry!,
                      );
                      if (deleted && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                if (item.type == _TodayItemType.exam && item.mockExam != null)
                  _ExamDetailBlock(
                    exam: item.mockExam!,
                    onDelete: () async {
                      final deleted = await deleteMockExamWithUndo(
                        context,
                        item.mockExam!,
                      );
                      if (deleted && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
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
    required this.onDelete,
  });

  final QuestionEntry entry;
  final VoidCallback onOpenTopic;
  final VoidCallback onDelete;

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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onOpenTopic,
                child: const Text('Konu Analizi'),
              ),
            ),
            const SizedBox(width: 12),
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
                child: const Text('Soru Ekle'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.45)),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Kaydı Sil'),
          ),
        ),
      ],
    );
  }
}

class _ExamDetailBlock extends StatelessWidget {
  const _ExamDetailBlock({
    required this.exam,
    required this.onDelete,
  });

  final MockExam exam;
  final VoidCallback onDelete;

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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: AppColors.of(context).background,
                    body: const AnalysisScreen(),
                  ),
                ),
              );
            },
            child: const Text('Analize Git'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.45)),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Denemeyi Sil'),
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
        color: AppColors.of(context).subtleFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
          ),
          SizedBox(height: 4),
          Text(
            value,
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
