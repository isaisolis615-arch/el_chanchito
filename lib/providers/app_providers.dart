import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Inicializado en main.dart');
});

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  return SharedPreferencesRepository();
});

final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService(ref.read(localRepositoryProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final scheduledTransactionServiceProvider = Provider<ScheduledTransactionService>((ref) {
  return ScheduledTransactionService(ref.read(localRepositoryProvider));
});

class DivisionsNotifier extends StateNotifier<List<Division>> {
  final LocalRepository _repository;

  DivisionsNotifier(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final divisiones = await _repository.getDivisiones();
    state = divisiones;
  }

  Future<void> add(Division division) async {
    await _repository.addDivision(division);
    state = [...state, division];
  }

  Future<void> update(Division division) async {
    await _repository.updateDivision(division);
    state = state.map((d) => d.id == division.id ? division : d).toList();
  }

  Future<void> delete(String divisionId) async {
    await _repository.deleteDivision(divisionId);
    state = state.where((d) => d.id != divisionId).toList();
  }

  Future<void> updateSaldo(String divisionId, double nuevoSaldo) async {
    await _repository.updateDivisionSaldo(divisionId, nuevoSaldo);
    state = state.map((d) => d.id == divisionId ? d.copyWith(saldo: nuevoSaldo) : d).toList();
  }

  Future<void> refresh() async {
    await _load();
  }
}

final divisionsProvider = StateNotifierProvider<DivisionsNotifier, List<Division>>((ref) {
  return DivisionsNotifier(ref.read(localRepositoryProvider));
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final LocalRepository _repository;

  TransactionsNotifier(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final transacciones = await _repository.getTransacciones();
    state = transacciones;
  }

  Future<void> add(Transaction transaccion) async {
    await _repository.addTransaccion(transaccion);
    state = [transaccion, ...state];
  }

  Future<void> update(Transaction transaccion) async {
    await _repository.updateTransaccion(transaccion);
    state = state.map((t) => t.id == transaccion.id ? transaccion : t).toList();
  }

  Future<void> delete(String transaccionId) async {
    await _repository.deleteTransaccion(transaccionId);
    state = state.where((t) => t.id != transaccionId).toList();
  }

  Future<void> refresh() async {
    await _load();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref.read(localRepositoryProvider));
});

class ScheduledTransactionsNotifier extends StateNotifier<List<ScheduledTransaction>> {
  final LocalRepository _repository;

  ScheduledTransactionsNotifier(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final transacciones = await _repository.getScheduledTransacciones();
    state = transacciones;
  }

  Future<void> add(ScheduledTransaction transaccion) async {
    await _repository.addScheduledTransaccion(transaccion);
    state = [...state, transaccion];
  }

  Future<void> update(ScheduledTransaction transaccion) async {
    await _repository.updateScheduledTransaccion(transaccion);
    state = state.map((t) => t.id == transaccion.id ? transaccion : t).toList();
  }

  Future<void> delete(String transaccionId) async {
    await _repository.deleteScheduledTransaccion(transaccionId);
    state = state.where((t) => t.id != transaccionId).toList();
  }

  Future<void> toggleActive(String id, bool activa) async {
    final schedule = state.firstWhere((t) => t.id == id);
    final updated = schedule.copyWith(activa: activa);
    await update(updated);
  }

  Future<void> refresh() async {
    await _load();
  }
}

final scheduledTransactionsProvider = StateNotifierProvider<ScheduledTransactionsNotifier, List<ScheduledTransaction>>((ref) {
  return ScheduledTransactionsNotifier(ref.read(localRepositoryProvider));
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final LocalRepository _repository;

  UserProfileNotifier(this._repository) : super(UserProfile()) {
    _load();
  }

  Future<void> _load() async {
    final profile = await _repository.getUserProfile();
    state = profile;
  }

  Future<void> update(UserProfile profile) async {
    await _repository.saveUserProfile(profile);
    state = profile;
  }

  Future<void> updateNombre(String nombre) async {
    final updated = state.copyWith(nombre: nombre, ultimaActualizacion: DateTime.now());
    await update(updated);
  }

  Future<void> updateCurrency(String currencyCode) async {
    final updated = state.copyWith(currencyCode: currencyCode, ultimaActualizacion: DateTime.now());
    await update(updated);
  }

  Future<void> updateLanguage(String languageCode) async {
    final updated = state.copyWith(languageCode: languageCode, ultimaActualizacion: DateTime.now());
    await update(updated);
  }

  Future<void> updateNotificaciones(bool valor) async {
    final updated = state.copyWith(notificacionesActivas: valor, ultimaActualizacion: DateTime.now());
    await update(updated);
  }

  Future<void> updateModoOscuro(bool valor) async {
    final updated = state.copyWith(modoOscuro: valor, ultimaActualizacion: DateTime.now());
    await update(updated);
  }

  Future<void> updateDiasRetencion(int dias) async {
    await _repository.setDiasRetencion(dias);
    final updated = state.copyWith(diasRetencion: dias, ultimaActualizacion: DateTime.now());
    await update(updated);
  }

  Future<void> refresh() async {
    await _load();
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref.read(localRepositoryProvider));
});

enum FilterType { todos, ingresos, egresos, programados }

class FilterState {
  final FilterType tipo;
  final String tiempo;
  final String? busqueda;

  const FilterState({
    this.tipo = FilterType.todos,
    this.tiempo = 'Todo',
    this.busqueda,
  });

  FilterState copyWith({
    FilterType? tipo,
    String? tiempo,
    String? busqueda,
  }) {
    return FilterState(
      tipo: tipo ?? this.tipo,
      tiempo: tiempo ?? this.tiempo,
      busqueda: busqueda ?? this.busqueda,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setTipo(FilterType tipo) => state = state.copyWith(tipo: tipo);
  void setTiempo(String tiempo) => state = state.copyWith(tiempo: tiempo);
  void setBusqueda(String? busqueda) => state = state.copyWith(busqueda: busqueda);
  void reset() => state = const FilterState();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transacciones = ref.watch(transactionsProvider);
  final filter = ref.watch(filterProvider);
  final divisiones = ref.watch(divisionsProvider);

  var resultado = transacciones;

  switch (filter.tipo) {
    case FilterType.ingresos:
      resultado = resultado.where((t) => t.esIngreso).toList();
      break;
    case FilterType.egresos:
      resultado = resultado.where((t) => !t.esIngreso).toList();
      break;
    case FilterType.programados:
      resultado = resultado.where((t) => t.esProgramada).toList();
      break;
    case FilterType.todos:
      break;
  }

  if (filter.tiempo != 'Todo') {
    final ahora = DateTime.now();
    final diasLimite = filter.tiempo == '7d' ? 7 : filter.tiempo == '30d' ? 30 : 90;
    final fechaLimite = ahora.subtract(Duration(days: diasLimite));
    resultado = resultado.where((t) => t.fecha.isAfter(fechaLimite)).toList();
  }

  if (filter.busqueda != null && filter.busqueda!.isNotEmpty) {
    final query = filter.busqueda!.toLowerCase();
    resultado = resultado.where((t) =>
        t.motivo.toLowerCase().contains(query) ||
        t.lugar?.toLowerCase().contains(query) == true ||
        t.categoria?.toLowerCase().contains(query) == true).toList();
  }

  return resultado;
});

final currencyProvider = Provider<Currency>((ref) {
  final profile = ref.watch(userProfileProvider);
  return Currency.fromCode(profile.currencyCode) ?? Currency.defaultCurrency;
});

final languageProvider = Provider<AppLanguage>((ref) {
  final profile = ref.watch(userProfileProvider);
  return AppLanguage.fromCode(profile.languageCode) ?? AppLanguage.defaultLanguage;
});

final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final service = ref.read(themeServiceProvider);
  await service.initialize();
  return service.themeMode;
});

final diasRetencionProvider = FutureProvider<int>((ref) async {
  return ref.read(localRepositoryProvider).getDiasRetencion();
});