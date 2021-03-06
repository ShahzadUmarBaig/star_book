import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal() {
    initialize();
  }
  List<String> notificationMessages = [
    'You only fail if you quit! Don\'t forget to input your mood. 😁',
    'Let\'s recognise emotional patterns in your life. 😊',
    'Don\'t forget to enter your mood. ⏰',
    '✨ StarBook is waiting for you! hop in, log your mood.',
    'Did you forget to eat your lunch? No! then dont\'t forget to enter your mood.',
    'Hey! you haven\'t entered your mood today. Do it now! 😃'
  ];

  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await currentTimeZone()));

    const InitializationSettings initSettings = InitializationSettings(
      android: const AndroidInitializationSettings('app_icon'),
      iOS: const IOSInitializationSettings(),
    );

    //TODO: Passing a function to onSelectNotification
    // which fires up when a notification
    // is tapped, navigating the user to other page or doing something else
    await _notification.initialize(initSettings);
  }

  /// Returns local timezone
  Future<String> currentTimeZone() async {
    return await FlutterNativeTimezone.getLocalTimezone();
  }

  /// Requesting permission to show notifications
  /// on [iOS]
  Future<bool> iosNotificationPermission() async {
    return await _notification
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Scheduling a notification to show everyday at a specifice time
  Future<void> scheduleDailyNotification({int hour, int minutes}) async {
    await _notification.zonedSchedule(
      1,
      'Reminder',
      'daily scheduled notification body',
      _nextInstanceOfSelectedTime(hour, minutes),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily notification channel id',
          'daily notification channel name',
          'daily notification description',
        ),
        iOS: IOSNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: 'notification subtitle',
            threadIdentifier: '1'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Checking whether the time selected by the user falls
  /// before or after the current date.
  tz.TZDateTime _nextInstanceOfSelectedTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime.local(now.year, now.month, now.day, hour, minutes);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
