class ExamProfile {
  const ExamProfile({
    required this.name,
    this.examDate,
    this.wrongPenalty = 0.25,
  });

  final String name;
  final DateTime? examDate;
  final double wrongPenalty;

  double calculateNet(int correct, int wrong) {
    return correct - (wrong * wrongPenalty);
  }

  String get penaltyLabel {
    if (wrongPenalty <= 0.001) return 'Cezasız (Yanlış götürmez)';
    if ((wrongPenalty - (1 / 3)).abs() < 0.02) return '3 Yanlış 1 Doğru';
    if ((wrongPenalty - 0.25).abs() < 0.01) return '4 Yanlış 1 Doğru';
    return '1/${(1 / wrongPenalty).round()} Yanlış';
  }

  ExamProfile copyWith({
    String? name,
    DateTime? examDate,
    bool clearExamDate = false,
    double? wrongPenalty,
  }) {
    return ExamProfile(
      name: name ?? this.name,
      examDate: clearExamDate ? null : (examDate ?? this.examDate),
      wrongPenalty: wrongPenalty ?? this.wrongPenalty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'examDate': examDate?.toIso8601String(),
      'wrongPenalty': wrongPenalty,
    };
  }

  factory ExamProfile.fromJson(Map<String, dynamic> json) {
    final rawDate = json['examDate'] as String?;
    return ExamProfile(
      name: (json['name'] as String? ?? 'Genel').trim(),
      examDate: rawDate == null ? null : DateTime.tryParse(rawDate),
      wrongPenalty: (json['wrongPenalty'] as num?)?.toDouble() ?? 0.25,
    );
  }
}
