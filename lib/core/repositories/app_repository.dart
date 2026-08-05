import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database_service.dart';
import '../data/entities/flashcard_entity.dart';
import '../data/entities/mock_exam_entity.dart';
import '../data/entities/notification_entity.dart';
import '../data/entities/question_entity.dart';
import '../data/entities/topic_entity.dart';
import '../data/topic_catalog.dart';
import '../models/app_notification.dart';
import '../models/flashcard.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../models/topic_summary.dart';

const _dailyGoalKey = 'daily_goal';
const _geminiApiKey = 'gemini_api_key';
const _geminiModel = 'gemini_model';
const _aiGoalCadenceKey = 'ai_goal_cadence';
const _aiNotificationsEnabledKey = 'ai_notifications_enabled';
const _aiGoalTargetsKey = 'ai_goal_targets';
const _aiGoalUpdatedAtKey = 'ai_goal_updated_at';
const _aiProgramLastKey = 'ai_program_last';
const _aiProgramUpdatedAtKey = 'ai_program_updated_at';
const _reminderEnabledKey = 'reminder_enabled';
const _reminderTimeKey = 'reminder_time';
const _reminderLastShownKey = 'reminder_last_shown';
const _weeklyPlanEnabledKey = 'weekly_plan_enabled';
const _weeklyPlanTimeKey = 'weekly_plan_time';
const _weeklyPlanWeekdayKey = 'weekly_plan_weekday';
const _themeKey = 'theme_key';
const _examDateKey = 'exam_date';
const _focusRemainingKey = 'focus_remaining';

class AppRepository {
  AppRepository._(this._prefs, this._db)
      : questionEntries = ValueNotifier<List<QuestionEntry>>([]),
        mockExams = ValueNotifier<List<MockExam>>([]),
        flashcards = ValueNotifier<Map<String, List<Flashcard>>>({}),
        userTopics = ValueNotifier<List<TopicSummary>>([]),
        // Legacy support
        customTopics = ValueNotifier<Map<String, TopicSummary>>({}),
        dailyGoal = ValueNotifier<int>(100),
        aiRequestCountToday = ValueNotifier<int>(0),
        geminiApiKey = ValueNotifier<String>(''),
        geminiModel = ValueNotifier<String>(''),
        themeKey = ValueNotifier<String>('graphite'),
        examDate = ValueNotifier<DateTime>(DateTime(2026, 9, 6)),
        aiGoalCadence = ValueNotifier<String>('daily'),
        aiNotificationsEnabled = ValueNotifier<bool>(false),
        aiGoalTargets = ValueNotifier<Map<String, int>>({}),
        aiGoalUpdatedAt = ValueNotifier<DateTime?>(null),
        aiProgramLast = ValueNotifier<String?>(null),
        aiProgramUpdatedAt = ValueNotifier<DateTime?>(null),
        notifications = ValueNotifier<List<AppNotification>>([]),
        reminderEnabled = ValueNotifier<bool>(false),
        reminderTime = ValueNotifier<String>('20:00'),
        reminderLastShown = ValueNotifier<DateTime?>(null),
        weeklyPlanEnabled = ValueNotifier<bool>(false),
        weeklyPlanTime = ValueNotifier<String>('09:00'),
        weeklyPlanWeekday = ValueNotifier<int>(DateTime.monday),
        focusRemaining = ValueNotifier<int>(25 * 60),
        focusRunning = ValueNotifier<bool>(false) {
    _load();
  }

  final SharedPreferences _prefs;
  final DatabaseService _db;
  
  final ValueNotifier<List<QuestionEntry>> questionEntries;
  final ValueNotifier<List<MockExam>> mockExams;
  final ValueNotifier<Map<String, List<Flashcard>>> flashcards;
  final ValueNotifier<List<TopicSummary>> userTopics;
  final ValueNotifier<Map<String, TopicSummary>> customTopics; // Legacy
  final ValueNotifier<int> dailyGoal;
  final ValueNotifier<int> aiRequestCountToday;
  final ValueNotifier<String> geminiApiKey;
  final ValueNotifier<String> geminiModel;
  final ValueNotifier<String> themeKey;
  final ValueNotifier<DateTime> examDate;
  final ValueNotifier<String> aiGoalCadence;
  final ValueNotifier<bool> aiNotificationsEnabled;
  final ValueNotifier<Map<String, int>> aiGoalTargets;
  final ValueNotifier<DateTime?> aiGoalUpdatedAt;
  final ValueNotifier<String?> aiProgramLast;
  final ValueNotifier<DateTime?> aiProgramUpdatedAt;
  final ValueNotifier<List<AppNotification>> notifications;
  final ValueNotifier<bool> reminderEnabled;
  final ValueNotifier<String> reminderTime;
  final ValueNotifier<DateTime?> reminderLastShown;
  final ValueNotifier<bool> weeklyPlanEnabled;
  final ValueNotifier<String> weeklyPlanTime;
  final ValueNotifier<int> weeklyPlanWeekday;
  final ValueNotifier<int> focusRemaining;
  final ValueNotifier<bool> focusRunning;

  static Future<AppRepository> init(DatabaseService db) async {
    final prefs = await SharedPreferences.getInstance();
    return AppRepository._(prefs, db);
  }

  List<TopicSummary> get topics => userTopics.value;

  // --- TOPICS ---
  Future<void> addUserTopic(TopicSummary topic) async {
    await _db.saveTopic(_mapToTopicEntity(topic));
    await _refreshTopics();
  }

  Future<void> addUserTopics(List<TopicSummary> topics) async {
    final entities = topics.map(_mapToTopicEntity).toList();
    await _db.saveTopics(entities);
    await _refreshTopics();
  }

  Future<void> updateUserTopic(TopicSummary topic) async {
    await _db.saveTopic(_mapToTopicEntity(topic));
    await _refreshTopics();
  }

  Future<void> deleteUserTopic(String id) async {
    await _db.deleteTopic(id);
    await _refreshTopics();
  }

  Future<void> _refreshTopics() async {
    final entities = await _db.getAllTopics();
    if (entities.isEmpty) {
        await _db.saveTopics(kpssTopicCatalog.map(_mapToTopicEntity).toList());
        userTopics.value = kpssTopicCatalog;
    } else {
        userTopics.value = entities.map(_mapFromTopicEntity).toList();
    }
    // Sync customTopics for legacy support (if needed)
    customTopics.value = {for (var t in userTopics.value) t.id: t};
  }

  // --- QUESTIONS ---
  Future<void> addQuestionEntry(QuestionEntry entry) async {
    await _db.addQuestion(_mapToQuestionEntity(entry));
    await _refreshQuestions();
  }

  Future<void> deleteQuestionEntry(String id) async {
    await _db.deleteQuestion(id);
    await _refreshQuestions();
  }

  Future<void> _refreshQuestions() async {
    final entities = await _db.getAllQuestions();
    questionEntries.value = entities.map(_mapFromQuestionEntity).toList();
  }

  // --- MOCK EXAMS ---
  Future<void> addMockExam(MockExam exam) async {
    await _db.addMockExam(_mapToMockExamEntity(exam));
    await _refreshMockExams();
  }

  Future<void> _refreshMockExams() async {
    final entities = await _db.getAllMockExams();
    mockExams.value = entities.map(_mapFromMockExamEntity).toList();
  }

  // --- FLASHCARDS ---
  Future<void> saveFlashcards(String topicTitle, List<Flashcard> cards) async {
    await _db.clearFlashcardsForTopic(topicTitle);
    for (final card in cards) {
      final entity = _mapToFlashcardEntity(card, topicTitle);
      await _db.saveFlashcard(entity);
    }
    await _refreshFlashcards();
  }

  Future<void> clearFlashcards(String topicTitle) async {
    await _db.clearFlashcardsForTopic(topicTitle);
    await _refreshFlashcards();
  }

  Future<void> deleteFlashcard(String topicTitle, String cardId) async {
    await _db.deleteFlashcard(cardId);
    await _refreshFlashcards();
  }

  Future<void> _refreshFlashcards() async {
    final entities = await _db.getAllFlashcards();
    final grouped = <String, List<Flashcard>>{};
    for (final e in entities) {
      if (!grouped.containsKey(e.topicTitle)) {
        grouped[e.topicTitle] = [];
      }
      grouped[e.topicTitle]!.add(_mapFromFlashcardEntity(e));
    }
    flashcards.value = grouped;
  }

  Future<void> bulkUpdateUserTopics(List<TopicSummary> updatedList) async {
    final entities = updatedList.map(_mapToTopicEntity).toList();
    await _db.saveTopics(entities);
    await _refreshTopics();
  }

  String exportData() {
    final payload = {
      'questionEntries': questionEntries.value.map((e) => e.toJson()).toList(),
      'mockExams': mockExams.value.map((e) => e.toJson()).toList(),
      'flashcards': flashcards.value.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
      'userTopics': userTopics.value.map((e) => e.toJson()).toList(),
      'notifications': notifications.value.map((e) => e.toJson()).toList(),
      'aiGoalTargets': aiGoalTargets.value,
      'aiGoalUpdatedAt': aiGoalUpdatedAt.value?.toIso8601String(),
      'aiGoalCadence': aiGoalCadence.value,
      'aiNotificationsEnabled': aiNotificationsEnabled.value,
      'dailyGoal': dailyGoal.value,
      'aiProgramLast': aiProgramLast.value,
      'aiProgramUpdatedAt': aiProgramUpdatedAt.value?.toIso8601String(),
      'reminderEnabled': reminderEnabled.value,
      'reminderTime': reminderTime.value,
      'reminderLastShown': reminderLastShown.value?.toIso8601String(),
      'weeklyPlanEnabled': weeklyPlanEnabled.value,
      'weeklyPlanTime': weeklyPlanTime.value,
      'weeklyPlanWeekday': weeklyPlanWeekday.value,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return jsonEncode(payload);
  }

  Future<void> importData(String raw) async {
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic>) {
      throw FormatException('Geçersiz yedek formatı.');
    }
    
    // Import Questions
    final questionsRaw = data['questionEntries'];
    if (questionsRaw is List) {
      final questions = questionsRaw
          .whereType<Map<String, dynamic>>()
          .map(QuestionEntry.fromJson)
          .toList();
      for (final q in questions) {
        await _db.addQuestion(_mapToQuestionEntity(q));
      }
    }

    // Import Exams
    final examsRaw = data['mockExams'];
    if (examsRaw is List) {
      final exams = examsRaw
          .whereType<Map<String, dynamic>>()
          .map(MockExam.fromJson)
          .toList();
      for (final e in exams) {
        await _db.addMockExam(_mapToMockExamEntity(e));
      }
    }

    // Import Topics
    final topicsRaw = data['userTopics'];
    if (topicsRaw is List) {
       final topics = topicsRaw.map((e) => TopicSummary.fromJson(e)).toList();
       await addUserTopics(topics);
    }

    // Import Notifications
    final notificationsRaw = data['notifications'];
    if (notificationsRaw is List) {
      final notifs = notificationsRaw
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
      for (final n in notifs) {
        await _db.addNotification(_mapToNotificationEntity(n));
      }
    }
    
    // Import Settings
    final targetsRaw = data['aiGoalTargets'];
    final targets = <String, int>{};
    if (targetsRaw is Map) {
      for (final entry in targetsRaw.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null) {
           if (value is int) targets[key] = value;
           else if (value is num) targets[key] = value.round();
           else if (value is String) {
             final p = int.tryParse(value);
             if (p != null) targets[key] = p;
           }
        }
      }
    }
    aiGoalTargets.value = targets;
    await _prefs.setString(_aiGoalTargetsKey, jsonEncode(targets));

    // Other settings
    final updatedRaw = data['aiGoalUpdatedAt'] as String?;
    aiGoalUpdatedAt.value = updatedRaw == null ? null : DateTime.tryParse(updatedRaw);
    if (aiGoalUpdatedAt.value != null) {
        await _prefs.setString(_aiGoalUpdatedAtKey, aiGoalUpdatedAt.value!.toIso8601String());
    }

    aiGoalCadence.value = data['aiGoalCadence'] as String? ?? aiGoalCadence.value;
    await _prefs.setString(_aiGoalCadenceKey, aiGoalCadence.value);

    aiNotificationsEnabled.value = data['aiNotificationsEnabled'] as bool? ?? aiNotificationsEnabled.value;
    await _prefs.setBool(_aiNotificationsEnabledKey, aiNotificationsEnabled.value);

    aiProgramLast.value = data['aiProgramLast'] as String?;
    if (aiProgramLast.value != null) await _prefs.setString(_aiProgramLastKey, aiProgramLast.value!);

    final programUpdatedRaw = data['aiProgramUpdatedAt'] as String?;
    aiProgramUpdatedAt.value = programUpdatedRaw == null ? null : DateTime.tryParse(programUpdatedRaw);
    if (aiProgramUpdatedAt.value != null) {
       await _prefs.setString(_aiProgramUpdatedAtKey, aiProgramUpdatedAt.value!.toIso8601String());
    }

    reminderEnabled.value = data['reminderEnabled'] as bool? ?? reminderEnabled.value;
    await _prefs.setBool(_reminderEnabledKey, reminderEnabled.value);

    reminderTime.value = data['reminderTime'] as String? ?? reminderTime.value;
    await _prefs.setString(_reminderTimeKey, reminderTime.value);

    weeklyPlanEnabled.value = data['weeklyPlanEnabled'] as bool? ?? weeklyPlanEnabled.value;
    await _prefs.setBool(_weeklyPlanEnabledKey, weeklyPlanEnabled.value);

    weeklyPlanTime.value = data['weeklyPlanTime'] as String? ?? weeklyPlanTime.value;
    await _prefs.setString(_weeklyPlanTimeKey, weeklyPlanTime.value);

    weeklyPlanWeekday.value = data['weeklyPlanWeekday'] as int? ?? weeklyPlanWeekday.value;
    await _prefs.setInt(_weeklyPlanWeekdayKey, weeklyPlanWeekday.value);

    final importedDailyGoal = data['dailyGoal'];
    if (importedDailyGoal is int) {
      dailyGoal.value = importedDailyGoal;
    } else if (importedDailyGoal is num) {
      dailyGoal.value = importedDailyGoal.round();
    }
    await _prefs.setInt(_dailyGoalKey, dailyGoal.value);

    await _load();
  }

  Future<void> saveTopicUpdate(TopicSummary topic) async {
    await updateUserTopic(topic);
  }

  Future<void> deleteTopicUpdate(String topicId) async {
    await deleteUserTopic(topicId);
  }

  Future<void> clearAll() async {
    questionEntries.value = [];
    mockExams.value = [];
    notifications.value = [];
    // DB clearing is handled via DatabaseService.init with a flag if needed,
    // or we can add a method to DatabaseService to clear all tables.
    // For now, UI state clear is enough as requested.
  }

  // --- SETTINGS / PREFS ---

  Future<void> setDailyGoal(int value) async {
    final clamped = value.clamp(10, 500);
    dailyGoal.value = clamped;
    await _prefs.setInt(_dailyGoalKey, clamped);
  }

  Future<void> incrementAiRequestCount() async {
    final current = aiRequestCountToday.value;
    aiRequestCountToday.value = current + 1;
    await _prefs.setInt('ai_request_count_today', current + 1);
    await _prefs.setString('ai_request_last_date', DateTime.now().toIso8601String());
  }

  Future<void> setGeminiApiKey(String value) async {
    final trimmed = value.trim();
    geminiApiKey.value = trimmed;
    await _prefs.setString(_geminiApiKey, trimmed);
  }

  Future<void> setGeminiModel(String value) async {
    geminiModel.value = value;
    await _prefs.setString(_geminiModel, value);
  }

  Future<void> setTheme(String key) async {
    themeKey.value = key;
    await _prefs.setString(_themeKey, key);
  }

  Future<void> setExamDate(DateTime date) async {
    examDate.value = date;
    await _prefs.setString(_examDateKey, date.toIso8601String());
  }

  Future<void> setAiGoalCadence(String cadence) async {
    aiGoalCadence.value = cadence;
    await _prefs.setString(_aiGoalCadenceKey, cadence);
  }

  Future<void> setAiNotificationsEnabled(bool value) async {
    aiNotificationsEnabled.value = value;
    await _prefs.setBool(_aiNotificationsEnabledKey, value);
  }

  Future<void> setAiGoalTargets(Map<String, int> value) async {
    aiGoalTargets.value = value;
    await _prefs.setString(_aiGoalTargetsKey, jsonEncode(value));
  }

  Future<void> setAiGoalUpdatedAt(DateTime? value) async {
    aiGoalUpdatedAt.value = value;
    if (value == null) {
      await _prefs.remove(_aiGoalUpdatedAtKey);
      return;
    }
    await _prefs.setString(_aiGoalUpdatedAtKey, value.toIso8601String());
  }

  // --- NOTIFICATIONS ---
  Future<void> addNotification(AppNotification notification) async {
    await _db.addNotification(_mapToNotificationEntity(notification));
    await _refreshNotifications();
  }

  Future<void> markNotificationRead(String id) async {
    await _db.markNotificationRead(id);
    await _refreshNotifications();
  }

  Future<void> markAllNotificationsRead() async {
    await _db.markAllNotificationsRead();
    await _refreshNotifications();
  }

  Future<void> clearNotifications() async {
    await _db.clearNotifications();
    await _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    final entities = await _db.getAllNotifications();
    notifications.value = entities.map(_mapFromNotificationEntity).toList();
  }

  Future<void> setAiProgram(String? value) async {
    aiProgramLast.value = value;
    aiProgramUpdatedAt.value = value == null ? null : DateTime.now();
    if (value == null) {
      await _prefs.remove(_aiProgramLastKey);
      await _prefs.remove(_aiProgramUpdatedAtKey);
      return;
    }
    await _prefs.setString(_aiProgramLastKey, value);
    await _prefs.setString(
      _aiProgramUpdatedAtKey,
      aiProgramUpdatedAt.value!.toIso8601String(),
    );
  }

  Future<void> setReminderEnabled(bool value) async {
    reminderEnabled.value = value;
    await _prefs.setBool(_reminderEnabledKey, value);
  }

  Future<void> setReminderTime(String value) async {
    reminderTime.value = value;
    await _prefs.setString(_reminderTimeKey, value);
  }

  Future<void> setReminderLastShown(DateTime? value) async {
    reminderLastShown.value = value;
    if (value == null) {
      await _prefs.remove(_reminderLastShownKey);
      return;
    }
    await _prefs.setString(_reminderLastShownKey, value.toIso8601String());
  }

  Future<void> setWeeklyPlanEnabled(bool value) async {
    weeklyPlanEnabled.value = value;
    await _prefs.setBool(_weeklyPlanEnabledKey, value);
  }

  Future<void> setWeeklyPlanTime(String value) async {
    weeklyPlanTime.value = value;
    await _prefs.setString(_weeklyPlanTimeKey, value);
  }

  Future<void> setWeeklyPlanWeekday(int value) async {
    weeklyPlanWeekday.value = value;
    await _prefs.setInt(_weeklyPlanWeekdayKey, value);
  }

  // --- LOAD ---
  Future<void> _load() async {
    await _refreshQuestions();
    await _refreshMockExams();
    await _refreshTopics();
    await _refreshFlashcards();
    await _refreshNotifications();

    geminiApiKey.value = _prefs.getString(_geminiApiKey) ?? '';
    geminiModel.value = _prefs.getString(_geminiModel) ?? '';
    themeKey.value = _prefs.getString(_themeKey) ?? 'graphite';
    final examDateRaw = _prefs.getString(_examDateKey);
    if (examDateRaw != null) {
      examDate.value = DateTime.tryParse(examDateRaw) ?? DateTime(2026, 9, 6);
    }
    
    final lastAiDateRaw = _prefs.getString('ai_request_last_date');
    final now = DateTime.now();
    if (lastAiDateRaw != null) {
      final lastDate = DateTime.parse(lastAiDateRaw);
      if (lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day) {
        aiRequestCountToday.value = _prefs.getInt('ai_request_count_today') ?? 0;
      } else {
        aiRequestCountToday.value = 0;
        await _prefs.setInt('ai_request_count_today', 0);
      }
    }

    dailyGoal.value = _prefs.getInt(_dailyGoalKey) ?? 50;
    aiGoalCadence.value = _prefs.getString(_aiGoalCadenceKey) ?? 'daily';
    aiNotificationsEnabled.value =
        _prefs.getBool(_aiNotificationsEnabledKey) ?? false;
    aiGoalTargets.value = _decodeAiGoalTargets(
      _prefs.getString(_aiGoalTargetsKey),
    );
    final updatedAtRaw = _prefs.getString(_aiGoalUpdatedAtKey);
    aiGoalUpdatedAt.value =
        updatedAtRaw == null ? null : DateTime.tryParse(updatedAtRaw);
    aiProgramLast.value = _prefs.getString(_aiProgramLastKey);
    final programUpdatedRaw = _prefs.getString(_aiProgramUpdatedAtKey);
    aiProgramUpdatedAt.value = programUpdatedRaw == null
        ? null
        : DateTime.tryParse(programUpdatedRaw);
    reminderEnabled.value = _prefs.getBool(_reminderEnabledKey) ?? false;
    reminderTime.value = _prefs.getString(_reminderTimeKey) ?? '20:00';
    final reminderLastRaw = _prefs.getString(_reminderLastShownKey);
    reminderLastShown.value =
        reminderLastRaw == null ? null : DateTime.tryParse(reminderLastRaw);
    weeklyPlanEnabled.value =
        _prefs.getBool(_weeklyPlanEnabledKey) ?? false;
    weeklyPlanTime.value = _prefs.getString(_weeklyPlanTimeKey) ?? '09:00';
    weeklyPlanWeekday.value =
        _prefs.getInt(_weeklyPlanWeekdayKey) ?? DateTime.monday;
  }

  // --- HELPERS & MAPPERS ---
  
  Map<String, int> _decodeAiGoalTargets(String? raw) {
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return {};
      final result = <String, int>{};
      for (final entry in data.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null && value is int) result[key] = value;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  QuestionEntity _mapToQuestionEntity(QuestionEntry m) {
    return QuestionEntity()
      ..originalId = m.id
      ..bookName = m.bookName
      ..subject = m.subject
      ..topic = m.topic
      ..correct = m.correct
      ..wrong = m.wrong
      ..blank = m.blank
      ..minutes = m.minutes
      ..note = m.note
      ..createdAt = m.createdAt
      ..errorTags = m.errorTags
      ..examType = m.examType
      ..imagePaths = m.imagePaths
      ..isSolved = m.isSolved;
  }

  QuestionEntry _mapFromQuestionEntity(QuestionEntity e) {
    return QuestionEntry(
      id: e.originalId,
      bookName: e.bookName,
      subject: e.subject,
      topic: e.topic,
      correct: e.correct,
      wrong: e.wrong,
      blank: e.blank,
      minutes: e.minutes,
      note: e.note,
      createdAt: e.createdAt,
      errorTags: e.errorTags,
      examType: e.examType,
      imagePaths: e.imagePaths,
      isSolved: e.isSolved,
    );
  }

  Future<void> markQuestionAsSolved(String id) async {
    await _db.markQuestionAsSolved(id);
    await _refreshQuestions();
  }

  MockExamEntity _mapToMockExamEntity(MockExam m) {
    return MockExamEntity()
      ..originalId = m.id
      ..title = m.title
      ..dateLabel = m.dateLabel
      ..correct = m.correct
      ..wrong = m.wrong
      ..blank = m.blank
      ..totalNet = m.totalNet
      ..minutes = m.minutes
      ..note = m.note
      ..createdAt = m.createdAt
      ..examType = m.examType
      ..subjectNetsJson = jsonEncode(m.subjectNets)
      ..subjectMinutesJson = jsonEncode(m.subjectMinutes);
  }

  MockExam _mapFromMockExamEntity(MockExamEntity e) {
    return MockExam(
      id: e.originalId,
      title: e.title,
      dateLabel: e.dateLabel,
      correct: e.correct,
      wrong: e.wrong,
      blank: e.blank,
      totalNet: e.totalNet,
      minutes: e.minutes,
      note: e.note,
      createdAt: e.createdAt,
      examType: e.examType,
      subjectNets: e.subjectNetsJson.isEmpty ? {} : Map<String, double>.from(jsonDecode(e.subjectNetsJson)),
      subjectMinutes: e.subjectMinutesJson.isEmpty ? {} : Map<String, int>.from(jsonDecode(e.subjectMinutesJson)),
    );
  }

  TopicEntity _mapToTopicEntity(TopicSummary m) {
    return TopicEntity()
      ..originalId = m.id
      ..subject = m.subject
      ..title = m.title
      ..nextReview = m.nextReview
      ..summary = m.summary
      ..notes = m.notes
      ..importance = m.importance
      ..tag = m.tag
      ..aiInsights = m.aiInsights.map((i) => TopicInsightEntity()
          ..originalId = i.id
          ..summary = i.summary
          ..notes = i.notes
          ..createdAt = i.createdAt).toList();
  }

  TopicSummary _mapFromTopicEntity(TopicEntity e) {
    return TopicSummary(
      id: e.originalId,
      subject: e.subject,
      title: e.title,
      nextReview: e.nextReview,
      summary: e.summary,
      notes: e.notes,
      importance: e.importance,
      tag: e.tag,
      aiInsights: e.aiInsights.map((i) => TopicInsight(
        id: i.originalId,
        summary: i.summary,
        notes: i.notes,
        createdAt: i.createdAt,
      )).toList(),
    );
  }

  FlashcardEntity _mapToFlashcardEntity(Flashcard m, String topic) {
    return FlashcardEntity()
      ..originalId = m.id
      ..topicTitle = topic
      ..question = m.question
      ..answer = m.answer;
  }

  Flashcard _mapFromFlashcardEntity(FlashcardEntity e) {
    return Flashcard(
      id: e.originalId,
      question: e.question,
      answer: e.answer,
      box: 1,
      nextReview: DateTime.now(),
      isLearned: false,
      topicTitle: e.topicTitle,
    );
  }

  NotificationEntity _mapToNotificationEntity(AppNotification m) {
    return NotificationEntity()
      ..originalId = m.id
      ..title = m.title
      ..body = m.body
      ..createdAt = m.createdAt
      ..unread = m.unread;
  }

  AppNotification _mapFromNotificationEntity(NotificationEntity e) {
    return AppNotification(
      id: e.originalId,
      title: e.title,
      body: e.body,
      createdAt: e.createdAt,
      unread: e.unread,
    );
  }
  
  List<QuestionEntry> entriesForTopic(String topic) {
    return questionEntries.value
        .where((entry) => entry.topic == topic)
        .toList();
  }

  List<QuestionEntry> entriesForSubject(String subject) {
    return questionEntries.value
        .where((entry) => entry.subject == subject)
        .toList();
  }

  List<TopicProgress> buildTopicProgress() {
    final entries = questionEntries.value;
    return topics.map((topic) {
      final topicEntries = entries
          .where((entry) =>
              entry.subject == topic.subject && entry.topic == topic.title)
          .toList();
      return TopicProgress.fromEntries(topic, topicEntries);
    }).toList();
  }

  List<TopicProgress> weakestTopics({int limit = 3}) {
    final progress = buildTopicProgress()
        .where((item) => item.totalQuestions > 0)
        .toList();
    progress.sort((a, b) {
      final aPriority = (1 - a.accuracy) * a.topic.importance;
      final bPriority = (1 - b.accuracy) * b.topic.importance;
      return bPriority.compareTo(aPriority);
    });
    if (progress.length <= limit) {
      return progress;
    }
    return progress.sublist(0, limit);
  }
}

class TopicProgress {
  TopicProgress({
    required this.topic,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.minutes,
    required this.lastStudied,
  });

  final TopicSummary topic;
  final int correct;
  final int wrong;
  final int blank;
  final int minutes;
  final DateTime? lastStudied;

  int get totalQuestions => correct + wrong + blank;
  double get accuracy => totalQuestions == 0 ? 0 : correct / totalQuestions;
  double get progressRatio => totalQuestions == 0
      ? 0
      : (totalQuestions / 200).clamp(0.0, 1.0);
  int get progressPercent => (progressRatio * 100).round();

  static TopicProgress fromEntries(
    TopicSummary topic,
    List<QuestionEntry> entries,
  ) {
    var correct = 0;
    var wrong = 0;
    var blank = 0;
    var minutes = 0;
    DateTime? lastStudied;

    for (final entry in entries) {
      correct += entry.effectiveCorrect;
      wrong += entry.effectiveWrong;
      blank += entry.blank;
      minutes += entry.minutes;
      if (lastStudied == null || entry.createdAt.isAfter(lastStudied)) {
        lastStudied = entry.createdAt;
      }
    }

    return TopicProgress(
      topic: topic,
      correct: correct,
      wrong: wrong,
      blank: blank,
      minutes: minutes,
      lastStudied: lastStudied,
    );
  }
}

class AppRepositoryScope extends InheritedWidget {
  const AppRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final AppRepository repository;

  static AppRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppRepositoryScope>();
    if (scope == null) {
      throw StateError('AppRepositoryScope bulunamadı.');
    }
    return scope.repository;
  }

  @override
  bool updateShouldNotify(AppRepositoryScope oldWidget) {
    return oldWidget.repository != repository;
  }
}