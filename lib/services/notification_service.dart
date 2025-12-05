import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_channel',
      'Recordatorios de Medicamentos',
      description: 'Notificaciones para tomar tus medicamentos',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  // PROGRAMAR NOTIFICACIONES
  static Future<void> scheduleMedicine(Medicine medicine) async {
    await cancelMedicine(medicine);

    final now = DateTime.now();

    for (int i = 0; i < medicine.times.length; i++) {
      DateTime baseDate = DateTime(
        now.year,
        now.month,
        now.day,
        medicine.times[i].hour,
        medicine.times[i].minute,
      );

      if (baseDate.isBefore(now)) {
        baseDate = baseDate.add(const Duration(days: 1));
      }

      for (int d = 0; d < 90; d++) {
        final scheduledDate = baseDate.add(Duration(days: d));
        final dayName = _dayName(scheduledDate.weekday);

        if (medicine.daysOfWeek.contains("Todos los días") ||
            medicine.daysOfWeek.contains(dayName)) {
          final int id = "${medicine.id}_$i$d".hashCode;

          final androidDetails = AndroidNotificationDetails(
            'medicine_channel',
            'Recordatorios',
            channelDescription: 'Es hora de tu medicamento',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

          final details = NotificationDetails(android: androidDetails);

          await _notifications.zonedSchedule(
            id,
            '¡Hora de tu medicamento!',
            '${medicine.name} - ${medicine.dosage}',
            tz.TZDateTime.from(scheduledDate, tz.local),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }
  }

  // CANCELAR TODAS LAS NOTIFICACIONES DE UN MEDICAMENTO
  static Future<void> cancelMedicine(Medicine medicine) async {
    for (int i = 0; i < 90; i++) {
      for (int j = 0; j < medicine.times.length; j++) {
        final int id = "${medicine.id}_$j$i".hashCode;
        await _notifications.cancel(id);
      }
    }
  }

  // NOMBRE DEL Dia
  static String _dayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return days[weekday - 1];
  }
}
