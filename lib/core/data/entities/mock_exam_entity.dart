import 'package:isar/isar.dart';

part 'mock_exam_entity.g.dart';

@collection
class MockExamEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String title;
  late String dateLabel;
  late int correct;
  late int wrong;
  late int blank;
  late double totalNet;
  late int minutes;
  late String note;
  
  @Index()
  late DateTime createdAt;
  
  late String examType;

  // Embedded object simulation for Maps
  // Isar doesn't support Map directly, so we store JSON or list of embedded objects.
  // Using JSON string for flexibility with existing map data structure.
  late String subjectNetsJson; 
  late String subjectMinutesJson;
}
