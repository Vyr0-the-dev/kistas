import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/flashcard.dart';
import '../models/question_entry.dart';
import '../models/topic_summary.dart';
import '../services/app_repository.dart';
import '../services/gemini_client.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_loading_dialog.dart';
import '../widgets/ai_response_dialog.dart';
import '../widgets/ambient_background.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import '../widgets/in_app_notice.dart';
import '../widgets/progress_ring.dart';
import 'analysis_screen.dart';
import 'entry_wizard_screen.dart';
import 'flashcard_study_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'quick_add_screen.dart';
import 'topic_summaries_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key, required this.topic});

  final TopicSummary topic;

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return ValueListenableBuilder<Map<String, TopicSummary>>(
      valueListenable: repository.customTopics,
      builder: (context, customMap, _) {
        final currentTopic = customMap[topic.id] ?? topic;
        final entries = repository.entriesForTopic(currentTopic.title);
        final progress = TopicProgress.fromEntries(currentTopic, entries);

        return Scaffold(
          backgroundColor: AppColors.of(context).background,
          body: AmbientBackground(
            child: Column(
              children: [
                _Header(topic: currentTopic),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Hero(progress: progress),
                        SizedBox(height: 16),
                        _KpiRow(progress: progress),
                        SizedBox(height: 12),
                                            _MasteryCard(
                                              mastery: _calculateMastery(progress),
                                              lastStudied: progress.lastStudied,
                                            ),
                                            SizedBox(height: 16),
                                                                _NotesSection(
                                                                  topic: currentTopic,
                                                                  onDeleteInsight: (id) async {
                                                                    final updated = currentTopic.copyWith(
                                                                      aiInsights: currentTopic.aiInsights
                                                                          .where((e) => e.id != id)
                                                                          .toList(),
                                                                    );
                                                                    await repository.saveTopicUpdate(updated);
                                                                  },
                                                                  onClearMainNotes: () async {
                                                                    await repository.deleteTopicUpdate(currentTopic.id);
                                                                  },
                                                                ),
                                            
                                            SizedBox(height: 16),
                        
                        _TrendCard(entries: entries),
                        SizedBox(height: 16),
                        _MistakeSection(entries: entries),
                        SizedBox(height: 18),
                        _ActionButtons(topic: currentTopic),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNav(),
        );
      },
    );
  }
}

enum _TrendRange { week, month }

enum _MistakeFilter { all, wrongOnly, blankOnly }

class _Header extends StatelessWidget {
  const _Header({required this.topic});

  final TopicSummary topic;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      radius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: Colors.white70),
              ),
              const Spacer(),
              Text(
                topic.subject.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showMoreActions(context, topic),
                icon: Icon(Icons.more_horiz, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.progress});

  final TopicProgress progress;

  @override
  Widget build(BuildContext context) {
    final lastStudied = progress.lastStudied;
    final score = (progress.accuracy * 100).round();
    final mastery = _calculateMastery(progress);
    final label = lastStudied == null
        ? 'Henüz çalışma yok'
        : 'Son çalışma: ${_formatShortDate(lastStudied)}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.of(context).primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.of(context).primary.withOpacity(0.3)),
                ),
                child: Text(
                  'Konu Analizi',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.of(context).primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    progress.topic.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (progress.topic.importance >= 4) ...[
                    SizedBox(width: 8),
                    Icon(Icons.local_fire_department,
                        color: Colors.orangeAccent, size: 28),
                  ],
                ],
              ),
              SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        _RingScore(score: mastery, label: 'HAKİMİYET'),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.topic,
    required this.onDeleteInsight,
    required this.onClearMainNotes,
  });

  final TopicSummary topic;
  final Function(String) onDeleteInsight;
  final VoidCallback onClearMainNotes;

  @override
  Widget build(BuildContext context) {
    final hasMainNotes = topic.notes.isNotEmpty || topic.summary.isNotEmpty;
    final hasAiInsights = topic.aiInsights.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Konu Özetleri & Notlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton.icon(
              onPressed: () => _requestTopicInsight(context, topic),
              icon: Icon(Icons.auto_awesome, size: 16),
              label: Text('AI ile Oluştur'),
            ),
          ],
        ),
        SizedBox(height: 10),
        if (!hasMainNotes && !hasAiInsights)
          GlassPanel(
            padding: const EdgeInsets.all(16),
            radius: BorderRadius.circular(18),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white38),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu konu için henüz kayıtlı not yok. AI ile hızlıca kritik notlar oluşturabilirsin.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ),
              ],
            ),
          ),
        if (hasMainNotes)
          _ExpandableNoteCard(
            title: 'Konu Özeti & Notlar',
            subtitle: 'Genel Bilgiler',
            icon: Icons.description_outlined,
            summary: topic.summary,
            notes: topic.notes,
            onDelete: onClearMainNotes,
          ),
        if (hasAiInsights)
          ...topic.aiInsights.reversed.map((insight) => _ExpandableNoteCard(
                key: ValueKey(insight.id),
                title: 'AI Çalışma Rehberi',
                subtitle: _formatInsightDate(insight.createdAt),
                icon: Icons.auto_awesome,
                summary: insight.summary,
                notes: insight.notes,
                onDelete: () => onDeleteInsight(insight.id),
                isAi: true,
              )),
      ],
    );
  }

  String _formatInsightDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ExpandableNoteCard extends StatefulWidget {
  const _ExpandableNoteCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.summary,
    required this.notes,
    required this.onDelete,
    this.isAi = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String summary;
  final List<String> notes;
  final VoidCallback onDelete;
  final bool isAi;

  @override
  State<_ExpandableNoteCard> createState() => _ExpandableNoteCardState();
}

class _ExpandableNoteCardState extends State<_ExpandableNoteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _isExpanded
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isExpanded
                ? Colors.white.withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isAi 
                      ? AppColors.of(context).primaryLight.withOpacity(_isExpanded ? 1.0 : 0.7)
                      : Colors.white.withOpacity(_isExpanded ? 1.0 : 0.7),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!_isExpanded && widget.summary.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Özetli',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                    ),
                  ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white38,
                  size: 22,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 20),
              if (widget.summary.isNotEmpty) ...[
                Text(
                  widget.summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 20),
              ],
              ...widget.notes.map((note) => _NoteItem(text: note)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Notu Sil'),
                        content: Text('Bu ${widget.isAi ? "AI" : ""} notunu silmek istediğine emin misin?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Vazgeç')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      widget.onDelete();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Bu Notu Sil'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  const _NoteItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingScore extends StatelessWidget {
  const _RingScore({required this.score, required this.label});

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final value = (score / 100).clamp(0.0, 1.0);
    return ProgressRing(
      value: value,
      size: 164,
      strokeWidth: 12,
      trackColor: Colors.white12,
      progressColor: AppColors.of(context).primary,
      centerColor: AppColors.of(context).background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              score.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.progress});

  final TopicProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Toplam\nSoru',
            value: progress.totalQuestions.toString(),
            valueColor: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            title: 'Doğruluk\nOranı',
            value: '%${(progress.accuracy * 100).round()}',
            valueColor: AppColors.of(context).success,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            title: 'Ortalama\nSüre',
            value: progress.totalQuestions == 0
                ? '—'
                : _formatAverageTime(
                    progress.minutes / progress.totalQuestions,
                  ),
            valueColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      radius: BorderRadius.circular(18),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.mastery,
    required this.lastStudied,
  });

  final int mastery;
  final DateTime? lastStudied;

  @override
  Widget build(BuildContext context) {
    final subtitle = lastStudied == null
        ? 'Henüz çalışma yok'
        : 'Son çalışma: ${_daysAgo(lastStudied!)} gün önce';
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konu Hakimiyeti',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: mastery / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.of(context).primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '%$mastery',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatefulWidget {
  const _TrendCard({required this.entries});

  final List<QuestionEntry> entries;

  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard> {
  _TrendRange _range = _TrendRange.week;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime startDate;
    int days;
    List<String> labels;

    if (_range == _TrendRange.week) {
      days = 7;
      startDate = today.subtract(Duration(days: today.weekday - 1));
      labels = List.generate(7, (i) {
        final d = startDate.add(Duration(days: i));
        return _getWeekdayLabel(d.weekday);
      });
    } else {
      days = 30;
      startDate = today.subtract(const Duration(days: 29));
      final mid = today.subtract(const Duration(days: 14));
      labels = [
        '${startDate.day}.${startDate.month}',
        '${mid.day}.${mid.month}',
        '${today.day}.${today.month}',
      ];
    }

    final points = _buildTrendSeries(widget.entries, startDate, days);

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performans Trendi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.entries.isEmpty
                        ? 'Henüz veri yok'
                        : 'Son $days gün hareketi',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _RangeBadge(
                      label: '1H',
                      active: _range == _TrendRange.week,
                      onTap: () => setState(() {
                        _range = _TrendRange.week;
                      }),
                    ),
                    _RangeBadge(
                      label: '1A',
                      active: _range == _TrendRange.month,
                      onTap: () => setState(() {
                        _range = _TrendRange.month;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'Grafik için veri bekleniyor.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  )
                : CustomPaint(
                    painter: _TopicTrendPainter(
                      points,
                      labels,
                      AppColors.of(context).primary,
                    ),
                    child: SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RangeBadge extends StatelessWidget {
  const _RangeBadge({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: active ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _TopicTrendPainter extends CustomPainter {
  _TopicTrendPainter(this.values, this.labels, this.primaryColor);

  final List<double> values;
  final List<String> labels;
  final Color primaryColor;

  @override
void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final chartHeight = size.height - 20;

    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final divisor = values.length > 1 ? (values.length - 1) : 1;
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : size.width * (i / divisor);
      final normalized = (values[i] - minValue) / range;
      final y = chartHeight - (normalized * chartHeight);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    final lastX = values.length == 1 ? size.width / 2 : size.width;
    final lastNormalized = (values.last - minValue) / range;
    final lastY = chartHeight - (lastNormalized * chartHeight);
    final pointPaint = Paint()..color = Colors.white;
    final outlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(lastX, lastY), 4, pointPaint);
    canvas.drawCircle(Offset(lastX, lastY), 6, outlinePaint);

    // Draw Axis Labels
    final textStyle = TextStyle(
      color: Colors.white38,
      fontSize: 10,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    if (labels.length > 3) {
      // Draw all labels for weekly view (assumed short list)
      for (var i = 0; i < labels.length; i++) {
        textPainter.text = TextSpan(text: labels[i], style: textStyle);
        textPainter.layout();
        final x =
            size.width * (i / (labels.length - 1)) - (textPainter.width / 2);
        textPainter.paint(canvas, Offset(x, size.height - textPainter.height));
      }
    } else {
      // Draw sparse labels (start, mid, end) for monthly view
      for (var i = 0; i < labels.length; i++) {
        textPainter.text = TextSpan(text: labels[i], style: textStyle);
        textPainter.layout();
        double x;
        if (i == 0) {
          x = 0;
        } else if (i == labels.length - 1) {
          x = size.width - textPainter.width;
        } else {
          x = (size.width - textPainter.width) / 2;
        }
        textPainter.paint(canvas, Offset(x, size.height - textPainter.height));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TopicTrendPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.primaryColor != primaryColor;
  }
}

class _MistakeSection extends StatelessWidget {
  const _MistakeSection({required this.entries});

  final List<QuestionEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Yanlış Analizi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () =>
                  _showMistakeSheet(context, entries, _MistakeFilter.all),
              child: Text('Tümünü Gör'),
            ),
          ],
        ),
        if (entries.isEmpty)
          Text(
            'Yanlış ve boş dağılımı için kayıt bekleniyor.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MistakeChip(
                label: 'Yanlış',
                count: entries.fold<int>(0, (sum, e) => sum + e.wrong),
                color: Colors.redAccent,
                onTap: () => _showMistakeSheet(
                  context,
                  entries,
                  _MistakeFilter.wrongOnly,
                ),
              ),
              _MistakeChip(
                label: 'Boş',
                count: entries.fold<int>(0, (sum, e) => sum + e.blank),
                color: Colors.amber,
                onTap: () => _showMistakeSheet(
                  context,
                  entries,
                  _MistakeFilter.blankOnly,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _MistakeChip extends StatelessWidget {
  const _MistakeChip({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
            SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.topic});

  final TopicSummary topic;

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    return ValueListenableBuilder<Map<String, List<Flashcard>>>(
      valueListenable: repository.flashcards,
      builder: (context, allCards, _) {
        final cards = allCards[topic.title] ?? [];
        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EntryWizardScreen(
                      type: EntryType.question,
                      preselectedTopic: topic,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add_circle),
              label: Text('Bu Konudan Soru Ekle'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            SizedBox(height: 12),
            if (cards.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openFlashcards(context, cards, topic.title),
                icon: Icon(Icons.style),
                label: Text('Bilgi Kartlarını Çalış (${cards.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).success.withOpacity(0.8),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _generateFlashcards(context, topic),
                icon: Icon(Icons.auto_awesome),
                label: Text('AI ile Bilgi Kartı Üret'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.of(context).primaryLight,
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(
                    color: AppColors.of(context).primary.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _scheduleReview(context, topic),
              icon: Icon(Icons.event),
              label: Text('Tekrar Planla'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: Colors.white.withOpacity(0.12)),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _requestTopicInsight(context, topic),
              icon: Icon(Icons.lightbulb_outline),
              label: Text('AI Çalışma Taktikleri'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.of(context).primaryLight,
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(
                  color: AppColors.of(context).primary.withOpacity(0.3),
                ),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _requestTopicInsight(
  BuildContext context,
  TopicSummary topic,
) async {
  final repository = AppRepositoryScope.of(context);
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  final prompt = '''
KPSS P3 "${topic.title}" (${topic.subject}) konusu için özel çalışma rehberi hazırla.
İstenen çıktı sadece JSON formatında olsun.
Şema:
{
  "summary": "Konunun önemi ve soru potansiyeli (1-2 cümle)",
  "notes": ["Sık yapılan hatalar", "Püf nokta 1", "Püf nokta 2", "Dikkat edilmesi gereken şey"]
}
Mentor tonunda, kısa ve öz yaz.
''';

  final closeLoading = _showLoadingDialog(context, 'AI taktikler hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash-latest'
        : repository.geminiModel.value;

    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();

    final match = RegExp(r'\{[\s\S]*\}').firstMatch(result);
    if (match == null) {
      throw Exception('Format hatası');
    }
    
    final data = jsonDecode(match.group(0)!);
    final summary = data['summary']?.toString() ?? '';
    final List<String> notes = (data['notes'] as List?)?.cast<String>() ?? [];

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${topic.title} Notları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (summary.isNotEmpty) ...[
                Text('Özet:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(summary),
                SizedBox(height: 12),
              ],
              Text('Kritik Notlar:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...notes.map((n) => Text('• $n')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Kaydet'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final newInsight = TopicInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        summary: summary,
        notes: notes,
        createdAt: DateTime.now(),
      );
      final updated = topic.copyWith(
        aiInsights: [...topic.aiInsights, newInsight],
      );
      await repository.saveTopicUpdate(updated);
      _showSnack(context, 'AI notu kaydedildi.');
    }

  } catch (e) {
    closeLoading();
    if (!context.mounted) return;
    _showSnack(context, 'AI taktikleri alınamadı.');
  }
}

Future<void> _generateFlashcards(
  BuildContext context,
  TopicSummary topic,
) async {
  final repository = AppRepositoryScope.of(context);
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  final prompt = '''
KPSS P3 "${topic.title}" (${topic.subject}) konusu için 10 adet bilgi kartı (Flashcard) oluştur.
İstenen çıktı sadece JSON formatında olsun.
Şema: [{"id":"string","question":"soru","answer":"cevap","hint":"ipucu"}]
Sorular kısa, öz ve sınavda çıkabilecek kritik bilgiler olsun.
''';

  final closeLoading = _showLoadingDialog(context, 'AI kartlar hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash-latest'
        : repository.geminiModel.value;

    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    debugPrint('AI Result: $result');
    await repository.incrementAiRequestCount();
    
    final match = RegExp(r'\[[\s\S]*\]').firstMatch(result);
    if (match == null) {
      debugPrint('AI Format Error: No JSON array found in result');
      throw Exception('Format hatası');
    }
    
    final List<dynamic> data = jsonDecode(match.group(0)!);
    final cards = data.map((json) {
      return Flashcard(
        id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        question: json['question'] ?? '',
        answer: json['answer'] ?? '',
        hint: json['hint'],
        topicTitle: topic.title,
      );
    }).toList();

    final existingCards = repository.flashcards.value[topic.title] ?? [];
    final updatedCards = [...existingCards, ...cards];
    await repository.saveFlashcards(topic.title, updatedCards);
    
    closeLoading();

    if (!context.mounted) return;
    _showSnack(context, '${cards.length} yeni kart eklendi. Toplam: ${updatedCards.length}');
    _openFlashcards(context, updatedCards, topic.title);

  } catch (e) {
    debugPrint('AI Flashcard Error: $e');
    closeLoading();
    if (!context.mounted) return;
    _showSnack(context, 'Kart üretilemedi: $e');
  }
}

void _openFlashcards(BuildContext context, List<Flashcard> cards, String topic) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FlashcardStudyScreen(cards: cards, topicTitle: topic),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      activeIndex: 1,
      onSelect: (index) => _navigateFromNav(context, index),
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

void _showMoreActions(BuildContext context, TopicSummary topic) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.of(context).surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionSheetTile(
                icon: Icons.add_circle_outline,
                title: 'Bu konudan soru ekle',
                subtitle: 'Yeni kayıt başlat',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EntryWizardScreen(
                        type: EntryType.question,
                        preselectedTopic: topic,
                      ),
                    ),
                  );
                },
              ),
              _ActionSheetTile(
                icon: Icons.event_available,
                title: 'Tekrar planla',
                subtitle: 'Hatırlatma ekle',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _scheduleReview(context, topic);
                },
              ),
              if (topic.notes.isNotEmpty || topic.summary.isNotEmpty)
                _ActionSheetTile(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Özet ve Notları Temizle',
                  subtitle: 'Varsayılan haline döndür',
                  iconColor: Colors.orangeAccent,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Notları Sil'),
                        content: const Text('Bu konu için kaydedilmiş AI özetleri ve notlar silinecek. Emin misin?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await AppRepositoryScope.of(context).deleteTopicUpdate(topic.id);
                      if (context.mounted) {
                        _showSnack(context, 'Notlar temizlendi.');
                      }
                    }
                  },
                ),
              if (AppRepositoryScope.of(context).flashcards.value.containsKey(topic.title))
                _ActionSheetTile(
                  icon: Icons.delete_sweep,
                  title: 'Bilgi Kartlarını Temizle',
                  subtitle: 'Tüm kartları sil',
                  iconColor: Colors.redAccent,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Kartları Sil'),
                        content: const Text('Bu konu için oluşturulmuş tüm bilgi kartları silinecek. Emin misin?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            child: const Text('Hepsini Sil'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await AppRepositoryScope.of(context).clearFlashcards(topic.title);
                      if (context.mounted) {
                        _showSnack(context, 'Kartlar temizlendi.');
                      }
                    }
                  },
                ),
              _ActionSheetTile(
                icon: Icons.insights,
                title: 'Analize git',
                subtitle: 'Performans ekranı',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AnalysisScreen()),
                  );
                },
              ),
              _ActionSheetTile(
                icon: Icons.library_books,
                title: 'Konulara dön',
                subtitle: 'Tüm konu listesi',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => TopicSummariesScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionSheetTile extends StatelessWidget {
  const _ActionSheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (iconColor ?? Colors.white).withOpacity(0.06),
        child: Icon(icon, color: iconColor ?? Colors.white70),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
            ),
      ),
      onTap: onTap,
    );
  }
}

Future<void> _scheduleReview(
  BuildContext context,
  TopicSummary topic,
) async {
  final today = DateTime.now();
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: today.add(const Duration(days: 1)),
    firstDate: today,
    lastDate: today.add(const Duration(days: 365)),
  );
  if (selectedDate == null) {
    return;
  }
  final selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(today.add(const Duration(hours: 1))),
  );
  if (selectedTime == null) {
    return;
  }
  final scheduled = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
  if (scheduled.isBefore(DateTime.now())) {
    _showSnack(context, 'Seçilen zaman geçmişte. Lütfen yeni bir zaman seç.');
    return;
  }

  final notificationId = scheduled.millisecondsSinceEpoch % 100000;
  await NotificationService.scheduleOneOff(
    id: notificationId,
    title: 'Tekrar Planı',
    body: '${topic.title} konusunu planladığın zamanda tekrar et.',
    dateTime: scheduled,
  );

  final repository = AppRepositoryScope.of(context);
  await repository.addNotification(
    AppNotification(
      id: notificationId.toString(),
      title: 'Tekrar planı oluşturuldu',
      body:
          '${topic.title} • ${_formatShortDate(scheduled)} ${_formatClock(scheduled)}',
      createdAt: DateTime.now(),
    ),
  );

  _showSnack(context, 'Tekrar planı eklendi.');
}

void _showMistakeSheet(
  BuildContext context,
List<QuestionEntry> entries,
  _MistakeFilter filter,
) {
  final filtered = entries.where((entry) {
    if (filter == _MistakeFilter.wrongOnly) {
      return entry.wrong > 0;
    }
    if (filter == _MistakeFilter.blankOnly) {
      return entry.blank > 0;
    }
    return entry.wrong > 0 || entry.blank > 0;
  }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _mistakeTitle(filter),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Bu filtre için kayıt bulunamadı.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white54,
                                    ),
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (_, index) {
                            final entry = filtered[index];
                            return _MistakeDetailTile(entry: entry);
                          },
                          separatorBuilder: (_, __) =>
                              SizedBox(height: 12),
                          itemCount: filtered.length,
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

String _mistakeTitle(_MistakeFilter filter) {
  switch (filter) {
    case _MistakeFilter.wrongOnly:
      return 'Yanlış Detayları';
    case _MistakeFilter.blankOnly:
      return 'Boş Detayları';
    case _MistakeFilter.all:
      return 'Yanlış & Boş Detayları';
  }
}

class _MistakeDetailTile extends StatelessWidget {
  const _MistakeDetailTile({required this.entry});

  final QuestionEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.topic.isEmpty ? 'Soru Kaydı' : entry.topic,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 4),
          Text(
            '${entry.subject} • ${_formatShortDate(entry.createdAt)} ${_formatClock(entry.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _MistakeStat(label: 'Doğru', value: entry.correct, color: AppColors.of(context).success),
              SizedBox(width: 8),
              _MistakeStat(label: 'Yanlış', value: entry.wrong, color: Colors.redAccent),
              SizedBox(width: 8),
              _MistakeStat(label: 'Boş', value: entry.blank, color: Colors.amber),
            ],
          ),
        ],
      ),
    );
  }
}

class _MistakeStat extends StatelessWidget {
  const _MistakeStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

List<double> _buildTrendSeries(List<QuestionEntry> entries, DateTime start, int days) {
  if (entries.isEmpty) {
    return [];
  }
  final now = DateTime.now();
  final buckets = List<double>.filled(days, 0);

  for (final entry in entries) {
    final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
    if (day.isBefore(start) || day.isAfter(now)) {
      continue;
    }
    final index = day.difference(start).inDays;
    if (index >= 0 && index < buckets.length) {
      buckets[index] += entry.correct.toDouble();
    }
  }
  return buckets;
}

String _getWeekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Pzt';
    case DateTime.tuesday:
      return 'Sal';
    case DateTime.wednesday:
      return 'Çar';
    case DateTime.thursday:
      return 'Per';
    case DateTime.friday:
      return 'Cum';
    case DateTime.saturday:
      return 'Cmt';
    case DateTime.sunday:
      return 'Paz';
    default:
      return '';
  }
}

String _formatShortDate(DateTime date) {
  final months = [
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
  return '${date.day} ${months[date.month - 1]}';
}

String _formatClock(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int _calculateMastery(TopicProgress progress) {
  if (progress.totalQuestions == 0) {
    return 0;
  }
  final accuracyScore = progress.accuracy * 70;
  final volumeScore = min(1.0, progress.totalQuestions / 200) * 20;
  final recencyScore = _recencyScore(progress.lastStudied) * 10;
  return (accuracyScore + volumeScore + recencyScore).round();
}

double _recencyScore(DateTime? lastStudied) {
  if (lastStudied == null) {
    return 0;
  }
  final days = DateTime.now().difference(lastStudied).inDays;
  if (days <= 1) {
    return 1;
  }
  if (days <= 3) {
    return 0.8;
  }
  if (days <= 7) {
    return 0.6;
  }
  if (days <= 14) {
    return 0.4;
  }
  return 0.2;
}

String _formatAverageTime(double minutesPerQuestion) {
  if (minutesPerQuestion < 1) {
    final seconds = (minutesPerQuestion * 60).round();
    return '$seconds sn';
  }
  return '${minutesPerQuestion.toStringAsFixed(1)} dk';
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

Future<void> _showResultDialog(
  BuildContext context,
  String title,
  String content,
) {
  return AiResponseDialog.show(context, title, content);
}

int _daysAgo(DateTime date) {
  final now = DateTime.now();
  return now.difference(date).inDays;
}

