import 'package:isar/isar.dart';

part 'notification_entity.g.dart';

@collection
class NotificationEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  late String title;
  late String body;
  
  @Index()
  late DateTime createdAt;
  
  late bool unread;
}
