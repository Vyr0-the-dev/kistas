class TopicInsight {
  const TopicInsight({
    required this.id,
    required this.summary,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String summary;
  final List<String> notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TopicInsight.fromJson(Map<String, dynamic> json) {
    return TopicInsight(
      id: json['id'] as String,
      summary: json['summary'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TopicSummary {
  const TopicSummary({
    required this.id,
    required this.subject,
    required this.title,
    required this.nextReview,
    this.summary = '',
    this.notes = const [],
    this.importance = 3, // 1: Low, 5: Critical
    this.aiInsights = const [],
    this.tag = 'KPSS',
  });

  final String id;
  final String subject;
  final String title;
  final String nextReview;
  final String summary;
  final List<String> notes;
  final int importance;
  final List<TopicInsight> aiInsights;
  final String tag;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'nextReview': nextReview,
      'summary': summary,
      'notes': notes,
      'importance': importance,
      'aiInsights': aiInsights.map((e) => e.toJson()).toList(),
      'tag': tag,
    };
  }

  factory TopicSummary.fromJson(Map<String, dynamic> json) {
    return TopicSummary(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? '',
      title: json['title'] as String? ?? '',
      nextReview: json['nextReview'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      notes: (json['notes'] as List<dynamic>?)?.cast<String>() ?? [],
      importance: json['importance'] as int? ?? 3,
      aiInsights: (json['aiInsights'] as List<dynamic>?)
              ?.map((e) => TopicInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tag: json['tag'] as String? ?? 'KPSS',
    );
  }

  TopicSummary copyWith({
    String? id,
    String? subject,
    String? title,
    String? nextReview,
    String? summary,
    List<String>? notes,
    int? importance,
    List<TopicInsight>? aiInsights,
    String? tag,
  }) {
    return TopicSummary(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      nextReview: nextReview ?? this.nextReview,
      summary: summary ?? this.summary,
      notes: notes ?? this.notes,
      importance: importance ?? this.importance,
      aiInsights: aiInsights ?? this.aiInsights,
      tag: tag ?? this.tag,
    );
  }
}
