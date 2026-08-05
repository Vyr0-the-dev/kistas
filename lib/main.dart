import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/splash/screens/splash_screen.dart';
import 'core/repositories/app_repository.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/data/database_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseService();
  await db.init();
  final repository = await AppRepository.init(db);
  await NotificationService.init();
  await NotificationService.scheduleMistakeReminder();
  
  if (repository.reminderEnabled.value) {
    await NotificationService.scheduleDailyReminder(
      repository.reminderTime.value,
    );
  }
  if (repository.weeklyPlanEnabled.value) {
    await NotificationService.scheduleWeeklyPlanWithBody(
      time: repository.weeklyPlanTime.value,
      weekday: repository.weeklyPlanWeekday.value,
      body: _buildWeeklyPlanBody(repository),
    );
  }
  runApp(KistasApp(repository: repository));
}

String _buildWeeklyPlanBody(AppRepository repository) {
  final program = repository.aiProgramLast.value;
  if (program == null || program.trim().isEmpty) {
    return 'Bu hafta için çalışma planını güncelle.';
  }
  final trimmed = program.trim();
  final firstLine = trimmed.split('\n').first;
  return firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
}

class KistasApp extends StatelessWidget {
  const KistasApp({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return AppRepositoryScope(
      repository: repository,
      child: ValueListenableBuilder<String>(
        valueListenable: repository.themeKey,
        builder: (context, themeKey, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Kıstas',
            theme: buildAppTheme(themeKey),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
            ],
            locale: const Locale('tr', 'TR'),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
