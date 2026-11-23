import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kistas/core/data/database_service.dart';
import 'package:kistas/core/data/entities/flashcard_entity.dart';
import 'package:kistas/core/data/entities/mock_exam_entity.dart';
import 'package:kistas/core/data/entities/notification_entity.dart';
import 'package:kistas/core/data/entities/question_entity.dart';
import 'package:kistas/core/data/entities/topic_entity.dart';
import 'package:kistas/core/data/exam_presets.dart';
import 'package:kistas/core/models/exam_profile.dart';
import 'package:kistas/core/models/flashcard.dart';
import 'package:kistas/core/models/mock_exam.dart';
import 'package:kistas/core/models/question_entry.dart';
import 'package:kistas/core/models/study_schedule_block.dart';
import 'package:kistas/core/models/topic_summary.dart';
import 'package:kistas/core/repositories/app_repository.dart';
import 'package:kistas/core/theme/app_theme.dart';
import 'package:kistas/features/analysis/screens/analysis_screen.dart';
import 'package:kistas/features/curriculum/screens/curriculum_hub_screen.dart';
import 'package:kistas/features/dashboard/screens/home_screen.dart';
import 'package:kistas/features/dashboard/screens/main_screen.dart';
import 'package:kistas/features/questions/screens/entry_wizard_screen.dart';
import 'package:kistas/features/questions/screens/topic_summaries_screen.dart';
import 'package:kistas/features/schedule/screens/weekly_schedule_screen.dart';

class _InMemoryDatabaseService extends DatabaseService {
  final List<QuestionEntity> _questions = [];
  final List<MockExamEntity> _exams = [];
  final Map<String, TopicEntity> _topics = {};
  final Map<String, FlashcardEntity> _flashcards = {};
  final List<NotificationEntity> _notifications = [];

  @override
  Future<void> init() async {}

  @override
  Future<List<QuestionEntity>> getAllQuestions() async {
    final copy = [..._questions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  Future<void> addQuestion(QuestionEntity entity) async {
    _questions.removeWhere((q) => q.originalId == entity.originalId);
    _questions.add(entity);
  }

  @override
  Future<void> deleteQuestion(String originalId) async {
    _questions.removeWhere((q) => q.originalId == originalId);
  }

  @override
  Future<void> markQuestionAsSolved(String originalId) async {
    for (final q in _questions) {
      if (q.originalId == originalId) q.isSolved = true;
    }
  }

  @override
  Future<List<MockExamEntity>> getAllMockExams() async {
    final copy = [..._exams]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  Future<void> addMockExam(MockExamEntity entity) async {
    _exams.removeWhere((e) => e.originalId == entity.originalId);
    _exams.add(entity);
  }

  @override
  Future<void> deleteMockExam(String originalId) async {
    _exams.removeWhere((e) => e.originalId == originalId);
  }

  @override
  Future<List<TopicEntity>> getAllTopics() async => _topics.values.toList();

  @override
  Future<void> saveTopic(TopicEntity entity) async {
    _topics[entity.originalId] = entity;
  }

  @override
  Future<void> saveTopics(List<TopicEntity> entities) async {
    for (final e in entities) {
      _topics[e.originalId] = e;
    }
  }

  @override
  Future<void> deleteTopic(String originalId) async {
    _topics.remove(originalId);
  }

  @override
  Future<void> deleteTopicsByIds(List<String> originalIds) async {
    for (final id in originalIds) {
      _topics.remove(id);
    }
  }

  @override
  Future<List<FlashcardEntity>> getAllFlashcards() async =>
      _flashcards.values.toList();

  @override
  Future<void> saveFlashcard(FlashcardEntity entity) async {
    _flashcards[entity.originalId] = entity;
  }

  @override
  Future<void> deleteFlashcard(String originalId) async {
    _flashcards.remove(originalId);
  }

  @override
  Future<void> clearFlashcardsForTopic(String topicTitle) async {
    _flashcards.removeWhere((_, v) => v.topicTitle == topicTitle);
  }

  @override
  Future<List<NotificationEntity>> getAllNotifications() async =>
      [..._notifications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<void> addNotification(NotificationEntity entity) async {
    _notifications.add(entity);
  }

  @override
  Future<void> markNotificationRead(String originalId) async {
    for (final n in _notifications) {
      if (n.originalId == originalId) n.unread = false;
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    for (final n in _notifications) {
      n.unread = false;
    }
  }

  @override
  Future<void> clearNotifications() async {
    _notifications.clear();
  }

  @override
  Future<void> clearAllData() async {
    _questions.clear();
    _exams.clear();
    _topics.clear();
    _flashcards.clear();
    _notifications.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Exam Presets Catalog', () {
    test('contains all 16 curated exam presets including Maarif Modeli TYT/AYT', () {
      final presetNames = examCatalogPresets.map((p) => p.name).toSet();
      expect(
        presetNames,
        containsAll([
          'KPSS Lisans',
          'KPSS Önlisans',
          'KPSS Ortaöğretim',
          'KPSS Eğitim Bilimleri',
          'TYT',
          'AYT Sayısal',
          'AYT Eşit Ağırlık',
          'AYT Sözel',
          'YDS',
          'YDT',
          'DGS',
          'ALES',
          'TYT (Maarif Modeli)',
          'AYT Sayısal (Maarif Modeli)',
          'AYT Eşit Ağırlık (Maarif Modeli)',
          'AYT Sözel (Maarif Modeli)',
        ]),
      );

      final maarifSay = examCatalogPresets.firstWhere(
        (p) => p.id == 'ayt-sayisal-maarif',
      );
      final mathTitles = maarifSay.subjects['Maarif AYT Matematik']!
          .map((e) => e.title)
          .toList();
      expect(
        mathTitles.any((t) => t.contains('Değişimin Matematiği')),
        isTrue,
      );
      expect(
        mathTitles.any((t) => t.toLowerCase().contains('integral')),
        isFalse,
      );

      for (final preset in examCatalogPresets) {
        expect(preset.subjects.isNotEmpty, isTrue, reason: preset.name);
        expect(preset.totalTopics, greaterThan(0), reason: preset.name);
        final summaries = preset.toTopicSummaries();
        final uniqueIds = summaries.map((s) => s.id).toSet();
        expect(uniqueIds.length, summaries.length, reason: preset.name);
      }
    });
  });

  group('AppRepository General Platform & Schedule Logic', () {
    late AppRepository repo;
    late _InMemoryDatabaseService db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = _InMemoryDatabaseService();
      repo = await AppRepository.init(db);
    });

    test('does not force-reseed KPSS when empty or after deletion', () async {
      expect(repo.topics, isEmpty);

      final added = await repo.addCourseTopics(
        subject: 'Veri Yapıları',
        topicTitles: ['Ağaçlar', 'Graflar'],
        tag: 'Üniversite',
      );
      expect(added, 2);
      expect(repo.topics.length, 2);

      await repo.deleteUserTopics(repo.topics.map((t) => t.id).toList());
      expect(repo.topics, isEmpty);
    });

    test('mixes presets freely, deduplicates, and applies per-exam net rules', () async {
      final tyt = examCatalogPresets.firstWhere((p) => p.id == 'tyt');
      final yds = examCatalogPresets.firstWhere((p) => p.id == 'yds');

      final addedTyt = await repo.importExamPreset(
        tyt,
        selectedSubjects: {'TYT Matematik'},
      );
      expect(addedTyt, greaterThan(0));

      // Re-importing same subject adds 0 duplicates
      final dupAdded = await repo.importExamPreset(
        tyt,
        selectedSubjects: {'TYT Matematik'},
      );
      expect(dupAdded, 0);

      final addedYds = await repo.importExamPreset(yds);
      expect(addedYds, greaterThan(0));

      expect(repo.availableTags, containsAll(['TYT', 'YDS']));
      expect(repo.calculateNet(30, 4, tag: 'TYT'), closeTo(29.0, 0.001));
      expect(repo.calculateNet(30, 4, tag: 'YDS'), closeTo(30.0, 0.001));
    });

    test('clearTopicNotes preserves topic while removing summary and notes', () async {
      await repo.addUserTopic(
        const TopicSummary(
          id: 't-keep',
          subject: 'Fizik',
          title: 'Optik',
          nextReview: '',
          summary: 'Kısa özet',
          notes: ['Not 1'],
          tag: 'TYT',
        ),
      );

      await repo.clearTopicNotes('t-keep');
      expect(repo.topics.length, 1);
      expect(repo.topics.first.title, 'Optik');
      expect(repo.topics.first.summary, isEmpty);
      expect(repo.topics.first.notes, isEmpty);
    });

    test('weekly schedule supports add, reorder, cross-day move, toggle, and reset', () async {
      await repo.addScheduleBlock(
        const StudyScheduleBlock(
          id: 'b1',
          weekday: DateTime.monday,
          subject: 'Matematik',
          durationMinutes: 60,
        ),
      );
      await repo.addScheduleBlock(
        const StudyScheduleBlock(
          id: 'b2',
          weekday: DateTime.monday,
          subject: 'YDS',
          durationMinutes: 45,
        ),
      );

      expect(repo.scheduleForDay(DateTime.monday).map((b) => b.id).toList(), [
        'b1',
        'b2',
      ]);

      await repo.reorderScheduleDay(DateTime.monday, 0, 2);
      expect(repo.scheduleForDay(DateTime.monday).map((b) => b.id).toList(), [
        'b2',
        'b1',
      ]);

      await repo.moveScheduleBlock('b1', DateTime.wednesday);
      expect(repo.scheduleForDay(DateTime.monday).length, 1);
      expect(repo.scheduleForDay(DateTime.wednesday).first.id, 'b1');

      await repo.toggleScheduleBlockCompleted('b1');
      expect(repo.scheduleForDay(DateTime.wednesday).first.isCompleted, isTrue);

      await repo.resetWeeklyCompletion();
      expect(repo.scheduleForDay(DateTime.wednesday).first.isCompleted, isFalse);
    });

    test('entriesForTopic isolates same-named topics across different subjects', () async {
      await repo.addQuestionEntry(
        QuestionEntry(
          id: 'q-mat',
          bookName: 'Kitap 1',
          subject: 'Matematik',
          topic: 'Analitik Geometri',
          correct: 10,
          wrong: 0,
          blank: 0,
          minutes: 15,
          note: '',
          createdAt: DateTime.now(),
        ),
      );
      await repo.addQuestionEntry(
        QuestionEntry(
          id: 'q-geo',
          bookName: 'Kitap 2',
          subject: 'Geometri',
          topic: 'Analitik Geometri',
          correct: 5,
          wrong: 5,
          blank: 0,
          minutes: 15,
          note: '',
          createdAt: DateTime.now(),
        ),
      );

      final matOnly =
          repo.entriesForTopic('Analitik Geometri', subject: 'Matematik');
      expect(matOnly.length, 1);
      expect(matOnly.first.id, 'q-mat');
    });

    test('streak preserves yesterday active streak before first entry today', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      await repo.addQuestionEntry(
        QuestionEntry(
          id: 'q-y',
          bookName: '',
          subject: 'Fizik',
          topic: 'Optik',
          correct: 10,
          wrong: 2,
          blank: 0,
          minutes: 10,
          note: '',
          createdAt: yesterday,
        ),
      );
      await repo.addQuestionEntry(
        QuestionEntry(
          id: 'q-2d',
          bookName: '',
          subject: 'Fizik',
          topic: 'Optik',
          correct: 10,
          wrong: 2,
          blank: 0,
          minutes: 10,
          note: '',
          createdAt: twoDaysAgo,
        ),
      );

      expect(repo.calculateCurrentStreak(), 2);
    });

    test('backup/restore preserves flashcards, Leitner meta, profiles, and schedule, and clearAll wipes DB', () async {
      await repo.upsertExamProfile(
        ExamProfile(
          name: 'YDS',
          examDate: DateTime(2026, 11, 29),
          wrongPenalty: 0.0,
        ),
      );
      await repo.addScheduleBlock(
        const StudyScheduleBlock(
          id: 'sched-1',
          weekday: DateTime.tuesday,
          subject: 'Grammar',
          tag: 'YDS',
        ),
      );
      await repo.saveFlashcards('Tenses', [
        Flashcard(
          id: 'fc-1',
          question: 'Past Perfect?',
          answer: 'had + V3',
          hint: 'Earlier past action',
          box: 3,
          nextReview: DateTime(2026, 12, 1),
          isLearned: true,
          topicTitle: 'Tenses',
        ),
      ]);

      final exported = repo.exportData();

      await repo.clearAll();
      expect(repo.topics, isEmpty);
      expect(repo.weeklySchedule.value, isEmpty);
      expect(repo.examProfiles.value, isEmpty);
      expect(repo.flashcards.value, isEmpty);
      expect(await db.getAllFlashcards(), isEmpty);

      await repo.importData(exported);
      expect(repo.weeklySchedule.value.length, 1);
      expect(repo.examProfiles.value.first.name, 'YDS');
      final restoredCard = repo.flashcards.value['Tenses']!.first;
      expect(restoredCard.hint, 'Earlier past action');
      expect(restoredCard.box, 3);
      expect(restoredCard.isLearned, isTrue);
    });
  });

  group('UI Widget Smoke Tests', () {
    Widget wrapWithApp(AppRepository repo, Widget child) {
      return AppRepositoryScope(
        repository: repo,
        child: ValueListenableBuilder<String>(
          valueListenable: repo.themeKey,
          builder: (_, key, __) => MaterialApp(
            theme: buildAppTheme(key),
            home: child,
          ),
        ),
      );
    }

    testWidgets('CurriculumHubScreen shows presets, manual, and AI tabs', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());

      await tester.pumpWidget(wrapWithApp(repo, const CurriculumHubScreen()));
      await tester.pump();

      expect(find.text('Ders & Müfredat Merkezi'), findsOneWidget);
      expect(find.text('KPSS Lisans'), findsOneWidget);
      expect(find.text('Hazır Paketler'), findsOneWidget);

      await tester.tap(find.text('Özel Ders'));
      await tester.pump();
      expect(find.text('Yeni Ders veya Konu Ekle'), findsOneWidget);

      await tester.tap(find.text('AI Oluştur'));
      await tester.pump();
      expect(find.text('AI Ders & Konu Oluşturucu'), findsOneWidget);
    });

    testWidgets('WeeklyScheduleScreen renders 7 day targets and toggles overview', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      await repo.addCourseTopics(
        subject: 'Matematik',
        topicTitles: ['Türev'],
        tag: 'AYT Sayısal',
      );

      await tester.pumpWidget(wrapWithApp(repo, const WeeklyScheduleScreen()));
      await tester.pump();

      expect(find.text('Haftalık Program'), findsOneWidget);
      expect(find.text('Pzt'), findsOneWidget);
      expect(find.text('Paz'), findsOneWidget);
      expect(find.text('Matematik'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.calendar_view_week));
      await tester.pump();
      expect(find.textContaining('Pazartesi'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Pazar'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining('Pazar'), findsOneWidget);
    });

    testWidgets('WeeklyScheduleScreen navigates future weeks and toggles Konu palette', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      await repo.addCourseTopics(
        subject: 'Fizik',
        topicTitles: ['Akışkanlar'],
        tag: 'TYT (Maarif Modeli)',
      );

      await tester.pumpWidget(wrapWithApp(repo, const WeeklyScheduleScreen()));
      await tester.pump();

      expect(find.text('Bu Hafta'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(find.textContaining('Gelecek Hafta'), findsOneWidget);

      await tester.tap(find.text('Konu'));
      await tester.pump();
      expect(find.text('Fizik • Akışkanlar'), findsOneWidget);
    });

    testWidgets('CurriculumHubScreen filters Maarif Modeli presets', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());

      await tester.pumpWidget(wrapWithApp(repo, const CurriculumHubScreen()));
      await tester.pump();

      await tester.tap(find.text('Maarif'));
      await tester.pump();
      expect(find.text('TYT (Maarif Modeli)'), findsOneWidget);
      expect(find.text('AYT Sayısal (Maarif Modeli)'), findsOneWidget);
    });

    testWidgets('EntryWizardScreen mockExam mode supports Konu Denemesi', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      await repo.addCourseTopics(
        subject: 'Matematik',
        topicTitles: ['Limit ve Süreklilik'],
        tag: 'AYT Sayısal (Maarif Modeli)',
      );

      await tester.pumpWidget(
        wrapWithApp(repo, const EntryWizardScreen(type: EntryType.mockExam)),
      );
      await tester.pump();

      expect(find.text('Konu Denemesi'), findsOneWidget);
      await tester.tap(find.text('Konu Denemesi'));
      await tester.pump();
      expect(find.text('Deneme Konusu'), findsOneWidget);
    });

    test('periodic schedule blocks and topic mock exams persist across weeks and backup', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());

      final week0 = DateTime(2026, 11, 23); // Monday
      final week1 = week0.add(const Duration(days: 7));
      final week2 = week0.add(const Duration(days: 14));
      final week0Key = StudyScheduleBlock.weekKeyFor(week0);
      final week1Key = StudyScheduleBlock.weekKeyFor(week1);

      await repo.addScheduleBlock(
        StudyScheduleBlock(
          id: 'wk-weekly',
          weekday: DateTime.monday,
          subject: 'Matematik',
          topic: 'Türev',
          recurrence: ScheduleRecurrence.weekly,
          startWeekKey: week0Key,
          videoUrl: 'https://youtu.be/example',
          imagePaths: const ['/tmp/note1.jpg'],
        ),
      );
      await repo.addScheduleBlock(
        StudyScheduleBlock(
          id: 'wk-biweekly',
          weekday: DateTime.monday,
          subject: 'Fizik',
          topic: 'Optik',
          recurrence: ScheduleRecurrence.biweekly,
          startWeekKey: week0Key,
        ),
      );
      await repo.addScheduleBlock(
        StudyScheduleBlock(
          id: 'wk-once',
          weekday: DateTime.monday,
          subject: 'Tarih',
          topic: 'İnkılap',
          recurrence: ScheduleRecurrence.once,
          startWeekKey: week0Key,
        ),
      );

      expect(repo.scheduleForDay(DateTime.monday, weekMonday: week0).length, 3);
      expect(repo.scheduleForDay(DateTime.monday, weekMonday: week1).map((b) => b.id).toList(), ['wk-weekly']);
      expect(repo.scheduleForDay(DateTime.monday, weekMonday: week2).map((b) => b.id).toSet(), {'wk-weekly', 'wk-biweekly'});

      await repo.toggleScheduleBlockCompleted('wk-weekly', weekKey: week0Key);
      final weeklyBlock = repo.weeklySchedule.value.firstWhere((b) => b.id == 'wk-weekly');
      expect(weeklyBlock.isCompletedForWeek(week0Key), isTrue);
      expect(weeklyBlock.isCompletedForWeek(week1Key), isFalse);
      expect(weeklyBlock.videoUrl, 'https://youtu.be/example');
      expect(weeklyBlock.imagePaths, ['/tmp/note1.jpg']);

      await repo.addMockExam(
        MockExam(
          id: 'kd-1',
          title: 'Matematik • Türev Denemesi',
          dateLabel: '22 Kasım',
          correct: 18,
          wrong: 2,
          blank: 0,
          totalNet: 17.5,
          minutes: 25,
          note: '',
          createdAt: DateTime(2026, 11, 22),
          examType: 'AYT Sayısal (Maarif Modeli)',
          examScope: 'Konu Denemesi',
          focusSubject: 'Matematik',
          focusTopic: 'Türev',
          subjectNets: const {'Matematik': 17.5},
        ),
      );

      final exported = repo.exportData();
      await repo.clearAll();
      await repo.importData(exported);

      final restoredExam = repo.mockExams.value.first;
      expect(restoredExam.isTopicExam, isTrue);
      expect(restoredExam.examScope, 'Konu Denemesi');
      expect(restoredExam.focusSubject, 'Matematik');
      expect(restoredExam.focusTopic, 'Türev');
    });

    testWidgets('MainScreen renders empty state without crashing and preserves floating +', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());

      await tester.pumpWidget(wrapWithApp(repo, const MainScreen()));
      await tester.pump();

      expect(find.text('Panel'), findsOneWidget);
      expect(find.text('Konular'), findsOneWidget);
      expect(find.text('Ekle'), findsOneWidget);
      expect(find.text('Analiz'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsWidgets);
      expect(find.text('Ders Programı'), findsOneWidget);
    });

    testWidgets('HomeScreen defaults to paper light theme, toggles dark mode, and deletes with Undo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      expect(repo.themeKey.value, 'paper');

      await repo.addQuestionEntry(
        QuestionEntry(
          id: 'q-del-1',
          bookName: '345 Matematik',
          subject: 'Matematik',
          topic: 'Türev',
          correct: 18,
          wrong: 2,
          blank: 0,
          minutes: 20,
          note: '',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(wrapWithApp(repo, const Scaffold(body: HomeScreen())));
      await tester.pumpAndSettle();

      // 1-tap theme toggle in header switches paper -> night
      await tester.tap(find.byTooltip('Gece Moduna Geç'));
      await tester.pumpAndSettle();
      expect(repo.themeKey.value, 'night');

      await tester.scrollUntilVisible(
        find.text('345 Matematik'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('345 Matematik'), findsOneWidget);

      await tester.tap(find.text('345 Matematik'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaydı Sil'));
      await tester.pumpAndSettle();
      expect(find.text('Soru Kaydını Sil'), findsOneWidget);

      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();
      expect(repo.questionEntries.value, isEmpty);

      await tester.tap(find.text('Geri Al'));
      await tester.pumpAndSettle();
      expect(repo.questionEntries.value.length, 1);
      expect(repo.questionEntries.value.first.id, 'q-del-1');
    });

    testWidgets('AnalysisScreen lists mock exams in Kayıtlar tab and deletes with confirmation', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      await repo.addMockExam(
        MockExam(
          id: 'ex-del-1',
          title: 'TYT Konu Denemesi #1',
          dateLabel: '22 Kasım',
          correct: 19,
          wrong: 1,
          blank: 0,
          totalNet: 18.75,
          minutes: 25,
          note: '',
          createdAt: DateTime.now(),
          examType: 'TYT',
          examScope: 'Konu Denemesi',
          focusSubject: 'Matematik',
          focusTopic: 'Fonksiyonlar',
          subjectNets: const {'Matematik': 18.75},
        ),
      );

      await tester.pumpWidget(
        wrapWithApp(repo, const Scaffold(body: AnalysisScreen())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kayıtlar (1)'));
      await tester.pumpAndSettle();
      expect(find.text('TYT Konu Denemesi #1'), findsOneWidget);

      await tester.tap(find.byTooltip('Denemeyi Sil'));
      await tester.pumpAndSettle();
      expect(find.text('Deneme Kaydını Sil'), findsOneWidget);

      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();
      expect(repo.mockExams.value, isEmpty);
    });

    testWidgets('WeeklyScheduleScreen deletes block directly with Undo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      final today = DateTime.now();
      await repo.addScheduleBlock(
        StudyScheduleBlock(
          id: 'blk-del-1',
          weekday: today.weekday,
          subject: 'Fizik',
          topic: 'Optik',
          startWeekKey: StudyScheduleBlock.weekKeyFor(today),
        ),
      );

      await tester.pumpWidget(wrapWithApp(repo, const WeeklyScheduleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Fizik • Optik'), findsOneWidget);
      await tester.tap(find.byTooltip('Görevi Sil'));
      await tester.pumpAndSettle();
      expect(find.text('Program Görevini Sil'), findsOneWidget);

      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();
      expect(repo.weeklySchedule.value, isEmpty);

      await tester.tap(find.text('Geri Al'));
      await tester.pumpAndSettle();
      expect(repo.weeklySchedule.value.length, 1);
    });

    testWidgets('TopicSummariesScreen deletes whole subject from management sheet', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      await repo.addCourseTopics(
        subject: 'Fizik',
        topicTitles: ['Optik', 'Dalgalar'],
        tag: 'TYT',
      );
      await repo.addCourseTopics(
        subject: 'Kimya',
        topicTitles: ['Atom'],
        tag: 'TYT',
      );

      await tester.pumpWidget(
        wrapWithApp(repo, const Scaffold(body: TopicSummariesScreen())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sınav & Ders Yönetimi'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dersler (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Fizik'), findsWidgets);
      await tester.tap(find.byTooltip('Dersi ve Konularını Kaldır').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dersi Kaldır'));
      await tester.pumpAndSettle();

      expect(repo.userTopics.value.map((t) => t.subject).toSet(), {'Kimya'});
    });

    test('syncExamPresetSubjects removes unchecked courses and keeps history', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      final tytMaarif = examCatalogPresets.firstWhere(
        (p) => p.id == 'tyt-maarif',
      );

      final initialAdded = await repo.importExamPreset(tytMaarif);
      expect(initialAdded, tytMaarif.totalTopics);
      expect(repo.profileForTag(tytMaarif.name), isNotNull);

      await repo.addQuestionEntry(
        QuestionEntry(
          id: 'hist-felsefe-1',
          subject: 'Maarif TYT Felsefe',
          topic: 'Felsefeyi Tanıma ve Düşünme-Akıl Yürütme',
          bookName: 'Soru Bankası',
          correct: 8,
          wrong: 2,
          blank: 0,
          minutes: 12,
          note: '',
          createdAt: DateTime.now(),
        ),
      );

      final keepSubjects = Set<String>.from(tytMaarif.subjects.keys)
        ..remove('Maarif TYT Felsefe')
        ..remove('Maarif TYT Din Kültürü');

      final diff = await repo.syncExamPresetSubjects(
        tytMaarif,
        selectedSubjects: keepSubjects,
      );
      expect(diff.added, 0);
      expect(diff.removed, greaterThan(0));

      final remainingSubjects = repo.userTopics.value
          .where((t) => t.tag == tytMaarif.name)
          .map((t) => t.subject)
          .toSet();
      expect(remainingSubjects, keepSubjects);
      expect(remainingSubjects.contains('Maarif TYT Felsefe'), isFalse);
      expect(remainingSubjects.contains('Maarif TYT Din Kültürü'), isFalse);
      // Past question history must be preserved
      expect(repo.questionEntries.value.length, 1);

      // Re-adding a removed subject restores its topics
      final reAddDiff = await repo.syncExamPresetSubjects(
        tytMaarif,
        selectedSubjects: {...keepSubjects, 'Maarif TYT Felsefe'},
      );
      expect(reAddDiff.added, tytMaarif.subjects['Maarif TYT Felsefe']!.length);
      expect(reAddDiff.removed, 0);

      // Removing the full preset removes all topics and its exam profile
      final removedAll = await repo.removeExamPreset(tytMaarif);
      expect(removedAll, greaterThan(0));
      expect(
        repo.userTopics.value.where((t) => t.tag == tytMaarif.name),
        isEmpty,
      );
      expect(repo.profileForTag(tytMaarif.name), isNull);
      expect(repo.questionEntries.value.length, 1);
    });

    test('deleteSubject with tag only removes subject from target package', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      await repo.addCourseTopics(
        subject: 'Matematik',
        topicTitles: ['Sayılar'],
        tag: 'TYT',
      );
      await repo.addCourseTopics(
        subject: 'Matematik',
        topicTitles: ['Türev'],
        tag: 'AYT',
      );

      final removed = await repo.deleteSubject('Matematik', tag: 'TYT');
      expect(removed, 1);
      expect(repo.userTopics.value.length, 1);
      expect(repo.userTopics.value.first.tag, 'AYT');
      expect(repo.userTopics.value.first.title, 'Türev');
    });

    testWidgets('CurriculumHubScreen removes unwanted courses from imported preset', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      final tytMaarif = examCatalogPresets.firstWhere(
        (p) => p.id == 'tyt-maarif',
      );
      await repo.importExamPreset(tytMaarif);

      await tester.pumpWidget(wrapWithApp(repo, const CurriculumHubScreen()));
      await tester.pumpAndSettle();

      // Loaded preset should appear at top with edit & remove buttons
      expect(find.text('Dersleri Düzenle'), findsOneWidget);
      expect(find.text('Paketi Kaldır'), findsOneWidget);

      // Open two-way subject editor and uncheck 'Maarif TYT Felsefe'
      await tester.tap(find.text('Dersleri Düzenle'));
      await tester.pumpAndSettle();
      expect(find.text('${tytMaarif.name} — Dersleri Düzenle'), findsOneWidget);

      final felsefeTile =
          find.widgetWithText(CheckboxListTile, 'Maarif TYT Felsefe');
      await tester.scrollUntilVisible(
        felsefeTile,
        150,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(felsefeTile);
      await tester.pumpAndSettle();

      expect(find.text('Kaldırılacak'), findsOneWidget);
      expect(find.text('1 Dersi Kaldır'), findsOneWidget);

      await tester.tap(find.text('1 Dersi Kaldır'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Kaldır'));
      await tester.pumpAndSettle();

      final remainingAfterEdit = repo.userTopics.value
          .where((t) => t.tag == tytMaarif.name)
          .map((t) => t.subject)
          .toSet();
      expect(remainingAfterEdit.contains('Maarif TYT Felsefe'), isFalse);
      expect(remainingAfterEdit.contains('Maarif TYT Matematik'), isTrue);

      // Also verify 1-tap removal directly from a loaded subject chip on the card
      await tester.tap(find.text('Maarif TYT Din Kültürü').first);
      await tester.pumpAndSettle();
      expect(find.text('Dersi Kaldır: Maarif TYT Din Kültürü'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Kaldır'));
      await tester.pumpAndSettle();

      final remainingAfterChip = repo.userTopics.value
          .where((t) => t.tag == tytMaarif.name)
          .map((t) => t.subject)
          .toSet();
      expect(remainingAfterChip.contains('Maarif TYT Din Kültürü'), isFalse);
      expect(remainingAfterChip.contains('Maarif TYT Matematik'), isTrue);
    });

    test('week-scoped daily & every-two-days recurrences isolate days and weeks', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      final thisMonday = DateTime(2026, 11, 23);
      final nextMonday = DateTime(2026, 11, 30);
      final weekKey = StudyScheduleBlock.weekKeyFor(thisMonday);

      final dailyBlock = StudyScheduleBlock(
        id: 'daily-1',
        weekday: DateTime.monday,
        subject: 'Paragraf',
        recurrence: ScheduleRecurrence.dailyInWeek,
        startWeekKey: weekKey,
      );
      final everyTwoDaysBlock = StudyScheduleBlock(
        id: 'two-days-1',
        weekday: DateTime.tuesday,
        subject: 'Geometri',
        recurrence: ScheduleRecurrence.everyTwoDaysInWeek,
        startWeekKey: weekKey,
      );

      await repo.addScheduleBlock(dailyBlock);
      await repo.addScheduleBlock(everyTwoDaysBlock);

      // Daily block appears on all 7 days of anchor week, never next week
      for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
        final subjects = repo
            .scheduleForDay(day, weekMonday: thisMonday)
            .map((b) => b.subject)
            .toList();
        expect(subjects.contains('Paragraf'), isTrue);
        expect(
          repo.scheduleForDay(day, weekMonday: nextMonday),
          isEmpty,
        );
      }

      // Every-two-days starting Tuesday appears ONLY on Tue (2), Thu (4), Sat (6)
      for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
        final hasGeo = repo
            .scheduleForDay(day, weekMonday: thisMonday)
            .any((b) => b.subject == 'Geometri');
        expect(hasGeo, [2, 4, 6].contains(day));
      }

      // Per-day completion toggles Monday without affecting Tuesday
      await repo.toggleScheduleBlockCompleted(
        'daily-1',
        weekKey: weekKey,
        weekday: DateTime.monday,
      );
      final updatedDaily =
          repo.weeklySchedule.value.firstWhere((b) => b.id == 'daily-1');
      expect(
        updatedDaily.isCompletedForWeek(weekKey, weekday: DateTime.monday),
        isTrue,
      );
      expect(
        updatedDaily.isCompletedForWeek(weekKey, weekday: DateTime.tuesday),
        isFalse,
      );

      // JSON round-trip preserves recurrence and per-day completion keys
      final roundTrip = StudyScheduleBlock.fromJson(updatedDaily.toJson());
      expect(roundTrip.recurrence, ScheduleRecurrence.dailyInWeek);
      expect(
        roundTrip.isCompletedForWeek(weekKey, weekday: DateTime.monday),
        isTrue,
      );
      expect(
        roundTrip.isCompletedForWeek(weekKey, weekday: DateTime.tuesday),
        isFalse,
      );

      // Weekly reset clears day-specific completion keys
      await repo.resetWeeklyCompletion(weekKey: weekKey);
      final resetDaily =
          repo.weeklySchedule.value.firstWhere((b) => b.id == 'daily-1');
      expect(
        resetDaily.isCompletedForWeek(weekKey, weekday: DateTime.monday),
        isFalse,
      );
    });

    test('copyScheduleBlockToDays duplicates task to chosen days independently', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      final thisMonday = DateTime(2026, 11, 23);
      final weekKey = StudyScheduleBlock.weekKeyFor(thisMonday);

      final source = StudyScheduleBlock(
        id: 'src-1',
        weekday: DateTime.monday,
        subject: 'Fizik',
        topic: 'Optik',
        videoUrl: 'https://youtu.be/demo',
        imagePaths: const ['/tmp/note.jpg'],
        recurrence: ScheduleRecurrence.weekly,
        startWeekKey: weekKey,
        completedWeeks: [weekKey],
      );
      await repo.addScheduleBlock(source);

      final count = await repo.copyScheduleBlockToDays(
        source,
        targetWeekdays: const [
          DateTime.wednesday,
          DateTime.friday,
          DateTime.sunday,
        ],
        targetWeekKey: weekKey,
      );
      expect(count, 3);
      expect(repo.weeklySchedule.value.length, 4);

      for (final day in [DateTime.wednesday, DateTime.friday, DateTime.sunday]) {
        final dayList = repo.scheduleForDay(day, weekMonday: thisMonday);
        expect(dayList.length, 1);
        expect(dayList.first.subject, 'Fizik');
        expect(dayList.first.topic, 'Optik');
        expect(dayList.first.videoUrl, 'https://youtu.be/demo');
        expect(dayList.first.imagePaths, ['/tmp/note.jpg']);
        expect(dayList.first.isCompletedForWeek(weekKey, weekday: day), isFalse);
      }

      // Copying a week-scoped multi-day task creates single-day 'once' copies
      final multiSource = StudyScheduleBlock(
        id: 'multi-1',
        weekday: DateTime.monday,
        subject: 'Kimya',
        recurrence: ScheduleRecurrence.dailyInWeek,
        startWeekKey: weekKey,
      );
      await repo.copyScheduleBlockToDays(
        multiSource,
        targetWeekdays: const [DateTime.tuesday, DateTime.thursday],
        targetWeekKey: weekKey,
      );
      final kimyaCopies =
          repo.weeklySchedule.value.where((b) => b.subject == 'Kimya').toList();
      expect(kimyaCopies.length, 2);
      expect(
        kimyaCopies.every((b) => b.recurrence == ScheduleRecurrence.once),
        isTrue,
      );
    });

    testWidgets('HomeScreen creates schedule with week-scoped recurrence and copies task to all days', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppRepository.init(_InMemoryDatabaseService());
      final now = DateTime.now();
      final monday = StudyScheduleBlock.mondayOf(now);
      final weekKey = StudyScheduleBlock.weekKeyFor(monday);

      // Seed one Monday task to test copying directly from HomeScreen
      await repo.addScheduleBlock(
        StudyScheduleBlock(
          id: 'home-copy-1',
          weekday: DateTime.monday,
          subject: 'Tarih',
          topic: 'Osmanlı',
          recurrence: ScheduleRecurrence.once,
          startWeekKey: weekKey,
        ),
      );

      await tester.pumpWidget(
        wrapWithApp(repo, const Scaffold(body: HomeScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ders Programı'), findsOneWidget);

      // Switch to Monday on HomeScreen's 7-day strip and copy 'Tarih' to all remaining days
      final pztPill = find.text('Pzt').first;
      await tester.ensureVisible(pztPill);
      await tester.tap(pztPill);
      await tester.pumpAndSettle();
      expect(find.text('Tarih • Osmanlı'), findsOneWidget);

      final copyBtn = find.byTooltip('Görevi Kopyala').first;
      await tester.ensureVisible(copyBtn);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();
      expect(find.text('Görevi Kopyala'), findsOneWidget);

      await tester.tap(find.text('Tüm Günler'));
      await tester.pumpAndSettle();
      expect(find.text('6 Güne Kopyala'), findsOneWidget);

      await tester.tap(find.text('6 Güne Kopyala'));
      await tester.pumpAndSettle();

      for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
        expect(
          repo
              .scheduleForDay(day, weekMonday: monday)
              .any((b) => b.subject == 'Tarih'),
          isTrue,
        );
      }

      // Now add a new '2 Günde Bir (Bu Hafta)' task directly from HomeScreen
      final addTaskPill = find.text('Görev').first;
      await tester.ensureVisible(addTaskPill);
      await tester.tap(addTaskPill);
      await tester.pumpAndSettle();
      expect(find.text('Çalışma Görevi Ekle'), findsOneWidget);

      await tester.tap(find.text('2 Günde Bir (Bu Hafta)'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bu haftaya özel günler (4): Pzt, Çar, Cum, Paz'),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Ders'),
        'Biyoloji',
      );
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(ElevatedButton, 'Ekle');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
        final hasBio = repo
            .scheduleForDay(day, weekMonday: monday)
            .any((b) => b.subject == 'Biyoloji');
        expect(hasBio, [1, 3, 5, 7].contains(day));
      }
    });
  });
}
