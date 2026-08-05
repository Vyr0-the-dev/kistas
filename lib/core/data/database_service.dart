import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'entities/question_entity.dart';
import 'entities/mock_exam_entity.dart';
import 'entities/topic_entity.dart';
import 'entities/flashcard_entity.dart';
import 'entities/notification_entity.dart';

class DatabaseService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        QuestionEntitySchema,
        MockExamEntitySchema,
        TopicEntitySchema,
        FlashcardEntitySchema,
        NotificationEntitySchema,
      ],
      directory: dir.path,
    );
  }

  Future<List<QuestionEntity>> getAllQuestions() async {
    return await isar.questionEntitys.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> addQuestion(QuestionEntity entity) async {
    await isar.writeTxn(() => isar.questionEntitys.put(entity));
  }

  Future<void> deleteQuestion(String originalId) async {
    await isar.writeTxn(() async {
      final q = await isar.questionEntitys.filter().originalIdEqualTo(originalId).findFirst();
      if (q != null) {
        await isar.questionEntitys.delete(q.id);
      }
    });
  }

  Future<void> markQuestionAsSolved(String originalId) async {
    await isar.writeTxn(() async {
      final q = await isar.questionEntitys.filter().originalIdEqualTo(originalId).findFirst();
      if (q != null) {
        q.isSolved = true;
        await isar.questionEntitys.put(q);
      }
    });
  }

  Future<List<MockExamEntity>> getAllMockExams() async {
    return await isar.mockExamEntitys.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> addMockExam(MockExamEntity entity) async {
    await isar.writeTxn(() => isar.mockExamEntitys.put(entity));
  }

  Future<List<TopicEntity>> getAllTopics() async {
    return await isar.topicEntitys.where().findAll();
  }

  Future<void> saveTopic(TopicEntity entity) async {
    await isar.writeTxn(() => isar.topicEntitys.put(entity));
  }

  Future<void> saveTopics(List<TopicEntity> entities) async {
    await isar.writeTxn(() => isar.topicEntitys.putAll(entities));
  }

  Future<void> deleteTopic(String originalId) async {
    await isar.writeTxn(() async {
      final topic = await isar.topicEntitys.filter().originalIdEqualTo(originalId).findFirst();
      if (topic != null) {
        await isar.topicEntitys.delete(topic.id);
      }
    });
  }

  Future<List<FlashcardEntity>> getAllFlashcards() async {
    return await isar.flashcardEntitys.where().findAll();
  }

  Future<void> saveFlashcard(FlashcardEntity entity) async {
    await isar.writeTxn(() => isar.flashcardEntitys.put(entity));
  }

  Future<void> deleteFlashcard(String originalId) async {
    await isar.writeTxn(() async {
      final card = await isar.flashcardEntitys.filter().originalIdEqualTo(originalId).findFirst();
      if (card != null) {
        await isar.flashcardEntitys.delete(card.id);
      }
    });
  }
  
  Future<void> clearFlashcardsForTopic(String topicTitle) async {
     await isar.writeTxn(() async {
      await isar.flashcardEntitys.filter().topicTitleEqualTo(topicTitle).deleteAll();
    });
  }

  Future<List<NotificationEntity>> getAllNotifications() async {
    return await isar.notificationEntitys.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> addNotification(NotificationEntity entity) async {
    await isar.writeTxn(() => isar.notificationEntitys.put(entity));
  }

  Future<void> markNotificationRead(String originalId) async {
    await isar.writeTxn(() async {
      final notif = await isar.notificationEntitys.filter().originalIdEqualTo(originalId).findFirst();
      if (notif != null) {
        notif.unread = false;
        await isar.notificationEntitys.put(notif);
      }
    });
  }
  
  Future<void> markAllNotificationsRead() async {
    await isar.writeTxn(() async {
      final unreads = await isar.notificationEntitys.filter().unreadEqualTo(true).findAll();
      for (final n in unreads) {
        n.unread = false;
        await isar.notificationEntitys.put(n);
      }
    });
  }

  Future<void> clearNotifications() async {
    await isar.writeTxn(() => isar.notificationEntitys.clear());
  }
}