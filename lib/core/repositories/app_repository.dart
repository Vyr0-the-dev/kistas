import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../data/database_service.dart';
import '../data/entities/flashcard_entity.dart';
import '../data/entities/mock_exam_entity.dart';
import '../data/entities/notification_entity.dart';
import '../data/entities/question_entity.dart';
import '../data/entities/topic_entity.dart';
import '../data/exam_presets.dart';
import '../models/app_notification.dart';
import '../models/exam_profile.dart';
import '../models/flashcard.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../models/study_schedule_block.dart';
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
const _themeKey = 'theme_key_v2';
const _examDateKey = 'exam_date';
const _examProfilesKey = 'exam_profiles_v1';
const _weeklyScheduleKey = 'weekly_schedule_v1';
const _flashcardProgressKey = 'flashcard_progress_v1';
const _mockExamMetaKey = 'mock_exam_meta_v1';
const _userNameKey = 'user_name_v1';
const _catalogInitializedKey = 'catalog_initialized_v2';

class AppRepository {
  static int _customTopicSeq = 0;
  static int _scheduleBlockSeq = 0;

  AppRepository._(this._prefs, this._db)
      : questionEntries = ValueNotifier<List<QuestionEntry>>([]),
        mockExams = ValueNotifier<List<MockExam>>([]),
        flashcards = ValueNotifier<Map<String, List<Flashcard>>>({}),
        userTopics = ValueNotifier<List<TopicSummary>>([]),
        customTopics = ValueNotifier<Map<String, TopicSummary>>({}),
        examProfiles = ValueNotifier<List<ExamProfile>>([]),
        weeklySchedule = ValueNotifier<List<StudyScheduleBlock>>([]),
        userName = ValueNotifier<String>(''),
        dailyGoal = ValueNotifier<int>(50),
        aiRequestCountToday = ValueNotifier<int>(0),
        geminiApiKey = ValueNotifier<String>(''),
        geminiModel = ValueNotifier<String>(''),
        themeKey = ValueNotifier<String>(AppColors.defaultThemeKey),
        examDate = ValueNotifier<DateTime>(DateTime.now().add(const Duration(days: 90))),
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
        focusRunning = ValueNotifier<bool>(false);

  final SharedPreferences _prefs;
  final DatabaseService _db;

  final ValueNotifier<List<QuestionEntry>> questionEntries;
  final ValueNotifier<List<MockExam>> mockExams;
  final ValueNotifier<Map<String, List<Flashcard>>> flashcards;
  final ValueNotifier<List<TopicSummary>> userTopics;
  final ValueNotifier<Map<String, TopicSummary>> customTopics;
  final ValueNotifier<List<ExamProfile>> examProfiles;
  final ValueNotifier<List<StudyScheduleBlock>> weeklySchedule;
  final ValueNotifier<String> userName;
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

  Map<String, Map<String, dynamic>> _flashcardMeta = {};
  Map<String, Map<String, String>> _mockExamMeta = {};

  static Future<AppRepository> init(DatabaseService db) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = AppRepository._(prefs, db);
    await repo._load();
    return repo;
  }

  List<TopicSummary> get topics => userTopics.value;

  List<String> get availableTags {
    final set = <String>{};
    for (final t in userTopics.value) {
      if (t.tag.trim().isNotEmpty) set.add(t.tag.trim());
    }
    for (final p in examProfiles.value) {
      if (p.name.trim().isNotEmpty) set.add(p.name.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> subjectsForTag(String? tag) {
    final normalized = (tag == null || tag == 'Tümü' || tag.trim().isEmpty)
        ? null
        : tag.trim().toLowerCase();
    final subjects = <String>{};
    for (final t in userTopics.value) {
      if (normalized == null || t.tag.trim().toLowerCase() == normalized) {
        if (t.subject.trim().isNotEmpty) subjects.add(t.subject.trim());
      }
    }
    final list = subjects.toList()..sort();
    return list;
  }

  // --- TOPICS & CURRICULUM ---

  Future<void> addUserTopic(TopicSummary topic) async {
    await _prefs.setBool(_catalogInitializedKey, true);
    await _db.saveTopic(_mapToTopicEntity(topic));
    await _ensureProfileExists(topic.tag);
    await _refreshTopics();
  }

  Future<void> addUserTopics(List<TopicSummary> newTopics) async {
    if (newTopics.isEmpty) return;
    await _prefs.setBool(_catalogInitializedKey, true);
    final entities = newTopics.map(_mapToTopicEntity).toList();
    await _db.saveTopics(entities);
    final tags = newTopics.map((e) => e.tag).toSet();
    for (final tag in tags) {
      await _ensureProfileExists(tag);
    }
    await _refreshTopics();
  }

  Future<void> updateUserTopic(TopicSummary topic) async {
    await _db.saveTopic(_mapToTopicEntity(topic));
    await _ensureProfileExists(topic.tag);
    await _refreshTopics();
  }

  Future<void> deleteUserTopic(String id) async {
    await _prefs.setBool(_catalogInitializedKey, true);
    await _db.deleteTopic(id);
    await _refreshTopics();
  }

  Future<void> deleteUserTopics(List<String> ids) async {
    if (ids.isEmpty) return;
    await _prefs.setBool(_catalogInitializedKey, true);
    await _db.deleteTopicsByIds(ids);
    await _refreshTopics();
  }

  Future<void> bulkUpdateUserTopics(List<TopicSummary> updatedList) async {
    if (updatedList.isEmpty) return;
    final entities = updatedList.map(_mapToTopicEntity).toList();
    await _db.saveTopics(entities);
    await _refreshTopics();
  }

  Future<void> clearTopicNotes(String topicId) async {
    final index = userTopics.value.indexWhere((t) => t.id == topicId);
    if (index == -1) return;
    final cleared = userTopics.value[index].copyWith(
      summary: '',
      notes: const [],
      aiInsights: const [],
    );
    await updateUserTopic(cleared);
  }

  Future<int> importExamPreset(
    ExamPreset preset, {
    Set<String>? selectedSubjects,
  }) async {
    final incoming = preset.toTopicSummaries(selectedSubjects: selectedSubjects);
    final existingKeys = userTopics.value
        .map((t) => _topicIdentityKey(t.tag, t.subject, t.title))
        .toSet();
    final uniqueToAdd = <TopicSummary>[];
    for (final topic in incoming) {
      final key = _topicIdentityKey(topic.tag, topic.subject, topic.title);
      if (existingKeys.add(key)) {
        uniqueToAdd.add(topic);
      }
    }

    await _ensureProfileExists(
      preset.name,
      defaultWrongPenalty: preset.defaultWrongPenalty,
    );

    if (uniqueToAdd.isNotEmpty) {
      await addUserTopics(uniqueToAdd);
    } else {
      await _prefs.setBool(_catalogInitializedKey, true);
    }
    return uniqueToAdd.length;
  }

  /// Synchronizes an exam preset's loaded subjects with [selectedSubjects].
  /// Removes preset subjects that were unchecked, adds any missing topics for
  /// newly selected subjects, and removes the preset's exam profile if no
  /// topics remain under its tag. Past question and mock exam logs are kept.
  Future<({int added, int removed})> syncExamPresetSubjects(
    ExamPreset preset, {
    required Set<String> selectedSubjects,
  }) async {
    final normalizedTag = preset.name.trim().toLowerCase();
    final normalizedSelected =
        selectedSubjects.map((s) => s.trim().toLowerCase()).toSet();
    final normalizedPresetSubjects =
        preset.subjects.keys.map((s) => s.trim().toLowerCase()).toSet();

    final idsToRemove = userTopics.value
        .where((t) {
          if (t.tag.trim().toLowerCase() != normalizedTag) return false;
          final subjectKey = t.subject.trim().toLowerCase();
          return normalizedPresetSubjects.contains(subjectKey) &&
              !normalizedSelected.contains(subjectKey);
        })
        .map((t) => t.id)
        .toList();

    if (idsToRemove.isNotEmpty) {
      await deleteUserTopics(idsToRemove);
    }

    var addedCount = 0;
    if (selectedSubjects.isNotEmpty) {
      addedCount = await importExamPreset(
        preset,
        selectedSubjects: selectedSubjects,
      );
    } else {
      final hasRemainingTopics = userTopics.value.any(
        (t) => t.tag.trim().toLowerCase() == normalizedTag,
      );
      if (!hasRemainingTopics) {
        await deleteExamProfile(preset.name);
      }
    }

    return (added: addedCount, removed: idsToRemove.length);
  }

  /// Removes all subjects belonging to [preset] from the user's curriculum.
  Future<int> removeExamPreset(ExamPreset preset) async {
    final result = await syncExamPresetSubjects(
      preset,
      selectedSubjects: const <String>{},
    );
    return result.removed;
  }

  Future<int> addCourseTopics({
    required String subject,
    required List<String> topicTitles,
    String tag = 'Genel',
    int importance = 3,
  }) async {
    final cleanSubject = subject.trim();
    if (cleanSubject.isEmpty) return 0;
    final cleanTag = tag.trim().isEmpty ? 'Genel' : tag.trim();
    final cleanedTitles = topicTitles
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final effectiveTitles =
        cleanedTitles.isEmpty ? <String>['Genel Çalışma'] : cleanedTitles;

    final existingKeys = userTopics.value
        .map((t) => _topicIdentityKey(t.tag, t.subject, t.title))
        .toSet();
    final now = DateTime.now().microsecondsSinceEpoch;
    final toAdd = <TopicSummary>[];

    for (var i = 0; i < effectiveTitles.length; i++) {
      final title = effectiveTitles[i];
      final key = _topicIdentityKey(cleanTag, cleanSubject, title);
      if (existingKeys.add(key)) {
        toAdd.add(
          TopicSummary(
            id: 'custom-$now-${++_customTopicSeq}-$i',
            subject: cleanSubject,
            title: title,
            nextReview: '',
            importance: importance.clamp(1, 5),
            tag: cleanTag,
          ),
        );
      }
    }

    if (toAdd.isNotEmpty) {
      await addUserTopics(toAdd);
    }
    return toAdd.length;
  }

  Future<void> renameSubject({
    required String oldSubject,
    required String newSubject,
    String? tag,
  }) async {
    final trimmedNew = newSubject.trim();
    if (trimmedNew.isEmpty || trimmedNew == oldSubject) return;

    final updatedTopics = userTopics.value
        .where((t) =>
            t.subject == oldSubject && (tag == null || t.tag == tag))
        .map((t) => t.copyWith(subject: trimmedNew))
        .toList();
    if (updatedTopics.isNotEmpty) {
      await bulkUpdateUserTopics(updatedTopics);
    }

    final updatedSchedule = weeklySchedule.value.map((b) {
      final matchesTag = tag == null || b.tag == tag;
      if (b.subject == oldSubject && matchesTag) {
        return b.copyWith(subject: trimmedNew);
      }
      return b;
    }).toList();
    await _saveWeeklySchedule(updatedSchedule);
  }

  Future<int> deleteSubject(String subject, {String? tag}) async {
    final normalizedSubject = subject.trim().toLowerCase();
    final normalizedTag = tag?.trim().toLowerCase();
    final matchingTopics = userTopics.value
        .where(
          (t) =>
              t.subject.trim().toLowerCase() == normalizedSubject &&
              (normalizedTag == null ||
                  t.tag.trim().toLowerCase() == normalizedTag),
        )
        .toList();
    if (matchingTopics.isEmpty) return 0;

    final affectedTags = matchingTopics.map((t) => t.tag).toSet();
    await deleteUserTopics(matchingTopics.map((t) => t.id).toList());

    for (final affectedTag in affectedTags) {
      final normTag = affectedTag.trim().toLowerCase();
      final hasRemaining = userTopics.value.any(
        (t) => t.tag.trim().toLowerCase() == normTag,
      );
      if (!hasRemaining) {
        await deleteExamProfile(affectedTag);
      }
    }
    return matchingTopics.length;
  }

  Future<void> _refreshTopics() async {
    final entities = await _db.getAllTopics();
    if (entities.isNotEmpty && !(_prefs.getBool(_catalogInitializedKey) ?? false)) {
      await _prefs.setBool(_catalogInitializedKey, true);
    }
    userTopics.value = entities.map(_mapFromTopicEntity).toList();
    customTopics.value = {for (final t in userTopics.value) t.id: t};
  }

  String _topicIdentityKey(String tag, String subject, String title) {
    return '${tag.trim().toLowerCase()}|${subject.trim().toLowerCase()}|${title.trim().toLowerCase()}';
  }

  // --- EXAM PROFILES ---

  ExamProfile? profileForTag(String tag) {
    final target = tag.trim().toLowerCase();
    for (final profile in examProfiles.value) {
      if (profile.name.trim().toLowerCase() == target) {
        return profile;
      }
    }
    return null;
  }

  double wrongPenaltyForTag(String tag) {
    return profileForTag(tag)?.wrongPenalty ?? 0.25;
  }

  double calculateNet(int correct, int wrong, {String tag = 'Genel'}) {
    final penalty = wrongPenaltyForTag(tag);
    return correct - (wrong * penalty);
  }

  Future<void> _ensureProfileExists(
    String tag, {
    double defaultWrongPenalty = 0.25,
  }) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (profileForTag(trimmed) != null) return;
    final updated = [
      ...examProfiles.value,
      ExamProfile(name: trimmed, wrongPenalty: defaultWrongPenalty),
    ];
    await _saveExamProfiles(updated);
  }

  Future<void> upsertExamProfile(ExamProfile profile) async {
    final trimmedName = profile.name.trim();
    if (trimmedName.isEmpty) return;
    final normalized = profile.copyWith(name: trimmedName);
    final list = [...examProfiles.value];
    final idx = list.indexWhere(
      (p) => p.name.trim().toLowerCase() == trimmedName.toLowerCase(),
    );
    if (idx >= 0) {
      list[idx] = normalized;
    } else {
      list.add(normalized);
    }
    await _saveExamProfiles(list);
  }

  Future<void> renameExamProfile(String oldName, String newName) async {
    final cleanNew = newName.trim();
    if (cleanNew.isEmpty || cleanNew == oldName) return;

    final topicsToUpdate = userTopics.value
        .where((t) => t.tag == oldName)
        .map((t) => t.copyWith(tag: cleanNew))
        .toList();
    if (topicsToUpdate.isNotEmpty) {
      await bulkUpdateUserTopics(topicsToUpdate);
    }

    final profiles = [...examProfiles.value];
    final oldIdx = profiles.indexWhere(
      (p) => p.name.trim().toLowerCase() == oldName.trim().toLowerCase(),
    );
    final newIdx = profiles.indexWhere(
      (p) => p.name.trim().toLowerCase() == cleanNew.toLowerCase(),
    );
    if (oldIdx >= 0) {
      final moved = profiles[oldIdx].copyWith(name: cleanNew);
      profiles.removeAt(oldIdx);
      if (newIdx == -1) {
        profiles.add(moved);
      }
      await _saveExamProfiles(profiles);
    }

    final updatedSchedule = weeklySchedule.value
        .map((b) => b.tag == oldName ? b.copyWith(tag: cleanNew) : b)
        .toList();
    await _saveWeeklySchedule(updatedSchedule);
  }

  Future<void> deleteExamProfile(String name) async {
    final updated = examProfiles.value
        .where((p) => p.name.trim().toLowerCase() != name.trim().toLowerCase())
        .toList();
    await _saveExamProfiles(updated);
  }

  Future<void> _saveExamProfiles(List<ExamProfile> profiles) async {
    examProfiles.value = profiles;
    await _prefs.setString(
      _examProfilesKey,
      jsonEncode(profiles.map((e) => e.toJson()).toList()),
    );
  }

  // --- WEEKLY STUDY SCHEDULE ---

  List<StudyScheduleBlock> scheduleForWeek(DateTime weekMonday) {
    final normalized = StudyScheduleBlock.mondayOf(weekMonday);
    return weeklySchedule.value
        .where((b) => b.occursInWeek(normalized))
        .toList();
  }

  List<StudyScheduleBlock> scheduleForDay(
    int weekday, {
    DateTime? weekMonday,
  }) {
    final resolvedMonday =
        StudyScheduleBlock.mondayOf(weekMonday ?? DateTime.now());
    final dayBlocks = weeklySchedule.value
        .where((b) => b.occursOnDay(resolvedMonday, weekday))
        .toList();
    dayBlocks.sort((a, b) {
      final orderCmp = a.sortOrder.compareTo(b.sortOrder);
      if (orderCmp != 0) return orderCmp;
      return a.startTime.compareTo(b.startTime);
    });
    return dayBlocks;
  }

  Future<void> addScheduleBlock(StudyScheduleBlock block) async {
    final anchorMonday = StudyScheduleBlock.parseWeekKey(block.startWeekKey) ??
        StudyScheduleBlock.mondayOf(DateTime.now());
    final dayCount =
        scheduleForDay(block.weekday, weekMonday: anchorMonday).length;
    final indexed = block.copyWith(sortOrder: dayCount);
    await _saveWeeklySchedule([...weeklySchedule.value, indexed]);
  }

  Future<int> copyScheduleBlockToDays(
    StudyScheduleBlock source, {
    required Iterable<int> targetWeekdays,
    required String targetWeekKey,
  }) async {
    final uniqueDays = targetWeekdays
        .map((d) => d.clamp(DateTime.monday, DateTime.sunday))
        .toSet()
        .toList()
      ..sort();
    if (uniqueDays.isEmpty) return 0;

    final anchorMonday = StudyScheduleBlock.parseWeekKey(targetWeekKey) ??
        StudyScheduleBlock.mondayOf(DateTime.now());
    final resolvedWeekKey = StudyScheduleBlock.weekKeyFor(anchorMonday);
    final copiedRecurrence = source.recurrence.isWeekScopedMultiDay
        ? ScheduleRecurrence.once
        : source.recurrence;

    final now = DateTime.now().microsecondsSinceEpoch;
    final nextList = [...weeklySchedule.value];
    final dayCounts = <int, int>{};

    for (var i = 0; i < uniqueDays.length; i++) {
      final day = uniqueDays[i];
      final existingCount = dayCounts[day] ??
          scheduleForDay(day, weekMonday: anchorMonday).length;
      dayCounts[day] = existingCount + 1;

      nextList.add(
        source.copyWith(
          id: 'blk-$now-${++_scheduleBlockSeq}-$i',
          weekday: day,
          sortOrder: existingCount,
          isCompleted: false,
          completedWeeks: const [],
          recurrence: copiedRecurrence,
          startWeekKey: resolvedWeekKey,
          imagePaths: List<String>.from(source.imagePaths),
        ),
      );
    }

    await _saveWeeklySchedule(nextList);
    return uniqueDays.length;
  }

  Future<void> updateScheduleBlock(StudyScheduleBlock block) async {
    final list = weeklySchedule.value
        .map((b) => b.id == block.id ? block : b)
        .toList();
    await _saveWeeklySchedule(list);
  }

  Future<void> moveScheduleBlock(
    String blockId,
    int targetWeekday, {
    int? targetIndex,
  }) async {
    final existingIdx = weeklySchedule.value.indexWhere((b) => b.id == blockId);
    if (existingIdx == -1) return;
    final moving = weeklySchedule.value[existingIdx];
    final clampedDay = targetWeekday.clamp(DateTime.monday, DateTime.sunday);

    final others = weeklySchedule.value.where((b) => b.id != blockId).toList();
    final targetDayList = others.where((b) => b.weekday == clampedDay).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final insertAt = targetIndex == null
        ? targetDayList.length
        : targetIndex.clamp(0, targetDayList.length);
    targetDayList.insert(insertAt, moving.copyWith(weekday: clampedDay));

    final rebuiltTarget = <StudyScheduleBlock>[];
    for (var i = 0; i < targetDayList.length; i++) {
      rebuiltTarget.add(targetDayList[i].copyWith(sortOrder: i));
    }

    final remaining = <StudyScheduleBlock>[];
    for (final day in [1, 2, 3, 4, 5, 6, 7]) {
      if (day == clampedDay) {
        remaining.addAll(rebuiltTarget);
      } else {
        final list = others.where((b) => b.weekday == day).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        for (var i = 0; i < list.length; i++) {
          remaining.add(list[i].copyWith(sortOrder: i));
        }
      }
    }
    await _saveWeeklySchedule(remaining);
  }

  Future<void> reorderScheduleDay(
    int weekday,
    int oldIndex,
    int newIndex, {
    DateTime? weekMonday,
  }) async {
    final dayBlocks = scheduleForDay(weekday, weekMonday: weekMonday);
    if (oldIndex < 0 || oldIndex >= dayBlocks.length) return;
    var adjustedNewIndex = newIndex;
    if (adjustedNewIndex > oldIndex) adjustedNewIndex -= 1;
    adjustedNewIndex = adjustedNewIndex.clamp(0, dayBlocks.length - 1);

    final item = dayBlocks.removeAt(oldIndex);
    dayBlocks.insert(adjustedNewIndex, item);

    final reindexedById = <String, StudyScheduleBlock>{};
    for (var i = 0; i < dayBlocks.length; i++) {
      reindexedById[dayBlocks[i].id] = dayBlocks[i].copyWith(sortOrder: i);
    }

    final updated = weeklySchedule.value
        .map((b) => reindexedById[b.id] ?? b)
        .toList();
    await _saveWeeklySchedule(updated);
  }

  Future<void> toggleScheduleBlockCompleted(
    String blockId, {
    String? weekKey,
    int? weekday,
  }) async {
    final resolvedKey =
        weekKey ?? StudyScheduleBlock.weekKeyFor(DateTime.now());
    final list = weeklySchedule.value.map((b) {
      if (b.id == blockId) {
        return b.toggleCompletedForWeek(resolvedKey, weekday: weekday);
      }
      return b;
    }).toList();
    await _saveWeeklySchedule(list);
  }

  Future<void> deleteScheduleBlock(String blockId) async {
    final list = weeklySchedule.value.where((b) => b.id != blockId).toList();
    await _saveWeeklySchedule(list);
  }

  Future<void> replaceWeeklySchedule(List<StudyScheduleBlock> blocks) async {
    final normalized = <StudyScheduleBlock>[];
    for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
      final dayItems = blocks.where((b) => b.weekday == day).toList();
      for (var i = 0; i < dayItems.length; i++) {
        normalized.add(dayItems[i].copyWith(sortOrder: i));
      }
    }
    await _saveWeeklySchedule(normalized);
  }

  Future<void> resetWeeklyCompletion({String? weekKey}) async {
    final resolvedKey =
        weekKey ?? StudyScheduleBlock.weekKeyFor(DateTime.now());
    final dayPrefix = '$resolvedKey-d';
    final list = weeklySchedule.value.map((b) {
      final next = b.completedWeeks
          .where((k) => k != resolvedKey && !k.startsWith(dayPrefix))
          .toList();
      return b.copyWith(completedWeeks: next, isCompleted: false);
    }).toList();
    await _saveWeeklySchedule(list);
  }

  Future<void> _saveWeeklySchedule(List<StudyScheduleBlock> blocks) async {
    weeklySchedule.value = blocks;
    await _prefs.setString(
      _weeklyScheduleKey,
      jsonEncode(blocks.map((e) => e.toJson()).toList()),
    );
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
    _mockExamMeta[exam.id] = {
      'examScope': exam.examScope,
      'focusSubject': exam.focusSubject,
      'focusTopic': exam.focusTopic,
    };
    await _persistMockExamMeta();
    await _db.addMockExam(_mapToMockExamEntity(exam));
    await _refreshMockExams();
  }

  Future<void> deleteMockExam(String id) async {
    _mockExamMeta.remove(id);
    await _persistMockExamMeta();
    await _db.deleteMockExam(id);
    await _refreshMockExams();
  }

  Future<void> _persistMockExamMeta() async {
    await _prefs.setString(_mockExamMetaKey, jsonEncode(_mockExamMeta));
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
      _flashcardMeta[card.id] = {
        'box': card.box,
        'nextReview': card.nextReview.toIso8601String(),
        'isLearned': card.isLearned,
      };
    }
    await _persistFlashcardMeta();
    await _refreshFlashcards();
  }

  Future<void> clearFlashcards(String topicTitle) async {
    final existing = flashcards.value[topicTitle] ?? const [];
    for (final c in existing) {
      _flashcardMeta.remove(c.id);
    }
    await _persistFlashcardMeta();
    await _db.clearFlashcardsForTopic(topicTitle);
    await _refreshFlashcards();
  }

  Future<void> deleteFlashcard(String topicTitle, String cardId) async {
    _flashcardMeta.remove(cardId);
    await _persistFlashcardMeta();
    await _db.deleteFlashcard(cardId);
    await _refreshFlashcards();
  }

  Future<void> _persistFlashcardMeta() async {
    await _prefs.setString(_flashcardProgressKey, jsonEncode(_flashcardMeta));
  }

  Future<void> _refreshFlashcards() async {
    final entities = await _db.getAllFlashcards();
    final grouped = <String, List<Flashcard>>{};
    for (final e in entities) {
      grouped.putIfAbsent(e.topicTitle, () => []).add(_mapFromFlashcardEntity(e));
    }
    flashcards.value = grouped;
  }

  // --- BACKUP / RESTORE / RESET ---

  String exportData() {
    final payload = {
      'schemaVersion': 2,
      'questionEntries': questionEntries.value.map((e) => e.toJson()).toList(),
      'mockExams': mockExams.value.map((e) => e.toJson()).toList(),
      'flashcards': flashcards.value.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'userTopics': userTopics.value.map((e) => e.toJson()).toList(),
      'examProfiles': examProfiles.value.map((e) => e.toJson()).toList(),
      'weeklySchedule': weeklySchedule.value.map((e) => e.toJson()).toList(),
      'userName': userName.value,
      'notifications': notifications.value.map((e) => e.toJson()).toList(),
      'aiGoalTargets': aiGoalTargets.value,
      'aiGoalUpdatedAt': aiGoalUpdatedAt.value?.toIso8601String(),
      'aiGoalCadence': aiGoalCadence.value,
      'aiNotificationsEnabled': aiNotificationsEnabled.value,
      'dailyGoal': dailyGoal.value,
      'examDate': examDate.value.toIso8601String(),
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
      throw const FormatException('Geçersiz yedek formatı.');
    }

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

    final examsRaw = data['mockExams'];
    if (examsRaw is List) {
      final exams = examsRaw
          .whereType<Map<String, dynamic>>()
          .map(MockExam.fromJson)
          .toList();
      for (final e in exams) {
        _mockExamMeta[e.id] = {
          'examScope': e.examScope,
          'focusSubject': e.focusSubject,
          'focusTopic': e.focusTopic,
        };
        await _db.addMockExam(_mapToMockExamEntity(e));
      }
      await _persistMockExamMeta();
    }

    final topicsRaw = data['userTopics'];
    if (topicsRaw is List) {
      final importedTopics = topicsRaw
          .whereType<Map<String, dynamic>>()
          .map(TopicSummary.fromJson)
          .toList();
      await addUserTopics(importedTopics);
    }

    final flashcardsRaw = data['flashcards'];
    if (flashcardsRaw is Map) {
      for (final entry in flashcardsRaw.entries) {
        final topicTitle = entry.key.toString();
        final rawList = entry.value;
        if (rawList is List) {
          final cards = rawList
              .whereType<Map<String, dynamic>>()
              .map(Flashcard.fromJson)
              .toList();
          if (cards.isNotEmpty) {
            await saveFlashcards(topicTitle, cards);
          }
        }
      }
    }

    final profilesRaw = data['examProfiles'];
    if (profilesRaw is List) {
      final importedProfiles = profilesRaw
          .whereType<Map<String, dynamic>>()
          .map(ExamProfile.fromJson)
          .toList();
      await _saveExamProfiles(importedProfiles);
    }

    final scheduleRaw = data['weeklySchedule'];
    if (scheduleRaw is List) {
      final importedBlocks = scheduleRaw
          .whereType<Map<String, dynamic>>()
          .map(StudyScheduleBlock.fromJson)
          .toList();
      await replaceWeeklySchedule(importedBlocks);
    }

    final importedName = data['userName'];
    if (importedName is String) {
      await setUserName(importedName);
    }

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

    final targetsRaw = data['aiGoalTargets'];
    final targets = <String, int>{};
    if (targetsRaw is Map) {
      for (final entry in targetsRaw.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key == null) continue;
        if (value is int) {
          targets[key] = value;
        } else if (value is num) {
          targets[key] = value.round();
        } else if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) targets[key] = parsed;
        }
      }
    }
    await setAiGoalTargets(targets);

    final updatedRaw = data['aiGoalUpdatedAt'] as String?;
    await setAiGoalUpdatedAt(
      updatedRaw == null ? null : DateTime.tryParse(updatedRaw),
    );

    await setAiGoalCadence(
      data['aiGoalCadence'] as String? ?? aiGoalCadence.value,
    );
    await setAiNotificationsEnabled(
      data['aiNotificationsEnabled'] as bool? ?? aiNotificationsEnabled.value,
    );

    final importedProgram = data['aiProgramLast'] as String?;
    if (importedProgram != null) {
      await setAiProgram(importedProgram);
    }

    final examDateRaw = data['examDate'] as String?;
    if (examDateRaw != null) {
      final parsedDate = DateTime.tryParse(examDateRaw);
      if (parsedDate != null) {
        await setExamDate(parsedDate);
      }
    }

    await setReminderEnabled(
      data['reminderEnabled'] as bool? ?? reminderEnabled.value,
    );
    await setReminderTime(
      data['reminderTime'] as String? ?? reminderTime.value,
    );
    await setWeeklyPlanEnabled(
      data['weeklyPlanEnabled'] as bool? ?? weeklyPlanEnabled.value,
    );
    await setWeeklyPlanTime(
      data['weeklyPlanTime'] as String? ?? weeklyPlanTime.value,
    );
    await setWeeklyPlanWeekday(
      data['weeklyPlanWeekday'] as int? ?? weeklyPlanWeekday.value,
    );

    final importedDailyGoal = data['dailyGoal'];
    if (importedDailyGoal is num) {
      await setDailyGoal(importedDailyGoal.round());
    }

    await _load();
  }

  Future<void> saveTopicUpdate(TopicSummary topic) async {
    await updateUserTopic(topic);
  }

  /// Preserved for compatibility — clears notes/summary without deleting the topic.
  Future<void> deleteTopicUpdate(String topicId) async {
    await clearTopicNotes(topicId);
  }

  Future<void> clearAll() async {
    await _db.clearAllData();
    _flashcardMeta.clear();
    _mockExamMeta.clear();
    await _prefs.remove(_flashcardProgressKey);
    await _prefs.remove(_mockExamMetaKey);
    await _prefs.remove(_weeklyScheduleKey);
    await _prefs.remove(_examProfilesKey);
    await _prefs.remove(_aiGoalTargetsKey);
    await _prefs.remove(_aiGoalUpdatedAtKey);
    await _prefs.remove(_aiProgramLastKey);
    await _prefs.remove(_aiProgramUpdatedAtKey);
    await _prefs.setBool(_catalogInitializedKey, true);

    questionEntries.value = [];
    mockExams.value = [];
    userTopics.value = [];
    customTopics.value = {};
    flashcards.value = {};
    notifications.value = [];
    examProfiles.value = [];
    weeklySchedule.value = [];
    aiGoalTargets.value = {};
    aiGoalUpdatedAt.value = null;
    aiProgramLast.value = null;
    aiProgramUpdatedAt.value = null;
  }

  // --- SETTINGS / PREFS ---

  Future<void> setUserName(String value) async {
    final trimmed = value.trim();
    userName.value = trimmed;
    await _prefs.setString(_userNameKey, trimmed);
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
    await _prefs.setString(
      'ai_request_last_date',
      DateTime.now().toIso8601String(),
    );
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
    final resolved = AppColors.resolveKey(key);
    themeKey.value = resolved;
    await _prefs.setString(_themeKey, resolved);
  }

  Future<void> toggleLightDarkTheme() async {
    await setTheme(AppColors.toggleLightDarkKey(themeKey.value));
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
    _flashcardMeta = _decodeFlashcardMeta(
      _prefs.getString(_flashcardProgressKey),
    );
    _mockExamMeta = _decodeMockExamMeta(
      _prefs.getString(_mockExamMetaKey),
    );
    await _refreshQuestions();
    await _refreshMockExams();
    await _refreshTopics();
    await _refreshFlashcards();
    await _refreshNotifications();

    examProfiles.value = _decodeExamProfiles(
      _prefs.getString(_examProfilesKey),
    );
    weeklySchedule.value = _decodeWeeklySchedule(
      _prefs.getString(_weeklyScheduleKey),
    );
    userName.value = _prefs.getString(_userNameKey) ?? '';

    geminiApiKey.value = _prefs.getString(_geminiApiKey) ?? '';
    geminiModel.value = _prefs.getString(_geminiModel) ?? '';
    themeKey.value = AppColors.resolveKey(
      _prefs.getString(_themeKey) ?? AppColors.defaultThemeKey,
    );
    final examDateRaw = _prefs.getString(_examDateKey);
    if (examDateRaw != null) {
      final parsed = DateTime.tryParse(examDateRaw);
      if (parsed != null) examDate.value = parsed;
    }

    final lastAiDateRaw = _prefs.getString('ai_request_last_date');
    final now = DateTime.now();
    if (lastAiDateRaw != null) {
      final lastDate = DateTime.tryParse(lastAiDateRaw);
      if (lastDate != null &&
          lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day) {
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
    weeklyPlanEnabled.value = _prefs.getBool(_weeklyPlanEnabledKey) ?? false;
    weeklyPlanTime.value = _prefs.getString(_weeklyPlanTimeKey) ?? '09:00';
    weeklyPlanWeekday.value =
        _prefs.getInt(_weeklyPlanWeekdayKey) ?? DateTime.monday;
  }

  // --- DECODERS ---

  Map<String, int> _decodeAiGoalTargets(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return {};
      final result = <String, int>{};
      for (final entry in data.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null && value is num) result[key] = value.round();
      }
      return result;
    } catch (e) {
      debugPrint('AppRepository: Failed to decode AI goal targets: $e');
      return {};
    }
  }

  List<ExamProfile> _decodeExamProfiles(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final data = jsonDecode(raw);
      if (data is! List) return [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(ExamProfile.fromJson)
          .toList();
    } catch (e) {
      debugPrint('AppRepository: Failed to decode exam profiles: $e');
      return [];
    }
  }

  List<StudyScheduleBlock> _decodeWeeklySchedule(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final data = jsonDecode(raw);
      if (data is! List) return [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(StudyScheduleBlock.fromJson)
          .toList();
    } catch (e) {
      debugPrint('AppRepository: Failed to decode weekly schedule: $e');
      return [];
    }
  }

  Map<String, Map<String, dynamic>> _decodeFlashcardMeta(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return {};
      final result = <String, Map<String, dynamic>>{};
      for (final entry in data.entries) {
        if (entry.value is Map) {
          result[entry.key.toString()] =
              Map<String, dynamic>.from(entry.value as Map);
        }
      }
      return result;
    } catch (e) {
      debugPrint('AppRepository: Failed to decode flashcard meta: $e');
      return {};
    }
  }

  // --- MAPPERS ---

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
    final nets = <String, double>{};
    if (e.subjectNetsJson.isNotEmpty) {
      final decoded = jsonDecode(e.subjectNetsJson);
      if (decoded is Map) {
        decoded.forEach((k, v) {
          if (v is num) nets[k.toString()] = v.toDouble();
        });
      }
    }
    final mins = <String, int>{};
    if (e.subjectMinutesJson.isNotEmpty) {
      final decoded = jsonDecode(e.subjectMinutesJson);
      if (decoded is Map) {
        decoded.forEach((k, v) {
          if (v is num) mins[k.toString()] = v.round();
        });
      }
    }
    final meta = _mockExamMeta[e.originalId];
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
      subjectNets: nets,
      subjectMinutes: mins,
      examScope: meta?['examScope'] ?? 'Genel Deneme',
      focusSubject: meta?['focusSubject'] ?? '',
      focusTopic: meta?['focusTopic'] ?? '',
    );
  }

  Map<String, Map<String, String>> _decodeMockExamMeta(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return {};
      final result = <String, Map<String, String>>{};
      for (final entry in data.entries) {
        if (entry.value is Map) {
          final inner = <String, String>{};
          (entry.value as Map).forEach((k, v) {
            if (v != null) inner[k.toString()] = v.toString();
          });
          result[entry.key.toString()] = inner;
        }
      }
      return result;
    } catch (e) {
      debugPrint('AppRepository: Failed to decode mock exam meta: $e');
      return {};
    }
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
      ..aiInsights = m.aiInsights
          .map(
            (i) => TopicInsightEntity()
              ..originalId = i.id
              ..summary = i.summary
              ..notes = i.notes
              ..createdAt = i.createdAt,
          )
          .toList();
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
      aiInsights: e.aiInsights
          .map(
            (i) => TopicInsight(
              id: i.originalId,
              summary: i.summary,
              notes: i.notes,
              createdAt: i.createdAt,
            ),
          )
          .toList(),
    );
  }

  FlashcardEntity _mapToFlashcardEntity(Flashcard m, String topic) {
    return FlashcardEntity()
      ..originalId = m.id
      ..topicTitle = topic
      ..question = m.question
      ..answer = m.answer
      ..hint = m.hint;
  }

  Flashcard _mapFromFlashcardEntity(FlashcardEntity e) {
    final meta = _flashcardMeta[e.originalId];
    return Flashcard(
      id: e.originalId,
      question: e.question,
      answer: e.answer,
      hint: e.hint,
      box: (meta?['box'] as num?)?.toInt() ?? 1,
      nextReview: meta?['nextReview'] is String
          ? (DateTime.tryParse(meta!['nextReview'] as String) ?? DateTime.now())
          : DateTime.now(),
      isLearned: meta?['isLearned'] as bool? ?? false,
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

  // --- QUERIES & ANALYTICS ---

  List<QuestionEntry> entriesForTopic(String topic, {String? subject}) {
    return questionEntries.value.where((entry) {
      if (entry.topic != topic) return false;
      if (subject != null && subject.isNotEmpty) {
        return entry.subject == subject;
      }
      return true;
    }).toList();
  }

  List<QuestionEntry> entriesForSubject(String subject) {
    return questionEntries.value
        .where((entry) => entry.subject == subject)
        .toList();
  }

  List<TopicProgress> buildTopicProgress({String? tag, String? subject}) {
    final entries = questionEntries.value;
    final filteredTopics = topics.where((topic) {
      if (tag != null && tag != 'Tümü' && topic.tag != tag) return false;
      if (subject != null && subject != 'Tümü' && topic.subject != subject) {
        return false;
      }
      return true;
    });

    return filteredTopics.map((topic) {
      final topicEntries = entries
          .where((entry) =>
              entry.subject == topic.subject && entry.topic == topic.title)
          .toList();
      return TopicProgress.fromEntries(topic, topicEntries);
    }).toList();
  }

  List<TopicProgress> weakestTopics({
    int limit = 3,
    String? tag,
    String? subject,
  }) {
    final progress = buildTopicProgress(tag: tag, subject: subject)
        .where((item) => item.totalQuestions > 0)
        .toList();
    progress.sort((a, b) {
      final aPriority = (1 - a.accuracy) * a.topic.importance;
      final bPriority = (1 - b.accuracy) * b.topic.importance;
      return bPriority.compareTo(aPriority);
    });
    if (progress.length <= limit) return progress;
    return progress.sublist(0, limit);
  }

  int calculateCurrentStreak() {
    final activityDates = <DateTime>{};
    for (final entry in questionEntries.value) {
      activityDates.add(
        DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day),
      );
    }
    for (final exam in mockExams.value) {
      activityDates.add(
        DateTime(exam.createdAt.year, exam.createdAt.month, exam.createdAt.day),
      );
    }
    if (activityDates.isEmpty) return 0;

    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!activityDates.contains(cursor)) {
      final yesterday = cursor.subtract(const Duration(days: 1));
      if (!activityDates.contains(yesterday)) return 0;
      cursor = yesterday;
    }

    var streak = 0;
    while (activityDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String buildWeeklyScheduleSummary() {
    final blocks = weeklySchedule.value;
    if (blocks.isEmpty) {
      final program = aiProgramLast.value;
      if (program != null && program.trim().isNotEmpty) {
        final firstLine = program.trim().split('\n').first;
        return firstLine.length > 120
            ? '${firstLine.substring(0, 120)}…'
            : firstLine;
      }
      return 'Bu hafta için çalışma programını planla.';
    }
    final todayBlocks = scheduleForDay(DateTime.now().weekday);
    if (todayBlocks.isNotEmpty) {
      final subjects = todayBlocks.map((b) => b.subject).toSet().join(', ');
      return 'Bugünkü programında ${todayBlocks.length} blok var: $subjects';
    }
    return 'Haftalık programında ${blocks.length} çalışma bloğu planlı.';
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
