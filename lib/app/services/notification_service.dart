import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    timezone_data.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation('Asia/Jakarta'));

    final initialized = await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    if (initialized == false) {
      throw StateError('Inisialisasi notifikasi gagal.');
    }
    _isInitialized = true;
  }

  Future<bool> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationService belum diinisialisasi.');
    }
    if (!await _requestPermission()) return false;

    await _plugin.show(0, title, body, _notificationDetails);
    return true;
  }

  Future<bool> scheduleReminder({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationService belum diinisialisasi.');
    }
    if (!await _requestPermission()) return false;

    await _plugin.zonedSchedule(
      1,
      title,
      body,
      timezone.TZDateTime.now(timezone.local).add(const Duration(minutes: 1)),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  Future<bool> _requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'hydra_game_reminders',
      'Pengingat Hydra Games',
      channelDescription: 'Pengingat aktivitas Hydra Games.',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
