import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

abstract class LocalRepository {
  Future<void> initialize();

  Future<List<Division>> getDivisiones();
  Future<void> saveDivisiones(List<Division> divisiones);
  Future<void> addDivision(Division division);
  Future<void> updateDivision(Division division);
  Future<void> deleteDivision(String divisionId);
  Future<void> updateDivisionSaldo(String divisionId, double nuevoSaldo);

  Future<List<Transaction>> getTransacciones();
  Future<void> saveTransacciones(List<Transaction> transacciones);
  Future<void> addTransaccion(Transaction transaccion);
  Future<void> updateTransaccion(Transaction transaccion);
  Future<void> deleteTransaccion(String transaccionId);

  Future<List<ScheduledTransaction>> getScheduledTransacciones();
  Future<void> saveScheduledTransacciones(List<ScheduledTransaction> transacciones);
  Future<void> addScheduledTransaccion(ScheduledTransaction transaccion);
  Future<void> updateScheduledTransaccion(ScheduledTransaction transaccion);
  Future<void> deleteScheduledTransaccion(String transaccionId);
  Future<void> updateUltimaEjecucion(String scheduleId, DateTime fecha);

  Future<UserProfile> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);

  Future<int> getDiasRetencion();
  Future<void> setDiasRetencion(int dias);

  Future<bool> getModoOscuro();
  Future<void> setModoOscuro(bool valor);

  Future<void> clearAllData();
}

class SharedPreferencesRepository implements LocalRepository {
  late SharedPreferences _prefs;

  static const String _keyDivisiones = 'divisiones';
  static const String _keyTransacciones = 'transacciones';
  static const String _keyScheduledTransacciones = 'scheduled_transacciones';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyDiasRetencion = 'dias_retencion';
  static const String _keyModoOscuro = 'modo_oscuro';
  static const String _keyInitialized = 'initialized';

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final initialized = _prefs.getBool(_keyInitialized) ?? false;
    if (!initialized) {
      await _seedDefaultData();
      await _prefs.setBool(_keyInitialized, true);
    }
  }

  Future<void> _seedDefaultData() async {
    final divisiones = <Division>[
      Division(
        nombre: 'Fondo General',
        saldo: 0.0,
        icono: 'account_balance_wallet',
        colorHex: '#4CAF50',
        esPrincipal: true,
      ),
      Division(
        nombre: 'Ahorros',
        saldo: 0.0,
        icono: 'savings',
        colorHex: '#2196F3',
      ),
    ];

    final profile = UserProfile(
      nombre: 'Usuario',
      currencyCode: 'USD',
      languageCode: 'es',
    );

    await saveDivisiones(divisiones);
    await saveTransacciones([]);
    await saveScheduledTransacciones([]);
    await saveUserProfile(profile);
    await setDiasRetencion(0);
    await setModoOscuro(false);
  }

  @override
  Future<List<Division>> getDivisiones() async {
    final jsonString = _prefs.getString(_keyDivisiones);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => Division.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveDivisiones(List<Division> divisiones) async {
    final jsonString = json.encode(divisiones.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyDivisiones, jsonString);
  }

  @override
  Future<void> addDivision(Division division) async {
    final divisiones = await getDivisiones();
    divisiones.add(division);
    await saveDivisiones(divisiones);
  }

  @override
  Future<void> updateDivision(Division division) async {
    final divisiones = await getDivisiones();
    final index = divisiones.indexWhere((d) => d.id == division.id);
    if (index != -1) {
      divisiones[index] = division;
      await saveDivisiones(divisiones);
    }
  }

  @override
  Future<void> deleteDivision(String divisionId) async {
    final divisiones = await getDivisiones();
    divisiones.removeWhere((d) => d.id == divisionId);
    await saveDivisiones(divisiones);

    final transacciones = await getTransacciones();
    transacciones.removeWhere((t) => t.divisionId == divisionId);
    await saveTransacciones(transacciones);

    final scheduled = await getScheduledTransacciones();
    scheduled.removeWhere((s) => s.divisionId == divisionId);
    await saveScheduledTransacciones(scheduled);
  }

  @override
  Future<void> updateDivisionSaldo(String divisionId, double nuevoSaldo) async {
    final divisiones = await getDivisiones();
    final index = divisiones.indexWhere((d) => d.id == divisionId);
    if (index != -1) {
      divisiones[index] = divisiones[index].copyWith(saldo: nuevoSaldo);
      await saveDivisiones(divisiones);
    }
  }

  @override
  Future<List<Transaction>> getTransacciones() async {
    final jsonString = _prefs.getString(_keyTransacciones);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveTransacciones(List<Transaction> transacciones) async {
    final jsonString = json.encode(transacciones.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyTransacciones, jsonString);
  }

  @override
  Future<void> addTransaccion(Transaction transaccion) async {
    final transacciones = await getTransacciones();
    transacciones.insert(0, transaccion);
    await saveTransacciones(transacciones);
  }

  @override
  Future<void> updateTransaccion(Transaction transaccion) async {
    final transacciones = await getTransacciones();
    final index = transacciones.indexWhere((t) => t.id == transaccion.id);
    if (index != -1) {
      transacciones[index] = transaccion;
      await saveTransacciones(transacciones);
    }
  }

  @override
  Future<void> deleteTransaccion(String transaccionId) async {
    final transacciones = await getTransacciones();
    transacciones.removeWhere((t) => t.id == transaccionId);
    await saveTransacciones(transacciones);
  }

  @override
  Future<List<ScheduledTransaction>> getScheduledTransacciones() async {
    final jsonString = _prefs.getString(_keyScheduledTransacciones);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => ScheduledTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveScheduledTransacciones(List<ScheduledTransaction> transacciones) async {
    final jsonString = json.encode(transacciones.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyScheduledTransacciones, jsonString);
  }

  @override
  Future<void> addScheduledTransaccion(ScheduledTransaction transaccion) async {
    final transacciones = await getScheduledTransacciones();
    transacciones.add(transaccion);
    await saveScheduledTransacciones(transacciones);
  }

  @override
  Future<void> updateScheduledTransaccion(ScheduledTransaction transaccion) async {
    final transacciones = await getScheduledTransacciones();
    final index = transacciones.indexWhere((t) => t.id == transaccion.id);
    if (index != -1) {
      transacciones[index] = transaccion;
      await saveScheduledTransacciones(transacciones);
    }
  }

  @override
  Future<void> deleteScheduledTransaccion(String transaccionId) async {
    final transacciones = await getScheduledTransacciones();
    transacciones.removeWhere((t) => t.id == transaccionId);
    await saveScheduledTransacciones(transacciones);
  }

  @override
  Future<void> updateUltimaEjecucion(String scheduleId, DateTime fecha) async {
    final transacciones = await getScheduledTransacciones();
    final index = transacciones.indexWhere((t) => t.id == scheduleId);
    if (index != -1) {
      transacciones[index] = transacciones[index].copyWith(ultimaEjecucion: fecha);
      await saveScheduledTransacciones(transacciones);
    }
  }

  @override
  Future<UserProfile> getUserProfile() async {
    final jsonString = _prefs.getString(_keyUserProfile);
    if (jsonString == null) {
      return UserProfile();
    }
    return UserProfile.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final jsonString = json.encode(profile.toJson());
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  @override
  Future<int> getDiasRetencion() async {
    return _prefs.getInt(_keyDiasRetencion) ?? 0;
  }

  @override
  Future<void> setDiasRetencion(int dias) async {
    await _prefs.setInt(_keyDiasRetencion, dias);
  }

  @override
  Future<bool> getModoOscuro() async {
    return _prefs.getBool(_keyModoOscuro) ?? false;
  }

  @override
  Future<void> setModoOscuro(bool valor) async {
    await _prefs.setBool(_keyModoOscuro, valor);
  }

  @override
  Future<void> clearAllData() async {
    await _prefs.clear();
    await initialize();
  }
}