import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String nombre;
  final String? email;
  final String? avatarPath;
  final String currencyCode;
  final String languageCode;
  final bool notificacionesActivas;
  final bool modoOscuro;
  final int diasRetencion;
  final DateTime fechaCreacion;
  final DateTime? ultimaActualizacion;

  UserProfile({
    String? id,
    this.nombre = 'Usuario',
    this.email,
    this.avatarPath,
    this.currencyCode = 'USD',
    this.languageCode = 'es',
    this.notificacionesActivas = true,
    this.modoOscuro = false,
    this.diasRetencion = 0,
    DateTime? fechaCreacion,
    this.ultimaActualizacion,
  })  : id = id ?? const Uuid().v4(),
        fechaCreacion = fechaCreacion ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? nombre,
    String? email,
    String? avatarPath,
    String? currencyCode,
    String? languageCode,
    bool? notificacionesActivas,
    bool? modoOscuro,
    int? diasRetencion,
    DateTime? fechaCreacion,
    DateTime? ultimaActualizacion,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      currencyCode: currencyCode ?? this.currencyCode,
      languageCode: languageCode ?? this.languageCode,
      notificacionesActivas: notificacionesActivas ?? this.notificacionesActivas,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      diasRetencion: diasRetencion ?? this.diasRetencion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimaActualizacion: ultimaActualizacion ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'avatarPath': avatarPath,
      'currencyCode': currencyCode,
      'languageCode': languageCode,
      'notificacionesActivas': notificacionesActivas,
      'modoOscuro': modoOscuro,
      'diasRetencion': diasRetencion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'ultimaActualizacion': ultimaActualizacion?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      nombre: json['nombre'] as String? ?? 'Usuario',
      email: json['email'] as String?,
      avatarPath: json['avatarPath'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      languageCode: json['languageCode'] as String? ?? 'es',
      notificacionesActivas: json['notificacionesActivas'] as bool? ?? true,
      modoOscuro: json['modoOscuro'] as bool? ?? false,
      diasRetencion: json['diasRetencion'] as int? ?? 0,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
      ultimaActualizacion: json['ultimaActualizacion'] != null
          ? DateTime.parse(json['ultimaActualizacion'] as String)
          : null,
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;
  final String locale;
  final int decimalDigits;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
    this.decimalDigits = 2,
  });

  static const List<Currency> supported = [
    Currency(code: 'USD', name: 'Dólar estadounidense', symbol: '\$', locale: 'en_US'),
    Currency(code: 'ARS', name: 'Peso argentino', symbol: '\$', locale: 'es_AR'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', locale: 'de_DE'),
    Currency(code: 'MXN', name: 'Peso mexicano', symbol: '\$', locale: 'es_MX'),
    Currency(code: 'COP', name: 'Peso colombiano', symbol: '\$', locale: 'es_CO'),
    Currency(code: 'CLP', name: 'Peso chileno', symbol: '\$', locale: 'es_CL'),
    Currency(code: 'PEN', name: 'Sol peruano', symbol: 'S/', locale: 'es_PE'),
    Currency(code: 'UYU', name: 'Peso uruguayo', symbol: '\$', locale: 'es_UY'),
    Currency(code: 'BRL', name: 'Real brasileño', symbol: 'R\$', locale: 'pt_BR'),
    Currency(code: 'GBP', name: 'Libra esterlina', symbol: '£', locale: 'en_GB'),
    Currency(code: 'CAD', name: 'Dólar canadiense', symbol: '\$', locale: 'en_CA'),
    Currency(code: 'AUD', name: 'Dólar australiano', symbol: '\$', locale: 'en_AU'),
  ];

  static Currency? fromCode(String code) {
    try {
      return supported.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  static Currency get defaultCurrency => supported.firstWhere((c) => c.code == 'USD');
}

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String locale;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  static const List<AppLanguage> supported = [
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', locale: 'es'),
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', locale: 'en'),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', locale: 'pt'),
  ];

  static AppLanguage? fromCode(String code) {
    try {
      return supported.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }

  static AppLanguage get defaultLanguage => supported.firstWhere((l) => l.code == 'es');
}