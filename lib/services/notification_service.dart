import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleTransactionNotification({
    required String id,
    required ScheduledTransaction transaction,
    required DateTime scheduledDate,
  }) async {
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'scheduled_transactions',
      'Transacciones Programadas',
      channelDescription: 'Notificaciones para transacciones programadas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final tipoStr = transaction.tipo == TransactionType.ingreso ? 'Ingreso' : 'Egreso';
    final signo = transaction.tipo == TransactionType.ingreso ? '+' : '-';

    await _notifications.zonedSchedule(
      id.hashCode,
      '📅 Transacción programada: $tipoStr',
      '$signo\$${transaction.monto.toStringAsFixed(2)} - ${transaction.motivo}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: jsonEncode({
        'type': 'scheduled_transaction',
        'scheduleId': transaction.id,
      }),
    );
  }

  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'instant_transactions',
      'Transacciones Instantáneas',
      channelDescription: 'Notificaciones para transacciones registradas al momento',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}