import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'repositories/repositories.dart';
import 'services/services.dart';
import 'screens/screens.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Inicializado en main()');
});

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/transaction',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'] ?? 'egreso';
        final divisionId = state.uri.queryParameters['divisionId'];
        return TransactionScreen(
          initialType: type == 'ingreso' ? TransactionType.ingreso : TransactionType.egreso,
          divisionId: divisionId,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/schedule',
      builder: (context, state) => const ScheduleScreen(),
    ),
    GoRoute(
      path: '/schedule/new',
      builder: (context, state) => const ScheduleNewScreen(),
    ),
    GoRoute(
      path: '/divisions/:divisionId',
      builder: (context, state) => DivisionDetailScreen(divisionId: state.pathParameters['divisionId']!),
    ),
  ],
);

class _AppInitData {
  final SharedPreferences prefs;
  final LocalRepository repository;
  final NotificationService notificationService;

  const _AppInitData({
    required this.prefs,
    required this.repository,
    required this.notificationService,
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AppInitializer(),
    ),
  );
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = ref.watch(appInitProvider.future);

    return FutureBuilder<_AppInitData>(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Error de inicialización', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SelectableText(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Stack trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(
                        snapshot.stackTrace.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final data = snapshot.data!;

        return ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(data.prefs),
          ],
          child: ElChanchitoApp(
            repository: data.repository,
            notificationService: data.notificationService,
          ),
        );
      },
    );
  }
}

final appInitProvider = FutureProvider<_AppInitData>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final repository = SharedPreferencesRepository();
  await repository.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  return _AppInitData(
    prefs: prefs,
    repository: repository,
    notificationService: notificationService,
  );
});

class ElChanchitoApp extends ConsumerWidget {
  final LocalRepository repository;
  final NotificationService notificationService;

  const ElChanchitoApp({
    super.key,
    required this.repository,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'El Chanchito',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Colors.green, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.green.shade800,
          titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          // ignore: prefer_const_constructors
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Colors.green.shade300, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.green.shade300,
          titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }
}