import 'package:isar/isar.dart';

part 'question_entity.g.dart';

@collection
class QuestionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String bookName;
  late String subject;
  
  @Index()
  late String topic;

  late int correct;
  late int wrong;
  late int blank;
  late int minutes;
  late String note;
  
  @Index()
  late DateTime createdAt;
  
  late List<String> errorTags;
  late String examType;
  
  List<String> imagePaths = [];
  bool isSolved = false;
}
