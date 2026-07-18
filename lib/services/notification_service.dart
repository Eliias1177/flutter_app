import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

/// Servicio de notificaciones a nivel de sistema.
/// Se usa para recordatorios REALES de notas/tareas con fecha límite,
/// no para eventos triviales como "iniciaste sesión" o "hiciste clic aquí".
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Abrir');
    const settings = InitializationSettings(android: androidInit, iOS: iosInit, linux: linuxInit);

    await _plugin.initialize(settings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Programa un recordatorio real para una nota con fecha/hora límite.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await init();
    // Convertimos explícitamente a UTC en vez de confiar en tz.local (que por
    // defecto queda en UTC si nunca se llama a setLocalLocation con la zona
    // real del dispositivo). Así el instante programado siempre es correcto,
    // sin importar la zona horaria del teléfono.
    final tzScheduled = tz.TZDateTime.from(scheduledDate.toUtc(), tz.UTC);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Recordatorios de notas',
          channelDescription: 'Notificaciones para recordatorios de tareas/notas con fecha límite',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);
}