class Flashcard {
  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.hint,
    required this.topicTitle,
  });

  final String id;
  final String question;
  final String answer;
  final String? hint;
  final String topicTitle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'hint': hint,
        'topicTitle': topicTitle,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'],
        question: json['question'],
        answer: json['answer'],
        hint: json['hint'],
        topicTitle: json['topicTitle'],
      );
}
