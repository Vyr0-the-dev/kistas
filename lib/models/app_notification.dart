class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.unread = true,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool unread;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'unread': unread,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      unread: json['unread'] as bool? ?? true,
    );
  }

  AppNotification copyWith({bool? unread}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      unread: unread ?? this.unread,
    );
  }
}
