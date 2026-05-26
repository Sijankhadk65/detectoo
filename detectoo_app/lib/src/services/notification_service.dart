import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages local notifications for recovery step reminders.
///
/// Each uncompleted recovery step gets a daily notification keyed on
/// its server-assigned [stepId]. Call [cancelStepReminder] when the
/// step is marked done to stop the repeating notification.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'recovery_steps';
  static const _channelName = 'Recovery Steps';

  static const _androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Daily reminders for plant recovery steps',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  /// Initialises the plugin and requests permission on Android 13+ / iOS.
  ///
  /// Must be called before [scheduleStepReminder] or [cancelStepReminder].
  static Future<void> init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(settings: initSettings);

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Schedules a daily notification for a recovery step.
  ///
  /// [stepId] is used directly as the notification ID, so calling this
  /// twice with the same [stepId] replaces the previous notification.
  static Future<void> scheduleStepReminder({
    required int stepId,
    required String plantName,
    required String stepTitle,
  }) async {
    await _plugin.periodicallyShow(
      id: stepId,
      title: stepTitle,
      body: 'Recovery reminder for $plantName — tap to check progress.',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancels the daily notification for a step (call when step is done).
  static Future<void> cancelStepReminder(int stepId) async {
    await _plugin.cancel(id: stepId);
  }

  /// Cancels all step reminders for a list of step IDs (call on plan deletion).
  static Future<void> cancelAllStepReminders(List<int> stepIds) async {
    for (final id in stepIds) {
      await _plugin.cancel(id: id);
    }
  }
}
