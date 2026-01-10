class QuestionEntry {
  const QuestionEntry({
    required this.id,
    required this.bookName,
    required this.subject,
    required this.topic,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.minutes,
    required this.note,
    required this.createdAt,
    this.errorTags = const [],
  });

  final String id;
  final String bookName;
  final String subject;
  final String topic;
  final int correct;
  final int wrong;
  final int blank;
  final int minutes;
  final String note;
  final DateTime createdAt;
  final List<String> errorTags;

  int get total => correct + wrong + blank;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'subject': subject,
      'topic': topic,
      'correct': correct,
      'wrong': wrong,
      'blank': blank,
      'minutes': minutes,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'errorTags': errorTags,
    };
  }

  factory QuestionEntry.fromJson(Map<String, dynamic> json) {
    final rawTags = json['errorTags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final item in rawTags) {
        if (item is String && item.trim().isNotEmpty) {
          tags.add(item);
        }
      }
    }
    return QuestionEntry(
      id: json['id'] as String,
      bookName: json['bookName'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      correct: json['correct'] as int? ?? 0,
      wrong: json['wrong'] as int? ?? 0,
      blank: json['blank'] as int? ?? 0,
      minutes: json['minutes'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      errorTags: tags,
    );
  }
}
