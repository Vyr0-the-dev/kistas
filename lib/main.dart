import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/splash/screens/splash_screen.dart';
import 'core/repositories/app_repository.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_colors.dart';
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
  return repository.buildWeeklyScheduleSummary();
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
          final palette = AppColors.resolvePalette(themeKey);
          final overlayStyle = palette.isDark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: palette.surface,
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: palette.surface,
                  systemNavigationBarIconBrightness: Brightness.dark,
                );
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: MaterialApp(
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
            ),
          );
        },
      ),
    );
  }
}
