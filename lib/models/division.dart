import 'package:uuid/uuid.dart';

class Division {
  final String id;
  final String nombre;
  final double saldo;
  final String icono;
  final String? colorHex;
  final bool esPrincipal;
  final DateTime fechaCreacion;

  Division({
    String? id,
    required this.nombre,
    this.saldo = 0.0,
    this.icono = 'folder',
    this.colorHex,
    this.esPrincipal = false,
    DateTime? fechaCreacion,
  })  : id = id ?? const Uuid().v4(),
        fechaCreacion = fechaCreacion ?? DateTime.now();

  Division copyWith({
    String? id,
    String? nombre,
    double? saldo,
    String? icono,
    String? colorHex,
    bool? esPrincipal,
    DateTime? fechaCreacion,
  }) {
    return Division(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      saldo: saldo ?? this.saldo,
      icono: icono ?? this.icono,
      colorHex: colorHex ?? this.colorHex,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'saldo': saldo,
      'icono': icono,
      'colorHex': colorHex,
      'esPrincipal': esPrincipal,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] as String?,
      nombre: json['nombre'] as String,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      icono: json['icono'] as String? ?? 'folder',
      colorHex: json['colorHex'] as String?,
      esPrincipal: json['esPrincipal'] as bool? ?? false,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
    );
  }

  static List<String> get availableIcons => [
        'wallet',
        'savings',
        'folder',
        'account_balance',
        'credit_card',
        'payments',
        'attach_money',
        'money',
        'currency_exchange',
        'account_balance_wallet',
        'savings_outlined',
        'folder_special',
        'business',
        'store',
        'home',
        'directions_car',
        'local_grocery_store',
        'restaurant',
        'school',
        'medical_services',
        'flight',
        'hotel',
        'shopping_cart',
        'games',
        'sports_esports',
        'fitness_center',
        'pets',
        'child_care',
        'elderly',
        'volunteer_activism',
        'donate',
      ];

  static List<String> get suggestedColors => [
        '#4CAF50', // Green
        '#2196F3', // Blue
        '#FF9800', // Orange
        '#E91E63', // Pink
        '#9C27B0', // Purple
        '#00BCD4', // Cyan
        '#795548', // Brown
        '#607D8B', // Blue Grey
        '#F44336', // Red
        '#3F51B5', // Indigo
        '#009688', // Teal
        '#CDDC39', // Lime
        '#FFC107', // Amber
        '#FF5722', // Deep Orange
        '#673AB7', // Deep Purple
      ];
}