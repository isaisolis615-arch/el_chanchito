import '../models/models.dart';
import '../repositories/repositories.dart';
import 'notification_service.dart';

class ScheduledTransactionService {
  final LocalRepository _repository;
  final NotificationService _notifications = NotificationService();

  ScheduledTransactionService(this._repository);

  Future<void> processPendingTransactions() async {
    final schedules = await _repository.getScheduledTransacciones();
    final ahora = DateTime.now();

    for (final schedule in schedules) {
      if (!schedule.activa) continue;
      if (schedule.fechaFin != null && schedule.fechaFin!.isBefore(ahora)) continue;

      final proximas = schedule.calcularProximasOcurrencias(limite: 1);
      if (proximas.isEmpty) continue;

      final proxima = proximas.first;
      final ultimaEjecucion = schedule.ultimaEjecucion;

      if (ultimaEjecucion != null && !_debeEjecutarse(ultimaEjecucion, proxima, schedule.frecuencia)) {
        continue;
      }

      if (proxima.isBefore(ahora) || proxima.isAtSameMomentAs(ahora)) {
        await _ejecutarTransaccion(schedule);
        await _repository.updateUltimaEjecucion(schedule.id, proxima);
        await _notifications.scheduleTransactionNotification(
          id: schedule.id,
          transaction: schedule,
          scheduledDate: proxima,
        );
      }
    }
  }

  bool _debeEjecutarse(DateTime ultima, DateTime proxima, ScheduleFrequency frecuencia) {
    switch (frecuencia) {
      case ScheduleFrequency.daily:
        return proxima.difference(ultima).inDays >= 1;
      case ScheduleFrequency.weekly:
        return proxima.difference(ultima).inDays >= 7;
      case ScheduleFrequency.biweekly:
        return proxima.difference(ultima).inDays >= 14;
      case ScheduleFrequency.monthly:
        return proxima.month != ultima.month || proxima.year != ultima.year;
      case ScheduleFrequency.quarterly:
        return (proxima.month - ultima.month).abs() >= 3 || proxima.year != ultima.year;
      case ScheduleFrequency.yearly:
        return proxima.year != ultima.year;
      case ScheduleFrequency.custom:
        return proxima.difference(ultima).inDays >= 30;
    }
  }

  Future<void> _ejecutarTransaccion(ScheduledTransaction schedule) async {
    final transaccion = Transaction(
      monto: schedule.monto,
      motivo: schedule.motivo,
      divisionId: schedule.divisionId,
      tipo: schedule.tipo,
      fecha: DateTime.now(),
      esProgramada: true,
      scheduleId: schedule.id,
    );

    await _repository.addTransaccion(transaccion);

    final divisiones = await _repository.getDivisiones();
    final divisionIndex = divisiones.indexWhere((d) => d.id == schedule.divisionId);
    if (divisionIndex != -1) {
      final division = divisiones[divisionIndex];
      final nuevoSaldo = schedule.tipo == TransactionType.ingreso
          ? division.saldo + schedule.monto
          : division.saldo - schedule.monto;
      await _repository.updateDivisionSaldo(schedule.divisionId, nuevoSaldo);
    }
  }

  Future<List<ScheduledTransaction>> getUpcomingExecutions({int days = 30}) async {
    final schedules = await _repository.getScheduledTransacciones();
    final ahora = DateTime.now();
    final limite = ahora.add(Duration(days: days));

    final upcoming = <ScheduledTransaction>[];
    for (final s in schedules) {
      if (!s.activa) continue;
      if (s.fechaFin != null && s.fechaFin!.isBefore(ahora)) continue;
      final occ = s.calcularProximasOcurrencias(limite: 5);
      if (occ.any((o) => o.isBefore(limite))) {
        upcoming.add(s);
      }
    }
    return upcoming;
  }
}