class Flashcard {
  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.hint,
    this.box = 1,
    required this.nextReview,
    this.isLearned = false,
    this.topicTitle = '',
  });

  final String id;
  final String question;
  final String answer;
  final String? hint;
  final int box;
  final DateTime nextReview;
  final bool isLearned;
  final String topicTitle;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'hint': hint,
      'box': box,
      'nextReview': nextReview.toIso8601String(),
      'isLearned': isLearned,
      'topicTitle': topicTitle,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      hint: json['hint'] as String?,
      box: json['box'] as int? ?? 1,
      nextReview: DateTime.tryParse(json['nextReview'] as String? ?? '') ??
          DateTime.now(),
      isLearned: json['isLearned'] as bool? ?? false,
      topicTitle: json['topicTitle'] as String? ?? '',
    );
  }
}