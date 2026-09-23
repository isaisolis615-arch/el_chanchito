import 'package:uuid/uuid.dart';
import 'transaction.dart';

enum ScheduleFrequency {
  daily('Diario', 'Cada N días'),
  weekly('Semanal', 'Día de la semana'),
  biweekly('Quincenal', 'Día 1 y 15 / 15 y fin de mes'),
  monthly('Mensual', 'Día fijo del mes'),
  quarterly('Trimestral', 'Cada 3 meses'),
  yearly('Anual', 'Una vez al año'),
  custom('Personalizada', 'Expresión cron');

  const ScheduleFrequency(this.label, this.description);
  final String label;
  final String description;
}

class ScheduledTransaction {
  final String id;
  final double monto;
  final String motivo;
  final String divisionId;
  final TransactionType tipo;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final ScheduleFrequency frecuencia;
  final int diaDelMes;
  final int? diaDeLaSemana;
  final bool activa;
  final DateTime? ultimaEjecucion;
  final DateTime fechaCreacion;

  ScheduledTransaction({
    String? id,
    required this.monto,
    required this.motivo,
    required this.divisionId,
    required this.tipo,
    required this.fechaInicio,
    this.fechaFin,
    required this.frecuencia,
    this.diaDelMes = 1,
    this.diaDeLaSemana,
    this.activa = true,
    this.ultimaEjecucion,
    DateTime? fechaCreacion,
  })  : id = id ?? const Uuid().v4(),
        fechaCreacion = fechaCreacion ?? DateTime.now();

  ScheduledTransaction copyWith({
    String? id,
    double? monto,
    String? motivo,
    String? divisionId,
    TransactionType? tipo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    ScheduleFrequency? frecuencia,
    int? diaDelMes,
    int? diaDeLaSemana,
    bool? activa,
    DateTime? ultimaEjecucion,
    DateTime? fechaCreacion,
  }) {
    return ScheduledTransaction(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      motivo: motivo ?? this.motivo,
      divisionId: divisionId ?? this.divisionId,
      tipo: tipo ?? this.tipo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      frecuencia: frecuencia ?? this.frecuencia,
      diaDelMes: diaDelMes ?? this.diaDelMes,
      diaDeLaSemana: diaDeLaSemana ?? this.diaDeLaSemana,
      activa: activa ?? this.activa,
      ultimaEjecucion: ultimaEjecucion ?? this.ultimaEjecucion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'motivo': motivo,
      'divisionId': divisionId,
      'tipo': tipo.name,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'frecuencia': frecuencia.name,
      'diaDelMes': diaDelMes,
      'diaDeLaSemana': diaDeLaSemana,
      'activa': activa,
      'ultimaEjecucion': ultimaEjecucion?.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory ScheduledTransaction.fromJson(Map<String, dynamic> json) {
    return ScheduledTransaction(
      id: json['id'] as String?,
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      motivo: json['motivo'] as String,
      divisionId: json['divisionId'] as String,
      tipo: TransactionType.values.firstWhere(
        (e) => e.name == (json['tipo'] as String? ?? 'egreso'),
        orElse: () => TransactionType.egreso,
      ),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'] as String)
          : null,
      frecuencia: ScheduleFrequency.values.firstWhere(
        (e) => e.name == (json['frecuencia'] as String? ?? 'monthly'),
        orElse: () => ScheduleFrequency.monthly,
      ),
      diaDelMes: json['diaDelMes'] as int? ?? 1,
      diaDeLaSemana: json['diaDeLaSemana'] as int?,
      activa: json['activa'] as bool? ?? true,
      ultimaEjecucion: json['ultimaEjecucion'] != null
          ? DateTime.parse(json['ultimaEjecucion'] as String)
          : null,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  List<DateTime> calcularProximasOcurrencias({int limite = 5}) {
    final List<DateTime> ocurrencias = [];
    DateTime actual = fechaInicio;
    final ahora = DateTime.now();
    final fin = fechaFin ?? ahora.add(const Duration(days: 365 * 2));

    while (ocurrencias.length < limite && actual.isBefore(fin)) {
      if (actual.isAfter(ahora) || actual.isAtSameMomentAs(ahora)) {
        ocurrencias.add(actual);
      }
      actual = _calcularSiguiente(actual);
    }
    return ocurrencias;
  }

  DateTime _calcularSiguiente(DateTime actual) {
    switch (frecuencia) {
      case ScheduleFrequency.daily:
        return actual.add(const Duration(days: 1));
      case ScheduleFrequency.weekly:
        return actual.add(const Duration(days: 7));
      case ScheduleFrequency.biweekly:
        if (actual.day == 1) {
          return DateTime(actual.year, actual.month, 15);
        } else {
          final nextMonth = actual.month == 12
              ? DateTime(actual.year + 1, 1, 1)
              : DateTime(actual.year, actual.month + 1, 1);
          return nextMonth;
        }
      case ScheduleFrequency.monthly:
        var nextMonth = actual.month + 1;
        var nextYear = actual.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        final daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final day = diaDelMes.clamp(1, daysInMonth);
        return DateTime(nextYear, nextMonth, day);
      case ScheduleFrequency.quarterly:
        var nextMonth = actual.month + 3;
        var nextYear = actual.year;
        if (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        final daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final day = diaDelMes.clamp(1, daysInMonth);
        return DateTime(nextYear, nextMonth, day);
      case ScheduleFrequency.yearly:
        var nextYear = actual.year + 1;
        final daysInMonth = DateTime(nextYear, actual.month + 1, 0).day;
        final day = diaDelMes.clamp(1, daysInMonth);
        return DateTime(nextYear, actual.month, day);
      case ScheduleFrequency.custom:
        return actual.add(const Duration(days: 30));
    }
  }

  bool get tieneProximasOcurrencias => calcularProximasOcurrencias(limite: 1).isNotEmpty;

  DateTime? get proximaOcurrencia {
    final occ = calcularProximasOcurrencias(limite: 1);
    return occ.isEmpty ? null : occ.first;
  }
}