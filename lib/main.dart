import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/app_repository.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await AppRepository.init();
  await NotificationService.init();
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
            debugShowCheckedModeBanner: false,
            title: 'Kıstas',
            theme: buildAppTheme(themeKey),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
