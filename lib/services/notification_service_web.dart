import 'package:el_chanchito/models/models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<bool> requestPermissions() async => false;

  Future<void> scheduleTransactionNotification({
    required String id,
    required ScheduledTransaction transaction,
    required DateTime scheduledDate,
  }) async {}

  Future<void> cancelNotification(String id) async {}

  Future<void> cancelAll() async {}

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}
}