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
  static const int mistakeReminderId = 7030;

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('notification_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.actionId == 'stop_alarm') {
          const MethodChannel('com.example.app/alarm').invokeMethod('stop');
        }
      },
    );

    if (!kIsWeb) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      
      final bool? canScheduleExactAlarms = await android?.areNotificationsEnabled();
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
    if (parts.length != 2) return;
    
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

  static Future<void> scheduleWeeklyPlanWithBody({
    required String time,
    required int weekday,
    required String body,
  }) async {
    final parts = time.split(':');
    if (parts.length != 2) return;
    
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
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
    );
  }

  static Future<void> cancelWeeklyPlan() async {
    await _plugin.cancel(weeklyPlanId);
  }

  static Future<void> scheduleMistakeReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for every Sunday at 18:00
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 0);
    
    while (scheduled.weekday != DateTime.sunday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    await _safeZonedSchedule(
      id: mistakeReminderId,
      title: 'Hata Defteri Tekrarı',
      body: 'Bu hafta biriktirdiğin hataları çözme vakti! Hadi eksiklerini kapat.',
      scheduled: scheduled,
      channelId: 'mistake_reminder',
      channelName: 'Hata Defteri Hatırlatıcı',
      channelDescription: 'Haftalık hatalı soru çözme hatırlatması',
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> scheduleFocusEnd(int seconds) async {
    final scheduled = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_timer',
        'Odak Zamanlayıcı',
        channelDescription: 'Odak süresi bitiş bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: 'notification_icon',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        focusEndId,
        'Odak Süresi Bitti',
        'Harika iş çıkardın! Şimdi kısa bir mola verme vakti.',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        focusEndId,
        'Odak Süresi Bitti',
        'Harika iş çıkardın! Şimdi kısa bir mola verme vakti.',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelFocusEnd() async {
    try {
      await _plugin.cancel(focusEndId);
    } catch (e) {
      debugPrint('NotificationService: Cancel focus error: $e');
    }
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
          icon: 'notification_icon',
        ),
      ),
    );
  }

  static Future<void> showFocusEndNotification() async {
    await _plugin.show(
      focusEndId,
      'Odak Süresi Bitti',
      'Harika iş çıkardın! Şimdi kısa bir mola verme vakti.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_timer',
          'Odak Zamanlayıcı',
          channelDescription: 'Odak süresi bitiş bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'notification_icon',
          actions: [
            AndroidNotificationAction(
              'stop_alarm', 
              'DURDUR', 
              showsUserInterface: true, // Bringing to foreground ensures the stop command hits the player
              cancelNotification: true,
            ),
          ],
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
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'topic_review',
        'Konu Hatırlatmaları',
        channelDescription: 'Konu bazlı tekrar hatırlatmaları',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'notification_icon',
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
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
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        icon: 'notification_icon',
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (e) {
      debugPrint('NotificationService: Exact alarm fallback. Error: $e');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }
}