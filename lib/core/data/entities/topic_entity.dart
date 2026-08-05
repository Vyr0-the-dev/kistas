import 'package:isar/isar.dart';

part 'topic_entity.g.dart';

@collection
class TopicEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String subject;
  late String title;
  late String nextReview;
  late String summary;
  late List<String> notes;
  late int importance;
  late String tag;

  // Embedded insights
  late List<TopicInsightEntity> aiInsights;
}

@embedded
class TopicInsightEntity {
  late String originalId;
  late String summary;
  late List<String> notes;
  late DateTime createdAt;
}
