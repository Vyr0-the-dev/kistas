import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_notification.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../services/app_repository.dart';
import '../services/gemini_client.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_loading_dialog.dart';
import '../widgets/ai_response_dialog.dart';
import '../widgets/ambient_background.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import 'entry_wizard_screen.dart';
import 'quick_add_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'topic_detail_screen.dart';
import 'topic_summaries_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisMode _mode = AnalysisMode.exams;
  _RangeFilter _rangeFilter = _RangeFilter.days30;
  DateTimeRange? _customRange;
  final GlobalKey _weeklyReportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: SafeArea(
          child: ValueListenableBuilder<List<QuestionEntry>>(
            valueListenable: repository.questionEntries,
            builder: (context, questionEntries, _) {
              return ValueListenableBuilder<List<MockExam>>(
                valueListenable: repository.mockExams,
                builder: (context, mockExams, __) {
                  final hasQuestions = questionEntries.isNotEmpty;
                  final hasExams = mockExams.isNotEmpty;
  
                  final dateRange = _getDateRange(_rangeFilter, _customRange);
                  final questionFiltered = _filterQuestions(
                    questionEntries,
                    dateRange.start,
                    dateRange.end,
                  );
                  final examsFiltered = _filterExams(
                    mockExams,
                    dateRange.start,
                    dateRange.end,
                  );
  
                  if (!hasQuestions && !hasExams) {
                    return _EmptyState(
                      onAddExam: () => _openEntry(context, EntryType.mockExam),
                      onAddQuestion: () =>
                          _openEntry(context, EntryType.question),
                    );
                  }

                final activeMode = _mode;
                final hasActiveData = activeMode == AnalysisMode.exams
                    ? examsFiltered.isNotEmpty
                    : questionFiltered.isNotEmpty;
                final metrics = activeMode == AnalysisMode.exams
                    ? _ExamMetrics.from(examsFiltered)
                    : _QuestionMetrics.from(
                        questionFiltered,
                        dateRange.start,
                        dateRange.end,
                      );
                final weakTopics = repository.weakestTopics();

                final weeklySummary =
                    _buildWeeklySummary(questionEntries, mockExams);
                final weeklyTargets = _buildWeeklyTargets(
                  questionEntries,
                  repository.dailyGoal.value,
                );

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(
                        onShare: () => _shareWeeklyReportImage(
                          context,
                          _weeklyReportKey,
                          weeklySummary,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ModeSelector(
                          mode: activeMode,
                          examsEnabled: true,
                          questionsEnabled: true,
                          onChanged: (mode) => setState(() => _mode = mode),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: _RangeSelector(
                          selected: _rangeFilter,
                          onSelect: (value) async {
                            if (value == _RangeFilter.custom) {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(DateTime.now().year - 1),
                                lastDate: DateTime(DateTime.now().year + 1),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              if (range == null) {
                                return;
                              }
                              setState(() {
                                _customRange = range;
                                _rangeFilter = _RangeFilter.custom;
                              });
                              return;
                            }
                            setState(() {
                              _customRange = null;
                              _rangeFilter = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: hasActiveData
                            ? _TrendCard(metrics: metrics)
                            : _ModeEmptyState(
                                mode: activeMode,
                                onAddExam: () =>
                                    _openEntry(context, EntryType.mockExam),
                                onAddQuestion: () =>
                                    _openEntry(context, EntryType.question),
                              ),
                      ),
                    ),
                    if (hasActiveData)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: metrics.leftTitle,
                                  value: metrics.leftValue,
                                  subtitle: metrics.leftSubtitle,
                                  accent: metrics.leftAccent(context),
                                  footer: _MiniSparkline(
                                    values: metrics.trend,
                                    color: metrics.leftAccent(context),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: metrics.rightTitle,
                                  value: metrics.rightValue,
                                  subtitle: metrics.rightSubtitle,
                                  accent: metrics.rightAccent(context),
                                  footer: _MiniBars(
                                    values: metrics.trend,
                                    color: metrics.rightAccent(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasActiveData && activeMode == AnalysisMode.exams)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _ExamCompareCard(
                            exams: _recentExams(mockExams),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: RepaintBoundary(
                          key: _weeklyReportKey,
                          child: _WeeklyReportCard(
                            summary: weeklySummary,
                            onShare: () => _shareWeeklyReportImage(
                              context,
                              _weeklyReportKey,
                              weeklySummary,
                            ),
                            onNewsletter: () => _requestAiNewsletter(
                              context,
                              repository,
                              weeklySummary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: _WeeklyTargetCard(items: weeklyTargets),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: _WeakTopicsCard(
                          topics: weakTopics,
                          onAiSummary: () => _requestAiSummary(
                            context,
                            repository,
                            activeMode,
                            metrics,
                          ),
                          onStudy: (topic) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TopicDetailScreen(
                                  topic: topic.topic,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (hasActiveData && activeMode == AnalysisMode.questions)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _QuestionInsightCard(
                            tags: _buildWrongTagCounts(questionEntries),
                            onAnalyze: () => _requestAiQuestionAnalysis(
                              context,
                              repository,
                              metrics as _QuestionMetrics,
                              weakTopics,
                            ),
                          ),
                        ),
                      ),
                    if (hasActiveData && activeMode == AnalysisMode.questions)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _TimeDistributionCard(
                            data: _buildSubjectMinutes(questionEntries),
                          ),
                        ),
                      ),
                    if (hasActiveData && activeMode == AnalysisMode.exams)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _ExamBranchCard(
                            stats: _buildExamBranchStats(mockExams),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                );
              },
            );
          },
        ),
      ),
    ),
    bottomNavigationBar: AppBottomNav(
      activeIndex: 3,
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => QuickAddScreen()),
        );
        return;
      case 3:
        return;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        return;
    }
  }
}

Future<void> _requestAiSummary(
  BuildContext context,
  AppRepository repository,
  AnalysisMode mode,
  _AnalysisMetrics metrics,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  debugPrint('AnalizScreen: _requestAiSummary. Repo Model Değeri: "${repository.geminiModel.value}"');

  final targets = repository.aiGoalTargets.value;
  final cadence = repository.aiGoalCadence.value;
  final prompt = '''
KPSS P3 çalışması için mentor gibi özet ve aksiyon önerisi yaz.
Mod: ${mode == AnalysisMode.exams ? 'Deneme' : 'Soru'}
Ana metrik: ${metrics.title} ${metrics.value} ${metrics.unit}
Öne çıkan metrikler: ${metrics.leftTitle} ${metrics.leftValue}, ${metrics.rightTitle} ${metrics.rightValue}
AI hedefleri (günlük/haftalık/aylık): ${targets['daily'] ?? '-'} / ${targets['weekly'] ?? '-'} / ${targets['monthly'] ?? '-'}
Seçili kadans: ${_cadenceLabel(cadence)}
İstenen çıktı: 4 maddelik mentor notu (1) kısa durum (2) net/performans odağı (3) bir sonraki aksiyon (4) motivasyon cümlesi.
''';

  final closeLoading = _showLoadingDialog(context, 'AI özet hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;
    
    debugPrint('AnalizScreen: Kullanılacak Model: $model');

    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    if (repository.aiNotificationsEnabled.value) {
      await repository.addNotification(
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'AI Analiz Özeti',
          body: result.length > 140 ? '${result.substring(0, 140)}…' : result,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (!context.mounted) {
      return;
    }
    await _showResultDialog(context, 'AI Özet', result);
  } catch (e) {
    debugPrint('AnalizScreen: Hata: $e');
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    
    String message = 'AI özet alınamadı.';
    if (e.toString().contains('429')) {
      message = 'API kotası aşıldı. Lütfen biraz bekleyin veya model değiştirin.';
    } else if (e.toString().contains('404')) {
      message = 'Seçilen model bu API anahtarı ile kullanılamıyor.';
    } else if (e.toString().contains('503')) {
      message = 'AI servisi yoğun. Lütfen daha sonra deneyin.';
    }
    
    _showSnack(context, message);
  }
}

Future<void> _requestAiQuestionAnalysis(
  BuildContext context,
  AppRepository repository,
  _QuestionMetrics metrics,
List<TopicProgress> weakTopics,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }
  
  debugPrint('AnalizScreen: _requestAiQuestionAnalysis. Repo Model Değeri: "${repository.geminiModel.value}"');

  final targets = repository.aiGoalTargets.value;
  final cadence = repository.aiGoalCadence.value;
  final weakLabel = weakTopics.isEmpty
      ? 'Henüz zayıf konu yok.'
      : weakTopics.map((e) => e.topic.title).take(3).join(', ');

  final averageDaily = metrics.trend.isEmpty
      ? 0
      : (metrics.trend.fold<double>(0, (sum, value) => sum + value) /
              metrics.trend.length)
          .round();
  final avgMinutes = metrics.avgMinutesPerQuestion == 0
      ? '-'
      : _formatAverageMinutes(metrics.avgMinutesPerQuestion);

  final prompt = '''
KPSS P3 soru analizi yap. Hatalı eğilimleri ve hız/performans darboğazını çıkar.
Özet:
- Ortalama doğruluk: ${(metrics.accuracy * 100).round()}%
- Günlük tempo: $averageDaily soru
- Ortalama süre: $avgMinutes
- Zayıf konular: $weakLabel
- AI hedefleri (günlük/haftalık/aylık): ${targets['daily'] ?? '-'} / ${targets['weekly'] ?? '-'} / ${targets['monthly'] ?? '-'}
- Seçili kadans: ${_cadenceLabel(cadence)}
İstenen çıktı: 4 maddelik net eylem listesi + 1 cümle motivasyon.
''';

  final closeLoading = _showLoadingDialog(context, 'AI soru analizi hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;
    
    debugPrint('AnalizScreen: Kullanılacak Model: $model');

    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    if (repository.aiNotificationsEnabled.value) {
      await repository.addNotification(
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'AI Soru Analizi',
          body: result.length > 140 ? '${result.substring(0, 140)}…' : result,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (!context.mounted) {
      return;
    }
    await _showResultDialog(context, 'AI Soru Analizi', result);
  } catch (e) {
    debugPrint('AnalizScreen: Hata: $e');
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    
    String message = 'AI soru analizi alınamadı.';
    if (e.toString().contains('429')) {
      message = 'API kotası aşıldı. Lütfen biraz bekleyin veya model değiştirin.';
    } else if (e.toString().contains('404')) {
      message = 'Seçilen model bu API anahtarı ile kullanılamıyor.';
    } else if (e.toString().contains('503')) {
      message = 'AI servisi yoğun. Lütfen daha sonra deneyin.';
    }
    
    _showSnack(context, message);
  }
}

Future<void> _requestAiNewsletter(
  BuildContext context,
  AppRepository repository,
  String rawSummary,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  final prompt = '''
Sen KPSS P3 adayı için bir mentörsün. Aşağıdaki haftalık çalışma özetini al ve profesyonel, motive edici bir "Haftalık Performans Bülteni" hazırla.
Veriler:
$rawSummary

Bülten yapısı:
1) Geçen Haftanın Panoraması (Şık bir başlık ile)
2) Güçlü ve Zayıf Yanlar Analizi
3) Gelecek Hafta İçin 3 Kritik Tavsiye
4) Kapanış Motivasyon Cümlesi

Bülteni Markdown formatında, paylaşılmaya uygun şık bir şekilde yaz.
''';

  final closeLoading = _showLoadingDialog(context, 'Bülten hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;

    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();

    if (!context.mounted) return;
    
    await _showResultDialog(context, 'Haftalık AI Bülteni', result);
    
    // Suggest sharing
    final confirmShare = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bülteni Paylaş'),
        content: const Text('Bu bülteni arkadaşlarınla veya kendine not olarak paylaşmak ister misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hayır')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet, Paylaş')),
        ],
      ),
    );

    if (confirmShare == true) {
      await Share.share(result, subject: 'KPSS Haftalık Performans Bültenim');
    }

  } catch (e) {
    closeLoading();
    if (!context.mounted) return;
    _showSnack(context, 'Bülten oluşturulamadı.');
  }
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

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String _buildWeeklySummary(
List<QuestionEntry> questions,
List<MockExam> exams,
) {
  final now = DateTime.now();
  final last7Questions = questions
      .where((entry) => now.difference(entry.createdAt).inDays < 7)
      .toList();
  final last7Exams = exams
      .where((exam) => now.difference(exam.createdAt).inDays < 7)
      .toList();
  final totalQuestions = last7Questions.fold<int>(
    0,
    (sum, entry) => sum + entry.total,
  );
  final totalMinutes = last7Questions.fold<int>(
    0,
    (sum, entry) => sum + entry.minutes,
  );
  final examCount = last7Exams.length;
  final avgNet = last7Exams.isEmpty
      ? 0
      : last7Exams
              .fold<double>(0, (sum, exam) => sum + exam.totalNet) /
          last7Exams.length;
  return [
    'Haftalık Özet',
    '- Toplam soru: $totalQuestions',
    '- Toplam süre: $totalMinutes dk',
    '- Deneme sayısı: $examCount',
    '- Ortalama net: ${avgNet.toStringAsFixed(1)}',
  ].join('\n');
}

List<_WeeklyTargetItem> _buildWeeklyTargets(
List<QuestionEntry> questions,
  int dailyGoal,
) {
  if (questions.isEmpty) {
    return [];
  }
  final now = DateTime.now();
  final items = <_WeeklyTargetItem>[];
  for (var i = 3; i >= 0; i--) {
    final weekStart = _startOfWeek(now.subtract(Duration(days: 7 * i)));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final total = questions
        .where((entry) =>
            !entry.createdAt.isBefore(weekStart) &&
            entry.createdAt.isBefore(weekEnd))
        .fold<int>(0, (sum, entry) => sum + entry.total);
    items.add(
      _WeeklyTargetItem(
        label: '${weekStart.day}.${weekStart.month}',
        actual: total,
        target: dailyGoal * 7,
      ),
    );
  }
  return items;
}

DateTime _startOfWeek(DateTime date) {
  final weekday = date.weekday == DateTime.sunday ? 7 : date.weekday;
  final diff = weekday - DateTime.monday;
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.subtract(Duration(days: diff));
}

enum _RangeFilter { days7, days30, days90, custom }

List<QuestionEntry> _filterQuestions(
List<QuestionEntry> entries,
  DateTime start,
  DateTime end,
) {
  if (entries.isEmpty) {
    return entries;
  }
  return entries
      .where((entry) =>
          !entry.createdAt.isBefore(start) && entry.createdAt.isBefore(end))
      .toList();
}

List<MockExam> _filterExams(
List<MockExam> exams,
  DateTime start,
  DateTime end,
) {
  if (exams.isEmpty) {
    return exams;
  }
  return exams
      .where((exam) =>
          !exam.createdAt.isBefore(start) && exam.createdAt.isBefore(end))
      .toList();
}

DateTimeRange _getDateRange(_RangeFilter filter, DateTimeRange? customRange) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime start;
  DateTime end = today.add(const Duration(days: 1));

  switch (filter) {
    case _RangeFilter.days7:
      start = today.subtract(const Duration(days: 6));
      break;
    case _RangeFilter.days30:
      start = today.subtract(const Duration(days: 29));
      break;
    case _RangeFilter.days90:
      start = today.subtract(const Duration(days: 89));
      break;
    case _RangeFilter.custom:
      if (customRange != null) {
        start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
        );
        end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
        ).add(const Duration(days: 1));
      } else {
        start = today.subtract(const Duration(days: 6));
      }
      break;
  }
  return DateTimeRange(start: start, end: end);
}

Future<void> _shareWeeklyReportImage(
  BuildContext context,
  GlobalKey key,
  String summary,
) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    await Share.share(summary, subject: 'Road to ATC - Haftalık Rapor');
    return;
  }
  if (boundary.debugNeedsPaint) {
    await Future.delayed(const Duration(milliseconds: 60));
  }
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    await Share.share(summary, subject: 'Road to ATC - Haftalık Rapor');
    return;
  }
  final bytes = byteData.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/weekly_report_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(bytes);
  if (!context.mounted) {
    return;
  }
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Road to ATC haftalık rapor',
  );
}

String _cadenceLabel(String cadence) {
  switch (cadence) {
    case 'weekly':
      return 'Haftalık';
    case 'monthly':
      return 'Aylık';
    default:
      return 'Günlük';
  }
}

enum AnalysisMode { exams, questions }

class _Header extends StatelessWidget {
  const _Header({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      radius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back, color: Colors.white70),
          ),
          SizedBox(width: 4),
          Text(
            'Performans Analizi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onShare,
            icon: Icon(Icons.ios_share, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.examsEnabled,
    required this.questionsEnabled,
    required this.onChanged,
  });

  final AnalysisMode mode;
  final bool examsEnabled;
  final bool questionsEnabled;
  final ValueChanged<AnalysisMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(6),
      radius: BorderRadius.circular(18),
      child: Row(
        children: [
          _ModeChip(
            label: 'Deneme',
            active: mode == AnalysisMode.exams,
            enabled: examsEnabled,
            onTap: examsEnabled ? () => onChanged(AnalysisMode.exams) : null,
          ),
          _ModeChip(
            label: 'Soru',
            active: mode == AnalysisMode.questions,
            enabled: questionsEnabled,
            onTap: questionsEnabled
                ? () => onChanged(AnalysisMode.questions)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.of(context).primary : Colors.white54;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.of(context).primary.withOpacity(0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled ? color : Colors.white24,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onSelect});

  final _RangeFilter selected;
  final ValueChanged<_RangeFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(6),
      radius: BorderRadius.circular(20),
      child: Row(
        children: [
          _RangeChip(
            label: '7 Gün',
            active: selected == _RangeFilter.days7,
            onTap: () => onSelect(_RangeFilter.days7),
          ),
          _RangeChip(
            label: '30 Gün',
            active: selected == _RangeFilter.days30,
            onTap: () => onSelect(_RangeFilter.days30),
          ),
          _RangeChip(
            label: '90 Gün',
            active: selected == _RangeFilter.days90,
            onTap: () => onSelect(_RangeFilter.days90),
          ),
          _RangeChip(
            label: 'Özel',
            active: selected == _RangeFilter.custom,
            onTap: () => onSelect(_RangeFilter.custom),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.of(context).primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active ? Theme.of(context).colorScheme.onPrimary : Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _ModeEmptyState extends StatelessWidget {
  const _ModeEmptyState({
    required this.mode,
    required this.onAddExam,
    required this.onAddQuestion,
  });

  final AnalysisMode mode;
  final VoidCallback onAddExam;
  final VoidCallback onAddQuestion;

  @override
  Widget build(BuildContext context) {
    final isExam = mode == AnalysisMode.exams;
    final title = isExam ? 'Deneme verisi yok' : 'Soru verisi yok';
    final message = isExam
        ? 'Bu aralıkta deneme kaydı bulunamadı. Yeni deneme ekleyebilirsin.'
        : 'Bu aralıkta soru kaydı bulunamadı. Yeni soru kaydı ekleyebilirsin.';
    final actionLabel = isExam ? 'Deneme Ekle' : 'Soru Ekle';
    final onTap = isExam ? onAddExam : onAddQuestion;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.metrics});

  final _AnalysisMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          metrics.value,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          metrics.unit,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DeltaChip(delta: metrics.delta),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: _TrendChart(values: metrics.trend, accent: metrics.accent(context)),
          ),
          SizedBox(height: 8),
          _TrendAxis(labels: metrics.axisLabels),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? AppColors.of(context).success : AppColors.of(context).danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            '%${(delta * 100).abs().toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.values, required this.accent});

  final List<double> values;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Center(
        child: Text(
          'Grafik için veri yok',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),
      );
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TrendPainter(values, accent),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values, this.accent);

  final List<double> values;
  final Color accent;

  @override
void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePath = Path();
    final fillPath = Path();

    final divisor = values.length > 1 ? (values.length - 1) : 1;
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * (i / divisor);
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withOpacity(0.35),
          accent.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final lastX = size.width;
    final lastNormalized = (values.last - minValue) / range;
    final lastY = size.height - (lastNormalized * size.height);
    final pointPaint = Paint()..color = Colors.white;
    final outlinePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(lastX, lastY), 4, pointPaint);
    canvas.drawCircle(Offset(lastX, lastY), 6, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.accent != accent;
  }
}

class _TrendAxis extends StatelessWidget {
  const _TrendAxis({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    this.footer,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: BorderRadius.circular(22),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Background chart/sparkline (positioned)
          if (footer != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60,
              child: Opacity(
                opacity: 0.15,
                child: footer!,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white38,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox.shrink();
    }
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
      child: SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
void paint(Canvas canvas, Size size) {
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = max(1.0, maxValue - minValue);
    final path = Path();
    final divisor = values.length - 1;
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / divisor);
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox.shrink();
    }
    final maxValue = values.reduce(max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values.take(7).map((value) {
        final ratio = maxValue == 0 ? 0.0 : value / maxValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: 6 + (ratio * 26),
              decoration: BoxDecoration(
                color: color.withOpacity(value == values.last ? 0.9 : 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeakTopicsCard extends StatelessWidget {
  const _WeakTopicsCard({
    required this.topics,
    required this.onAiSummary,
    required this.onStudy,
  });

  final List<TopicProgress> topics;
  final VoidCallback onAiSummary;
  final ValueChanged<TopicProgress> onStudy;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dikkat Gerektiren Konular',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: onAiSummary,
                child: Text(
                  'AI Özet',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.of(context).primaryLight,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (topics.isEmpty)
            Text(
              'Henüz zayıf konu tespiti yapılmadı.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            )
          else
            Column(
              children: topics
                  .map((topic) => _WeakTopicRow(
                        topic: topic,
                        onStudy: () => onStudy(topic),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _WeakTopicRow extends StatelessWidget {
  const _WeakTopicRow({required this.topic, required this.onStudy});

  final TopicProgress topic;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    final accuracyPercent = (topic.accuracy * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.topic.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${topic.topic.subject} • ${topic.totalQuestions} çözülen',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '%$accuracyPercent',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).warning,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'Doğruluk',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                    ),
              ),
            ],
          ),
          SizedBox(width: 12),
          OutlinedButton(
            onPressed: onStudy,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.12)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('Çalış'),
          ),
        ],
      ),
    );
  }
}

class _QuestionInsightCard extends StatelessWidget {
  const _QuestionInsightCard({
    required this.tags,
    required this.onAnalyze,
  });

  final Map<String, int> tags;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Soru Analizi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Yanlış eğilimlerini ve hız darboğazını yorumlar.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          SizedBox(height: 10),
          if (tags.isEmpty)
            Text(
              'Yanlış türü etiketlenmedi.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.entries
                  .map(
                    (entry) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.of(context).primary),
                      ),
                      child: Text(
                        '${entry.key} • ${entry.value}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAnalyze,
              icon: Icon(Icons.psychology_alt),
              label: Text('Analiz Al'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCompareCard extends StatelessWidget {
  const _ExamCompareCard({required this.exams});

  final List<MockExam> exams;

  @override
  Widget build(BuildContext context) {
    final points = exams.map((exam) => exam.totalNet).toList();
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deneme Kıyas Grafiği',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8),
          if (exams.isEmpty)
            Text(
              'Henüz deneme eklenmedi.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            )
          else ...[
            RepaintBoundary(
              child: SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: _LineChartPainter(
                    values: points,
                    primaryColor: AppColors.of(context).primary,
                    primaryLightColor: AppColors.of(context).primaryLight,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: exams
                  .map(
                    (exam) => _BarRow(
                      label: exam.title,
                      valueLabel:
                          '${exam.totalNet.toStringAsFixed(1)} net • ${exam.minutes} dk',
                      ratio: (exam.totalNet / 120).clamp(0.0, 1.0),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.primaryColor,
    required this.primaryLightColor,
  });

  final List<double> values;
  final Color primaryColor;
  final Color primaryLightColor;

  @override
void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }
    final maxValue = values.reduce(max);
    final minValue = values.reduce(min);
    final range = max(1.0, maxValue - minValue);
    final paintLine = Paint()
      ..color = primaryLightColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);
    // last point dot
    final lastX = size.width;
    final lastNormalized = (values.last - minValue) / range;
    final lastY = size.height - (lastNormalized * size.height);
    canvas.drawCircle(Offset(lastX, lastY), 5, paintDot);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.primaryLightColor != primaryLightColor;
  }
}

class _WeeklyTargetItem {
  const _WeeklyTargetItem({
    required this.label,
    required this.actual,
    required this.target,
  });

  final String label;
  final int actual;
  final int target;
}

class _WeeklyTargetCard extends StatelessWidget {
  const _WeeklyTargetCard({required this.items});

  final List<_WeeklyTargetItem> items;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haftalık Hedef Grafiği',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'Hedef grafiği için yeterli veri yok.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            )
          else
            Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Text(
                                '${item.actual}/${item.target}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.white54),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: 1,
                                  minHeight: 6,
                                  backgroundColor: Colors.white12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white12),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: item.target == 0
                                      ? 0
                                      : (item.actual / item.target)
                                          .clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          AppColors.of(context).primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _WeeklyReportCard extends StatelessWidget {
  const _WeeklyReportCard({
    required this.summary,
    required this.onShare,
    required this.onNewsletter,
  });

  final String summary;
  final VoidCallback onShare;
  final VoidCallback onNewsletter;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haftalık Rapor',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: Icon(Icons.share, size: 18),
                  label: Text('Paylaş'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onNewsletter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(Icons.auto_awesome, size: 18),
                  label: Text('AI Bülten Al'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectBar {
  const _SubjectBar({
    required this.subject,
    required this.value,
    required this.label,
  });

  final String subject;
  final double value;
  final String label;
}

class _TimeDistributionCard extends StatelessWidget {
  const _TimeDistributionCard({required this.data});

  final List<_SubjectBar> data;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ders Süre Dağılımı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12),
          if (data.isEmpty)
            Text(
              'Henüz süre verisi yok.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            )
          else
            Column(
              children: data
                  .map((item) => _BarRow(
                        label: item.subject,
                        valueLabel: item.label,
                        ratio: item.value,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ExamBranchStat {
  const _ExamBranchStat({
    required this.subject,
    required this.avgNet,
    required this.avgMinutes,
  });

  final String subject;
  final double avgNet;
  final double avgMinutes;
}

class _ExamBranchCard extends StatelessWidget {
  const _ExamBranchCard({required this.stats});

  final List<_ExamBranchStat> stats;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      radius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deneme Branş Analizi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12),
          if (stats.isEmpty)
            Text(
              'Branş netleri girilmedi. Deneme eklerken branş netlerini doldurabilirsin.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            )
          else
            Column(
              children: stats
                  .map(
                    (item) => _BarRow(
                      label: item.subject,
                      valueLabel:
                          '${item.avgNet.toStringAsFixed(1)} net • ${item.avgMinutes.toStringAsFixed(0)} dk',
                      ratio: (item.avgNet / 20).clamp(0.0, 1.0),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.valueLabel,
    required this.ratio,
  });

  final String label;
  final String valueLabel;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.of(context).primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddExam, required this.onAddQuestion});

  final VoidCallback onAddExam;
  final VoidCallback onAddQuestion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.analytics, color: Colors.white70, size: 40),
            ),
            SizedBox(height: 16),
            Text(
              'Henüz Veri Yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Önce soru veya deneme ekleyerek analiz panelini aç.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onAddQuestion,
                  child: Text('Soru Ekle'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAddExam,
                  child: Text('Deneme Ekle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _AnalysisMetrics {
  String get title;
  String get value;
  String get unit;
  double get delta;
List<double> get trend;
List<String> get axisLabels;
  Color accent(BuildContext context);
  String get leftTitle;
  String get leftValue;
  String get leftSubtitle;
  Color leftAccent(BuildContext context);
  String get rightTitle;
  String get rightValue;
  String get rightSubtitle;
  Color rightAccent(BuildContext context);
}

class _ExamMetrics implements _AnalysisMetrics {
  _ExamMetrics({
    required this.averageNet,
    required this.averageMinutes,
    required this.trend,
    required this.delta,
    required this.axisLabels,
  });

  final double averageNet;
  final double averageMinutes;
  @override
  final List<double> trend;
  @override
  final double delta;
  @override
  final List<String> axisLabels;

  static _ExamMetrics from(List<MockExam> exams) {
    final sorted = [...exams]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final points = sorted.map((e) => e.totalNet).toList();
    final averageNet = exams.isEmpty
        ? 0.0
        : exams.fold<double>(0, (sum, e) => sum + e.totalNet) / exams.length;
    final averageMinutes = exams.isEmpty
        ? 0.0
        : exams.fold<int>(0, (sum, e) => sum + e.minutes).toDouble() /
            exams.length;

List<String> labels = [];
    if (sorted.isNotEmpty) {
      if (sorted.length <= 4) {
        labels = sorted.map((e) => '${e.createdAt.day}.${e.createdAt.month}').toList();
      } else {
        final first = sorted.first.createdAt;
        final last = sorted.last.createdAt;
        final mid1 = sorted[sorted.length ~/ 3].createdAt;
        final mid2 = sorted[2 * sorted.length ~/ 3].createdAt;
        labels = [
          '${first.day}.${first.month}',
          '${mid1.day}.${mid1.month}',
          '${mid2.day}.${mid2.month}',
          '${last.day}.${last.month}',
        ];
      }
    }

    return _ExamMetrics(
      averageNet: averageNet,
      averageMinutes: averageMinutes,
      trend: points,
      delta: _calculateDelta(points),
      axisLabels: labels,
    );
  }

  @override
  String get title => 'Genel Net Gidişatı';

  @override
  String get value => trend.isEmpty ? '0' : trend.last.toStringAsFixed(1);

  @override
  String get unit => 'Net';

  @override
  Color accent(BuildContext context) => AppColors.of(context).primaryLight;

  @override
  String get leftTitle => 'Ortalama Net';

  @override
  String get leftValue => averageNet == 0 ? '—' : averageNet.toStringAsFixed(1);

  @override
  String get leftSubtitle => 'Deneme ortalaması';

  @override
  Color leftAccent(BuildContext context) => AppColors.of(context).primaryLight;

  @override
  String get rightTitle => 'Ortalama Süre';

  @override
  String get rightValue => averageMinutes == 0 ? '—' : '${averageMinutes.toStringAsFixed(0)} dk';

  @override
  String get rightSubtitle => 'Deneme süresi';

  @override
  Color rightAccent(BuildContext context) => AppColors.of(context).warning;
}

class _QuestionMetrics implements _AnalysisMetrics {
  _QuestionMetrics({
    required this.accuracy,
    required this.avgMinutesPerQuestion,
    required this.trend,
    required this.delta,
    required this.totalQuestions,
    required this.axisLabels,
  });

  final double accuracy;
  final double avgMinutesPerQuestion;
  final int totalQuestions;
  @override
  final List<double> trend;
  @override
  final double delta;
  @override
  final List<String> axisLabels;

  static _QuestionMetrics from(
List<QuestionEntry> entries,
    DateTime start,
    DateTime end,
  ) {
    final totalCorrect = entries.fold<int>(0, (sum, e) => sum + e.correct);
    final totalQuestions = entries.fold<int>(0, (sum, e) => sum + e.total);
    final totalMinutes = entries.fold<int>(0, (sum, e) => sum + e.minutes);
    final accuracy = totalQuestions == 0
        ? 0.0
        : totalCorrect.toDouble() / totalQuestions;
    final avgMinutes = totalQuestions == 0
        ? 0.0
        : totalMinutes.toDouble() / totalQuestions;
    final trend = _buildQuestionTrend(entries, start, end);

    final daysDifference = end.difference(start).inDays;
List<String> labels;
    
    if (daysDifference <= 8) {
       labels = List.generate(daysDifference, (i) {
        final d = start.add(Duration(days: i));
        return _getWeekdayLabel(d.weekday);
      });
    } else {
       // Show Start - Mid - End
       labels = [
         '${start.day}.${start.month}',
         '${start.add(Duration(days: daysDifference ~/ 2)).day}.${start.add(Duration(days: daysDifference ~/ 2)).month}',
         '${end.subtract(const Duration(days: 1)).day}.${end.subtract(const Duration(days: 1)).month}',
       ];
    }

    return _QuestionMetrics(
      accuracy: accuracy,
      avgMinutesPerQuestion: avgMinutes,
      trend: trend,
      delta: _calculateDelta(trend),
      totalQuestions: totalQuestions,
      axisLabels: labels,
    );
  }

  @override
  String get title => 'Soru Gidişatı';

  @override
  String get value => trend.isEmpty ? '0' : trend.last.toStringAsFixed(0);

  @override
  String get unit => 'Soru';

  @override
  Color accent(BuildContext context) => AppColors.of(context).primaryLight;

  @override
  String get leftTitle => 'Doğruluk Oranı';

  @override
  String get leftValue => accuracy == 0 ? '—' : '%${(accuracy * 100).round()}';

  @override
  String get leftSubtitle => 'Soru doğruluğu';

  @override
  Color leftAccent(BuildContext context) => AppColors.of(context).success;

  @override
  String get rightTitle => 'Ortalama Süre';

  @override
  String get rightValue => avgMinutesPerQuestion == 0
      ? '—'
      : _formatAverageMinutes(avgMinutesPerQuestion);

  @override
  String get rightSubtitle => 'Soru başına';

  @override
  Color rightAccent(BuildContext context) => AppColors.of(context).warning;
}

List<double> _buildQuestionTrend(
List<QuestionEntry> entries,
  DateTime start,
  DateTime end,
) {
  final daysDifference = end.difference(start).inDays;
  final totals = <double>[];
  for (var i = 0; i < daysDifference; i++) {
    final day = start.add(Duration(days: i));
    final total = entries
        .where((e) => _isSameDay(e.createdAt, day))
        .fold<int>(0, (sum, e) => sum + e.total);
    totals.add(total.toDouble());
  }
  return totals;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
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

double _calculateDelta(List<double> values) {
  if (values.length < 2) {
    return 0;
  }
  final start = values.first == 0 ? 1 : values.first;
  return (values.last - start) / start;
}

String _formatAverageMinutes(double minutes) {
  if (minutes < 1) {
    final seconds = (minutes * 60).round();
    return '$seconds sn';
  }
  return '${minutes.toStringAsFixed(2)} dk';
}

List<_SubjectBar> _buildSubjectMinutes(List<QuestionEntry> entries) {
  final totals = <String, int>{};
  for (final entry in entries) {
    totals.update(entry.subject, (value) => value + entry.minutes,
        ifAbsent: () => entry.minutes);
  }
  if (totals.isEmpty) {
    return [];
  }
  final maxValue = totals.values.reduce(max);
  final items = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return items
      .map(
        (item) => _SubjectBar(
          subject: item.key,
          value: maxValue == 0 ? 0 : item.value / maxValue,
          label: '${item.value} dk',
        ),
      )
      .toList();
}

Map<String, int> _buildWrongTagCounts(List<QuestionEntry> entries) {
  final counts = <String, int>{};
  for (final entry in entries) {
    for (final tag in entry.errorTags) {
      counts.update(tag, (value) => value + 1, ifAbsent: () => 1);
    }
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return {
    for (final entry in sorted.take(4)) entry.key: entry.value,
  };
}

List<_ExamBranchStat> _buildExamBranchStats(List<MockExam> exams) {
  final netTotals = <String, double>{};
  final minuteTotals = <String, int>{};
  final counts = <String, int>{};
  for (final exam in exams) {
    exam.subjectNets.forEach((subject, net) {
      netTotals.update(subject, (value) => value + net, ifAbsent: () => net);
      counts.update(subject, (value) => value + 1, ifAbsent: () => 1);
    });
    exam.subjectMinutes.forEach((subject, minutes) {
      minuteTotals.update(subject, (value) => value + minutes,
          ifAbsent: () => minutes);
    });
  }
  if (netTotals.isEmpty) {
    return [];
  }
  final stats = <_ExamBranchStat>[];
  for (final subject in netTotals.keys) {
    final count = counts[subject] ?? 1;
    final avgNet = netTotals[subject]! / count;
    final avgMinutes =
        (minuteTotals[subject] ?? 0) / max(count, 1);
    stats.add(
      _ExamBranchStat(
        subject: subject,
        avgNet: avgNet,
        avgMinutes: avgMinutes.toDouble(),
      ),
    );
  }
  stats.sort((a, b) => b.avgNet.compareTo(a.avgNet));
  return stats;
}

List<MockExam> _recentExams(List<MockExam> exams, {int limit = 5}) {
  final sorted = [...exams]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted.take(limit).toList();
}
