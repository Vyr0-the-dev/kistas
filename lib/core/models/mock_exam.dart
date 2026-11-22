class MockExam {
  const MockExam({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.totalNet,
    required this.minutes,
    required this.note,
    required this.createdAt,
    this.subjectNets = const {},
    this.subjectMinutes = const {},
    this.examType = 'Genel',
    this.examScope = 'Genel Deneme',
    this.focusSubject = '',
    this.focusTopic = '',
  });

  final String id;
  final String title;
  final String dateLabel;
  final int correct;
  final int wrong;
  final int blank;
  final double totalNet;
  final int minutes;
  final String note;
  final DateTime createdAt;
  final Map<String, double> subjectNets;
  final Map<String, int> subjectMinutes;
  final String examType;
  final String examScope; // 'Genel Deneme', 'Branş Denemesi', 'Konu Denemesi', etc.
  final String focusSubject;
  final String focusTopic;

  bool get isTopicExam =>
      examScope == 'Konu Denemesi' || focusTopic.trim().isNotEmpty;

  bool get isBranchExam =>
      examScope == 'Branş Denemesi' && focusTopic.trim().isEmpty;

  String get scopeSummary {
    if (isTopicExam) {
      final parts = [
        if (focusSubject.isNotEmpty) focusSubject,
        if (focusTopic.isNotEmpty) focusTopic,
      ];
      return parts.isEmpty ? 'Konu Denemesi' : 'Konu Denemesi • ${parts.join(' - ')}';
    }
    if (isBranchExam && focusSubject.isNotEmpty) {
      return 'Branş • $focusSubject';
    }
    return examScope;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateLabel': dateLabel,
      'correct': correct,
      'wrong': wrong,
      'blank': blank,
      'totalNet': totalNet,
      'minutes': minutes,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'subjectNets': subjectNets,
      'subjectMinutes': subjectMinutes,
      'examType': examType,
      'examScope': examScope,
      'focusSubject': focusSubject,
      'focusTopic': focusTopic,
    };
  }

  factory MockExam.fromJson(Map<String, dynamic> json) {
    final nets = <String, double>{};
    final minutes = <String, int>{};
    final rawNets = json['subjectNets'];
    if (rawNets is Map) {
      for (final entry in rawNets.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key == null) continue;
        if (value is num) {
          nets[key] = value.toDouble();
        } else if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) nets[key] = parsed;
        }
      }
    }
    final rawMinutes = json['subjectMinutes'];
    if (rawMinutes is Map) {
      for (final entry in rawMinutes.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key == null) continue;
        if (value is num) {
          minutes[key] = value.round();
        } else if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) minutes[key] = parsed;
        }
      }
    }
    return MockExam(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
      correct: json['correct'] as int? ?? 0,
      wrong: json['wrong'] as int? ?? 0,
      blank: json['blank'] as int? ?? 0,
      totalNet: (json['totalNet'] as num?)?.toDouble() ?? 0,
      minutes: json['minutes'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      subjectNets: nets,
      subjectMinutes: minutes,
      examType: json['examType'] as String? ?? 'Genel',
      examScope: json['examScope'] as String? ?? 'Genel Deneme',
      focusSubject: json['focusSubject'] as String? ?? '',
      focusTopic: json['focusTopic'] as String? ?? '',
    );
  }
}
