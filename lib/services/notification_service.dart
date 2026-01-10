import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int reminderId = 7001;
  static const int weeklyPlanId = 7010;
  static const int focusEndId = 7020;

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    if (!kIsWeb) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      
      // Check for exact alarm permission on Android 12+
      final bool? canScheduleExactAlarms = await android?.areNotificationsEnabled();
      // Note: There isn't a direct API to request SCHEDULE_EXACT_ALARM permission from within Dart.
      // If needed, user must grant it manually in system settings.
      // We can check if it's granted or inform the user.
      // For now, we rely on the fallback to inexact alarms if exact fails.
      // If notifications are consistently missing, this is a key area to investigate on device settings.
      debugPrint('NotificationService: Notifications permission granted: $canScheduleExactAlarms');
    }

    tz.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  }

  static Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final bool? granted = await android.requestExactAlarmsPermission();
    return granted ?? false;
  }

  static Future<void> scheduleDailyReminder(String time) async {
    final parts = time.split(':');
    if (parts.length != 2) {
      return;
    }
    final hour = int.tryParse(parts[0]) ?? 20;
    final minute = int.tryParse(parts[1]) ?? 0;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _safeZonedSchedule(
      id: reminderId,
      title: 'Günlük Hedef Hatırlatma',
      body: 'Hedefini tamamlamak için bugün kalan soruları bitir.',
      scheduled: scheduled,
      channelId: 'daily_goal',
      channelName: 'Günlük Hedef',
      channelDescription: 'Günlük hedef hatırlatmaları',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(reminderId);
  }

  static Future<void> scheduleWeeklyPlan({
    required String time,
    required int weekday,
  }) async {
    final parts = time.split(':');
    if (parts.length != 2) {
      return;
    }
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    await _safeZonedSchedule(
      id: weeklyPlanId,
      title: 'Haftalık Plan Hatırlatma',
      body: 'Bu hafta için çalışma planını güncelle.',
      scheduled: scheduled,
      channelId: 'weekly_plan',
      channelName: 'Haftalık Plan',
      channelDescription: 'Haftalık plan hatırlatmaları',
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  static Future<void> scheduleWeeklyPlanWithBody({
    required String time,
    required int weekday,
    required String body,
  }) async {
    final parts = time.split(':');
    if (parts.length != 2) {
      return;
    }
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    await _safeZonedSchedule(
      id: weeklyPlanId,
      title: 'Haftalık Plan Hatırlatma',
      body: body,
      scheduled: scheduled,
      channelId: 'weekly_plan',
      channelName: 'Haftalık Plan',
      channelDescription: 'Haftalık plan hatırlatmaları',
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  static Future<void> cancelWeeklyPlan() async {
    await _plugin.cancel(weeklyPlanId);
  }

  static Future<void> scheduleFocusEnd(int seconds) async {
    final scheduled = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    try {
      await _plugin.zonedSchedule(
        focusEndId,
        'Odak Süresi Bitti',
        'Harika iş çıkardın! Şimdi kısa bir mola verme vakti.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'focus_timer',
            'Odak Zamanlayıcı',
            channelDescription: 'Odak süresi bitiş bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Fallback if exact alarm not allowed
      await _plugin.zonedSchedule(
        focusEndId,
        'Odak Süresi Bitti',
        'Harika iş çıkardın! Şimdi kısa bir mola verme vakti.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'focus_timer',
            'Odak Zamanlayıcı',
            channelDescription: 'Odak süresi bitiş bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelFocusEnd() async {
    await _plugin.cancel(focusEndId);
  }

  static Future<void> showReminderNow(String message) async {
    await _plugin.show(
      reminderId + 1,
      'Günlük Hedef Hatırlatma',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_goal_instant',
          'Günlük Hedef (Anlık)',
          channelDescription: 'Anlık hedef hatırlatmaları',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final scheduled = tz.TZDateTime.from(dateTime, tz.local);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'topic_review',
            'Konu Hatırlatmaları',
            channelDescription: 'Konu bazlı tekrar hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'topic_review',
            'Konu Hatırlatmaları',
            channelDescription: 'Konu bazlı tekrar hatırlatmaları',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduled,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required DateTimeComponents matchDateTimeComponents,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: importance,
            priority: priority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationService: Exact alarm failed, falling back. Error: $e');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: importance,
            priority: priority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }
}
