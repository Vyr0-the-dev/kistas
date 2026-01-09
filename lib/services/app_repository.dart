import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/topic_catalog.dart';
import '../models/app_notification.dart';
import '../models/flashcard.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../models/topic_summary.dart';

const _questionEntriesKey = 'question_entries';
const _mockExamsKey = 'mock_exams';
const _dailyGoalKey = 'daily_goal';
const _geminiApiKey = 'gemini_api_key';
const _geminiModel = 'gemini_model';
const _aiGoalCadenceKey = 'ai_goal_cadence';
const _aiNotificationsEnabledKey = 'ai_notifications_enabled';
const _aiGoalTargetsKey = 'ai_goal_targets';
const _aiGoalUpdatedAtKey = 'ai_goal_updated_at';
const _aiProgramLastKey = 'ai_program_last';
const _aiProgramUpdatedAtKey = 'ai_program_updated_at';
const _notificationsKey = 'notifications';
const _reminderEnabledKey = 'reminder_enabled';
const _reminderTimeKey = 'reminder_time';
const _reminderLastShownKey = 'reminder_last_shown';
const _weeklyPlanEnabledKey = 'weekly_plan_enabled';
const _weeklyPlanTimeKey = 'weekly_plan_time';
const _weeklyPlanWeekdayKey = 'weekly_plan_weekday';
const _themeKey = 'theme_key';
const _examDateKey = 'exam_date';
const _flashcardsKey = 'flashcards';

class AppRepository {
  AppRepository._(this._prefs)
      : questionEntries = ValueNotifier<List<QuestionEntry>>([]),
        mockExams = ValueNotifier<List<MockExam>>([]),
        flashcards = ValueNotifier<Map<String, List<Flashcard>>>({}),
        dailyGoal = ValueNotifier<int>(100),
        aiRequestCountToday = ValueNotifier<int>(0),
        geminiApiKey = ValueNotifier<String>(''),
        geminiModel = ValueNotifier<String>(''),
        themeKey = ValueNotifier<String>('midnight'),
        examDate = ValueNotifier<DateTime>(DateTime(2026, 7, 19)),
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
        weeklyPlanWeekday = ValueNotifier<int>(DateTime.monday) {
    _load();
  }

  final SharedPreferences _prefs;
  final ValueNotifier<List<QuestionEntry>> questionEntries;
  final ValueNotifier<List<MockExam>> mockExams;
  final ValueNotifier<Map<String, List<Flashcard>>> flashcards;
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

  static Future<AppRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AppRepository._(prefs);
  }

  List<TopicSummary> get topics => kpssTopicCatalog;

  Future<void> addQuestionEntry(QuestionEntry entry) async {
    final updated = [...questionEntries.value, entry];
    questionEntries.value = updated;
    await _saveQuestionEntries(updated);
  }

  Future<void> addMockExam(MockExam exam) async {
    final updated = [...mockExams.value, exam];
    mockExams.value = updated;
    await _saveMockExams(updated);
  }

  Future<void> saveFlashcards(String topicTitle, List<Flashcard> cards) async {
    final updated = Map<String, List<Flashcard>>.from(flashcards.value);
    updated[topicTitle] = cards;
    flashcards.value = updated;
    await _saveFlashcards(updated);
  }

  Future<void> clearAll() async {
    questionEntries.value = [];
    mockExams.value = [];
    notifications.value = [];
    await _prefs.remove(_questionEntriesKey);
    await _prefs.remove(_mockExamsKey);
    await _prefs.remove(_notificationsKey);
  }

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
    debugPrint('AppRepository: API Key güncelleniyor. Uzunluk: ${trimmed.length}');
    geminiApiKey.value = trimmed;
    await _prefs.setString(_geminiApiKey, trimmed);
  }

  Future<void> setGeminiModel(String value) async {
    debugPrint('AppRepository: Model güncelleniyor: $value');
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

  Future<void> addNotification(AppNotification notification) async {
    final updated = [notification, ...notifications.value];
    notifications.value = updated;
    await _saveNotifications(updated);
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

  Future<void> markNotificationRead(String id) async {
    final updated = notifications.value
        .map((item) =>
            item.id == id ? item.copyWith(unread: false) : item)
        .toList();
    notifications.value = updated;
    await _saveNotifications(updated);
  }

  Future<void> markAllNotificationsRead() async {
    final updated =
        notifications.value.map((item) => item.copyWith(unread: false)).toList();
    notifications.value = updated;
    await _saveNotifications(updated);
  }

  Future<void> clearNotifications() async {
    notifications.value = [];
    await _prefs.remove(_notificationsKey);
  }

  String exportData() {
    final payload = {
      'questionEntries': questionEntries.value.map((e) => e.toJson()).toList(),
      'mockExams': mockExams.value.map((e) => e.toJson()).toList(),
      'flashcards': flashcards.value.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
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
    final questionsRaw = data['questionEntries'];
    final examsRaw = data['mockExams'];
    if (questionsRaw is! List || examsRaw is! List) {
      throw FormatException('Yedek verisi eksik.');
    }
    final questions = questionsRaw
        .whereType<Map<String, dynamic>>()
        .map(QuestionEntry.fromJson)
        .toList();
    final exams = examsRaw
        .whereType<Map<String, dynamic>>()
        .map(MockExam.fromJson)
        .toList();
    final notificationsRaw = data['notifications'];
    final importedNotifications = notificationsRaw is List
        ? notificationsRaw
            .whereType<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList()
        : <AppNotification>[];
    final targetsRaw = data['aiGoalTargets'];
    final targets = <String, int>{};
    if (targetsRaw is Map) {
      for (final entry in targetsRaw.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key == null) {
          continue;
        }
        if (value is int) {
          targets[key] = value;
        } else if (value is num) {
          targets[key] = value.round();
        } else if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            targets[key] = parsed;
          }
        }
      }
    }

    questionEntries.value = questions;
    mockExams.value = exams;
    flashcards.value = _decodeFlashcards(jsonEncode(data['flashcards'] ?? {}));
    notifications.value = importedNotifications;
    aiGoalTargets.value = targets;
    final updatedRaw = data['aiGoalUpdatedAt'] as String?;
    aiGoalUpdatedAt.value =
        updatedRaw == null ? null : DateTime.tryParse(updatedRaw);
    aiGoalCadence.value =
        data['aiGoalCadence'] as String? ?? aiGoalCadence.value;
    aiNotificationsEnabled.value =
        data['aiNotificationsEnabled'] as bool? ?? aiNotificationsEnabled.value;
    aiProgramLast.value = data['aiProgramLast'] as String?;
    final programUpdatedRaw = data['aiProgramUpdatedAt'] as String?;
    aiProgramUpdatedAt.value =
        programUpdatedRaw == null ? null : DateTime.tryParse(programUpdatedRaw);
    reminderEnabled.value = data['reminderEnabled'] as bool? ??
        reminderEnabled.value;
    reminderTime.value = data['reminderTime'] as String? ?? reminderTime.value;
    final reminderShownRaw = data['reminderLastShown'] as String?;
    reminderLastShown.value = reminderShownRaw == null
        ? null
        : DateTime.tryParse(reminderShownRaw);
    weeklyPlanEnabled.value =
        data['weeklyPlanEnabled'] as bool? ?? weeklyPlanEnabled.value;
    weeklyPlanTime.value =
        data['weeklyPlanTime'] as String? ?? weeklyPlanTime.value;
    weeklyPlanWeekday.value =
        data['weeklyPlanWeekday'] as int? ?? weeklyPlanWeekday.value;
    final importedDailyGoal = data['dailyGoal'];
    if (importedDailyGoal is int) {
      dailyGoal.value = importedDailyGoal;
    } else if (importedDailyGoal is num) {
      dailyGoal.value = importedDailyGoal.round();
    }
    await _saveQuestionEntries(questions);
    await _saveMockExams(exams);
    await _saveNotifications(importedNotifications);
    await _prefs.setString(_aiGoalTargetsKey, jsonEncode(targets));
    if (aiGoalUpdatedAt.value != null) {
      await _prefs.setString(
        _aiGoalUpdatedAtKey,
        aiGoalUpdatedAt.value!.toIso8601String(),
      );
    }
    await _prefs.setString(_aiGoalCadenceKey, aiGoalCadence.value);
    await _prefs.setBool(
      _aiNotificationsEnabledKey,
      aiNotificationsEnabled.value,
    );
    await _prefs.setInt(_dailyGoalKey, dailyGoal.value);
    if (aiProgramLast.value != null) {
      await _prefs.setString(_aiProgramLastKey, aiProgramLast.value!);
    }
    if (aiProgramUpdatedAt.value != null) {
      await _prefs.setString(
        _aiProgramUpdatedAtKey,
        aiProgramUpdatedAt.value!.toIso8601String(),
      );
    }
    await _prefs.setBool(_reminderEnabledKey, reminderEnabled.value);
    await _prefs.setString(_reminderTimeKey, reminderTime.value);
    if (reminderLastShown.value != null) {
      await _prefs.setString(
        _reminderLastShownKey,
        reminderLastShown.value!.toIso8601String(),
      );
    }
    await _prefs.setBool(_weeklyPlanEnabledKey, weeklyPlanEnabled.value);
    await _prefs.setString(_weeklyPlanTimeKey, weeklyPlanTime.value);
    await _prefs.setInt(_weeklyPlanWeekdayKey, weeklyPlanWeekday.value);
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
    progress.sort((a, b) => a.accuracy.compareTo(b.accuracy));
    if (progress.length <= limit) {
      return progress;
    }
    return progress.sublist(0, limit);
  }

  Future<void> _load() async {
    questionEntries.value = _decodeQuestionEntries(
      _prefs.getString(_questionEntriesKey),
    );
    mockExams.value = _decodeMockExams(_prefs.getString(_mockExamsKey));
    flashcards.value = _decodeFlashcards(_prefs.getString(_flashcardsKey));
    geminiApiKey.value = _prefs.getString(_geminiApiKey) ?? '';
    geminiModel.value = _prefs.getString(_geminiModel) ?? '';
    themeKey.value = _prefs.getString(_themeKey) ?? 'midnight';
    final examDateRaw = _prefs.getString(_examDateKey);
    if (examDateRaw != null) {
      examDate.value = DateTime.tryParse(examDateRaw) ?? DateTime(2026, 7, 19);
    }
    
    debugPrint('AppRepository: Yüklendi. API Key var mı: ${geminiApiKey.value.isNotEmpty}, Model: ${geminiModel.value}');

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
    notifications.value = _decodeNotifications(
      _prefs.getString(_notificationsKey),
    );
  }

  Future<void> _saveQuestionEntries(List<QuestionEntry> entries) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_questionEntriesKey, encoded);
  }

  Future<void> _saveMockExams(List<MockExam> exams) async {
    final encoded = jsonEncode(exams.map((e) => e.toJson()).toList());
    await _prefs.setString(_mockExamsKey, encoded);
  }

  Future<void> _saveFlashcards(Map<String, List<Flashcard>> data) async {
    final encoded = jsonEncode(
      data.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
    );
    await _prefs.setString(_flashcardsKey, encoded);
  }

  Future<void> _saveNotifications(List<AppNotification> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_notificationsKey, encoded);
  }

  List<QuestionEntry> _decodeQuestionEntries(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final data = jsonDecode(raw);
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(QuestionEntry.fromJson)
        .toList();
  }

  List<MockExam> _decodeMockExams(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final data = jsonDecode(raw);
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(MockExam.fromJson)
        .toList();
  }

  Map<String, List<Flashcard>> _decodeFlashcards(String? raw) {
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      return data.map((key, value) {
        final list = value as List;
        return MapEntry(
          key,
          list.whereType<Map<String, dynamic>>().map(Flashcard.fromJson).toList(),
        );
      });
    } catch (_) {
      return {};
    }
  }

  List<AppNotification> _decodeNotifications(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final data = jsonDecode(raw);
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  Map<String, int> _decodeAiGoalTargets(String? raw) {
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final data = jsonDecode(raw);
    if (data is! Map) {
      return {};
    }
    final result = <String, int>{};
    for (final entry in data.entries) {
      final key = entry.key?.toString();
      final value = entry.value;
      if (key == null) {
        continue;
      }
      if (value is int) {
        result[key] = value;
      } else if (value is num) {
        result[key] = value.round();
      } else if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          result[key] = parsed;
        }
      }
    }
    return result;
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
      correct += entry.correct;
      wrong += entry.wrong;
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
