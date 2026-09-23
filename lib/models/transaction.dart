import 'package:uuid/uuid.dart';

enum TransactionType { ingreso, egreso }

class Transaction {
  final String id;
  final double monto;
  final String motivo;
  final String divisionId;
  final TransactionType tipo;
  final DateTime fecha;
  final String? lugar;
  final bool esProgramada;
  final String? scheduleId;
  final String? categoria;

  Transaction({
    String? id,
    required this.monto,
    required this.motivo,
    required this.divisionId,
    required this.tipo,
    DateTime? fecha,
    this.lugar,
    this.esProgramada = false,
    this.scheduleId,
    this.categoria,
  })  : id = id ?? const Uuid().v4(),
        fecha = fecha ?? DateTime.now();

  bool get esIngreso => tipo == TransactionType.ingreso;

  Transaction copyWith({
    String? id,
    double? monto,
    String? motivo,
    String? divisionId,
    TransactionType? tipo,
    DateTime? fecha,
    String? lugar,
    bool? esProgramada,
    String? scheduleId,
    String? categoria,
  }) {
    return Transaction(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      motivo: motivo ?? this.motivo,
      divisionId: divisionId ?? this.divisionId,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      lugar: lugar ?? this.lugar,
      esProgramada: esProgramada ?? this.esProgramada,
      scheduleId: scheduleId ?? this.scheduleId,
      categoria: categoria ?? this.categoria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'motivo': motivo,
      'divisionId': divisionId,
      'tipo': tipo.name,
      'fecha': fecha.toIso8601String(),
      'lugar': lugar,
      'esProgramada': esProgramada,
      'scheduleId': scheduleId,
      'categoria': categoria,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String?,
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      motivo: json['motivo'] as String,
      divisionId: json['divisionId'] as String,
      tipo: TransactionType.values.firstWhere(
        (e) => e.name == (json['tipo'] as String? ?? 'egreso'),
        orElse: () => TransactionType.egreso,
      ),
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      lugar: json['lugar'] as String?,
      esProgramada: json['esProgramada'] as bool? ?? false,
      scheduleId: json['scheduleId'] as String?,
      categoria: json['categoria'] as String?,
    );
  }

  static const List<String> categoriasIngreso = [
    'Sueldo',
    'Freelance',
    'Inversiones',
    'Regalos',
    'Reembolsos',
    'Ventas',
    'Otros ingresos',
  ];

  static const List<String> categoriasEgreso = [
    '🍔 Comida',
    '🚌 Transporte',
    '💡 Servicios',
    '🛒 Compras',
    '💊 Salud',
    '🎮 Ocio',
    '🏠 Hogar',
    '📚 Educación',
    '✈️ Viajes',
    '🐾 Mascotas',
    '👶 Niños',
    '💇 Cuidado personal',
    '🎁 Regalos',
    '📱 Tecnología',
    '🚗 Vehículo',
    '🏦 Bancario',
    '📄 Impuestos',
    '📦 Otros gastos',
  ];

  static List<String> categoriasPara(TransactionType tipo) {
    return tipo == TransactionType.ingreso ? categoriasIngreso : categoriasEgreso;
  }

  static const List<double> quickAmounts = [10, 20, 50, 100, 200, 500, 1000];
}