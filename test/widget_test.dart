import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kistas/core/data/database_service.dart';
import 'package:kistas/core/data/entities/flashcard_entity.dart';
import 'package:kistas/core/data/entities/mock_exam_entity.dart';
import 'package:kistas/core/data/entities/notification_entity.dart';
import 'package:kistas/core/data/entities/question_entity.dart';
import 'package:kistas/core/data/entities/topic_entity.dart';
import 'package:kistas/core/repositories/app_repository.dart';
import 'package:kistas/core/theme/app_theme.dart';
import 'package:kistas/features/dashboard/screens/main_screen.dart';

class _TestDatabaseService extends DatabaseService {
  @override
  Future<void> init() async {}
  @override
  Future<List<QuestionEntity>> getAllQuestions() async => [];
  @override
  Future<List<MockExamEntity>> getAllMockExams() async => [];
  @override
  Future<List<TopicEntity>> getAllTopics() async => [];
  @override
  Future<List<FlashcardEntity>> getAllFlashcards() async => [];
  @override
  Future<List<NotificationEntity>> getAllNotifications() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Uygulama ana ekranı hatasız açılıyor', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = _TestDatabaseService();
    await db.init();
    final repository = await AppRepository.init(db);

    expect(repository.themeKey.value, 'paper');

    await tester.pumpWidget(
      AppRepositoryScope(
        repository: repository,
        child: MaterialApp(
          theme: buildAppTheme(repository.themeKey.value),
          home: const MainScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Panel'), findsOneWidget);
    expect(find.text('Konular'), findsOneWidget);
    expect(find.text('Ekle'), findsOneWidget);
    expect(find.text('Analiz'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
