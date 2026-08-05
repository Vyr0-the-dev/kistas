import 'package:isar/isar.dart';

part 'flashcard_entity.g.dart';

@collection
class FlashcardEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String question;
  late String answer;
  String? hint;
  
  @Index()
  late String topicTitle;
}
