class TopicSummary {
  const TopicSummary({
    required this.id,
    required this.subject,
    required this.title,
    required this.nextReview,
    this.summary = '',
    this.notes = const [],
  });

  final String id;
  final String subject;
  final String title;
  final String nextReview;
  final String summary;
  final List<String> notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'nextReview': nextReview,
      'summary': summary,
      'notes': notes,
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
    );
  }
}
