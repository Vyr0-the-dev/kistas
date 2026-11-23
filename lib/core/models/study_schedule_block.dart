enum ScheduleRecurrence {
  weekly,
  biweekly,
  once,
  dailyInWeek,
  everyTwoDaysInWeek;

  static ScheduleRecurrence fromString(String? raw) {
    switch (raw) {
      case 'biweekly':
        return ScheduleRecurrence.biweekly;
      case 'once':
        return ScheduleRecurrence.once;
      case 'dailyInWeek':
        return ScheduleRecurrence.dailyInWeek;
      case 'everyTwoDaysInWeek':
        return ScheduleRecurrence.everyTwoDaysInWeek;
      default:
        return ScheduleRecurrence.weekly;
    }
  }

  bool get isWeekScopedMultiDay =>
      this == ScheduleRecurrence.dailyInWeek ||
      this == ScheduleRecurrence.everyTwoDaysInWeek;

  String get label {
    switch (this) {
      case ScheduleRecurrence.weekly:
        return 'Her Hafta';
      case ScheduleRecurrence.biweekly:
        return '2 Haftada Bir';
      case ScheduleRecurrence.once:
        return 'Tek Seferlik';
      case ScheduleRecurrence.dailyInWeek:
        return 'Her Gün (Bu Hafta)';
      case ScheduleRecurrence.everyTwoDaysInWeek:
        return '2 Günde Bir (Bu Hafta)';
    }
  }
}

class StudyScheduleBlock {
  const StudyScheduleBlock({
    required this.id,
    required this.weekday,
    required this.subject,
    this.topic = '',
    this.tag = 'Genel',
    this.startTime = '',
    this.durationMinutes = 45,
    this.targetQuestions = 30,
    this.isCompleted = false,
    this.sortOrder = 0,
    this.note = '',
    this.recurrence = ScheduleRecurrence.weekly,
    this.startWeekKey = '',
    this.completedWeeks = const [],
    this.videoUrl = '',
    this.imagePaths = const [],
  });

  final String id;
  final int weekday; // 1 (Monday) .. 7 (Sunday)
  final String subject;
  final String topic;
  final String tag;
  final String startTime;
  final int durationMinutes;
  final int targetQuestions;
  final bool isCompleted; // Legacy single-week completion fallback
  final int sortOrder;
  final String note;
  final ScheduleRecurrence recurrence;
  final String startWeekKey; // YYYY-MM-DD of Monday
  final List<String> completedWeeks; // List of YYYY-MM-DD Monday keys
  final String videoUrl;
  final List<String> imagePaths;

  static DateTime mondayOf(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final diff = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: diff));
  }

  static String weekKeyFor(DateTime date) {
    final monday = mondayOf(date);
    final y = monday.year.toString().padLeft(4, '0');
    final m = monday.month.toString().padLeft(2, '0');
    final d = monday.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime? parseWeekKey(String key) {
    if (key.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(key.trim());
    if (parsed == null) return null;
    return mondayOf(parsed);
  }

  static List<int> weekdaysForRecurrence(
    int startWeekday,
    ScheduleRecurrence recurrence,
  ) {
    final safeStart = startWeekday.clamp(DateTime.monday, DateTime.sunday);
    switch (recurrence) {
      case ScheduleRecurrence.weekly:
      case ScheduleRecurrence.biweekly:
      case ScheduleRecurrence.once:
        return [safeStart];
      case ScheduleRecurrence.dailyInWeek:
        return [for (var d = safeStart; d <= DateTime.sunday; d++) d];
      case ScheduleRecurrence.everyTwoDaysInWeek:
        return [for (var d = safeStart; d <= DateTime.sunday; d += 2) d];
    }
  }

  List<int> activeWeekdaysInWeek() =>
      weekdaysForRecurrence(weekday, recurrence);

  bool occursInWeek(DateTime weekMonday) {
    final target = mondayOf(weekMonday);
    final anchor = parseWeekKey(startWeekKey);

    switch (recurrence) {
      case ScheduleRecurrence.once:
      case ScheduleRecurrence.dailyInWeek:
      case ScheduleRecurrence.everyTwoDaysInWeek:
        if (anchor == null) return true;
        return target.year == anchor.year &&
            target.month == anchor.month &&
            target.day == anchor.day;
      case ScheduleRecurrence.weekly:
        if (anchor == null) return true;
        return !target.isBefore(anchor);
      case ScheduleRecurrence.biweekly:
        if (anchor == null) return true;
        if (target.isBefore(anchor)) return false;
        final weeksDiff = target.difference(anchor).inDays ~/ 7;
        return weeksDiff % 2 == 0;
    }
  }

  bool occursOnDay(DateTime weekMonday, int targetWeekday) {
    if (!occursInWeek(weekMonday)) return false;
    return activeWeekdaysInWeek().contains(targetWeekday);
  }

  String completionKey(String weekKey, {int? weekday}) {
    if (recurrence.isWeekScopedMultiDay) {
      final safeDay =
          (weekday ?? this.weekday).clamp(DateTime.monday, DateTime.sunday);
      return '$weekKey-d$safeDay';
    }
    return weekKey;
  }

  bool isCompletedForWeek(String weekKey, {int? weekday}) {
    final key = completionKey(weekKey, weekday: weekday);
    if (completedWeeks.contains(key)) return true;
    // Backward compatibility for legacy single-day blocks without completedWeeks
    if (!recurrence.isWeekScopedMultiDay &&
        completedWeeks.isEmpty &&
        isCompleted &&
        weekKey == weekKeyFor(DateTime.now())) {
      return true;
    }
    return false;
  }

  StudyScheduleBlock toggleCompletedForWeek(String weekKey, {int? weekday}) {
    final key = completionKey(weekKey, weekday: weekday);
    final next = Set<String>.from(completedWeeks);
    if (isCompletedForWeek(weekKey, weekday: weekday)) {
      next.remove(key);
      return copyWith(completedWeeks: next.toList(), isCompleted: false);
    }
    next.add(key);
    return copyWith(completedWeeks: next.toList(), isCompleted: true);
  }

  StudyScheduleBlock copyWith({
    String? id,
    int? weekday,
    String? subject,
    String? topic,
    String? tag,
    String? startTime,
    int? durationMinutes,
    int? targetQuestions,
    bool? isCompleted,
    int? sortOrder,
    String? note,
    ScheduleRecurrence? recurrence,
    String? startWeekKey,
    List<String>? completedWeeks,
    String? videoUrl,
    List<String>? imagePaths,
  }) {
    return StudyScheduleBlock(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      tag: tag ?? this.tag,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetQuestions: targetQuestions ?? this.targetQuestions,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      note: note ?? this.note,
      recurrence: recurrence ?? this.recurrence,
      startWeekKey: startWeekKey ?? this.startWeekKey,
      completedWeeks: completedWeeks ?? this.completedWeeks,
      videoUrl: videoUrl ?? this.videoUrl,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekday': weekday,
      'subject': subject,
      'topic': topic,
      'tag': tag,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'targetQuestions': targetQuestions,
      'isCompleted': isCompleted,
      'sortOrder': sortOrder,
      'note': note,
      'recurrence': recurrence.name,
      'startWeekKey': startWeekKey,
      'completedWeeks': completedWeeks,
      'videoUrl': videoUrl,
      'imagePaths': imagePaths,
    };
  }

  factory StudyScheduleBlock.fromJson(Map<String, dynamic> json) {
    final rawWeekday = (json['weekday'] as num?)?.toInt() ?? DateTime.monday;
    final rawCompleted = json['completedWeeks'];
    final completedList = rawCompleted is List
        ? rawCompleted.whereType<String>().where((e) => e.isNotEmpty).toList()
        : <String>[];
    final rawImages = json['imagePaths'];
    final imageList = rawImages is List
        ? rawImages.whereType<String>().where((e) => e.isNotEmpty).toList()
        : <String>[];

    return StudyScheduleBlock(
      id: json['id'] as String? ?? '',
      weekday: rawWeekday.clamp(DateTime.monday, DateTime.sunday),
      subject: json['subject'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      tag: json['tag'] as String? ?? 'Genel',
      startTime: json['startTime'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 45,
      targetQuestions: (json['targetQuestions'] as num?)?.toInt() ?? 30,
      isCompleted: json['isCompleted'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      note: json['note'] as String? ?? '',
      recurrence: ScheduleRecurrence.fromString(json['recurrence'] as String?),
      startWeekKey: json['startWeekKey'] as String? ?? '',
      completedWeeks: completedList,
      videoUrl: json['videoUrl'] as String? ?? '',
      imagePaths: imageList,
    );
  }
}
