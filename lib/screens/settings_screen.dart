import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/services.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);
    final diasRetencion = ref.watch(diasRetencionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historial', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Conservar historial por:', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  diasRetencion.when(
                    data: (dias) => DropdownButtonFormField<int>(
                      initialValue: dias,
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 Días')),
                        DropdownMenuItem(value: 30, child: Text('30 Días')),
                        DropdownMenuItem(value: 90, child: Text('90 Días')),
                        DropdownMenuItem(value: 0, child: Text('Siempre (Sin límite)')),
                      ],
                      onChanged: (nuevoValor) async {
                        if (nuevoValor != null) {
                          await ref.read(userProfileProvider.notifier).updateDiasRetencion(nuevoValor);
                          ref.invalidate(diasRetencionProvider);
                        }
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette, color: theme.colorScheme.primary),
                  title: const Text('Tema'),
                  subtitle: Text(profile.modoOscuro ? 'Modo Oscuro' : 'Modo Claro'),
                  trailing: Switch(
                    value: profile.modoOscuro,
                    onChanged: (valor) {
                      ref.read(userProfileProvider.notifier).updateModoOscuro(valor);
                      ref.read(themeServiceProvider.notifier).setThemeMode(valor ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications, color: theme.colorScheme.primary),
                  title: const Text('Notificaciones'),
                  subtitle: Text(profile.notificacionesActivas ? 'Activadas' : 'Desactivadas'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
                        tooltip: 'Información sobre notificaciones',
                        onPressed: () => _showNotificationsInfo(context),
                      ),
                      Switch(
                        value: profile.notificacionesActivas,
                        onChanged: (valor) => ref.read(userProfileProvider.notifier).updateNotificaciones(valor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.table_view, color: theme.colorScheme.primary),
                  title: const Text('Exportar Historial a CSV'),
                  subtitle: const Text('Copia los datos al portapapeles para Excel'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportarCSV(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.backup, color: theme.colorScheme.primary),
                  title: const Text('Respaldar Datos'),
                  subtitle: const Text('Exportar todos los datos (próximamente)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                  title: const Text('Eliminar Todos los Datos', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Esta acción no se puede deshacer'),
                  onTap: () => _showConfirmDeleteAll(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: theme.colorScheme.primary),
                  title: const Text('Acerca de'),
                  subtitle: const Text('Versión 1.0.1'),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarCSV(BuildContext context, WidgetRef ref) async {
    final transacciones = ref.read(transactionsProvider);
    final divisiones = ref.read(divisionsProvider);
    final currency = ref.read(currencyProvider);

    if (transacciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay datos para exportar')));
      return;
    }

    final csv = ExportService.generateCSV(transacciones, divisiones, currency);
    await ExportService.copyToClipboard(csv);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📊 ¡CSV copiado al portapapeles! Ya puedes pegarlo en Excel.')),
      );
    }
  }

  void _showConfirmDeleteAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Eliminar TODOS los datos'),
        content: const Text('Se borrarán todas las divisiones, transacciones, programaciones y ajustes. Esta acción es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              await ref.read(localRepositoryProvider).clearAllData();
              ref.invalidate(divisionsProvider);
              ref.invalidate(transactionsProvider);
              ref.invalidate(scheduledTransactionsProvider);
              ref.invalidate(userProfileProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos los datos eliminados')));
              }
            },
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'El Chanchito',
      applicationVersion: '1.0.1',
      applicationIcon: const Icon(Icons.savings, size: 48, color: Colors.green),
      children: [
        const Text('Tu gestor de finanzas personal simple y privado.'),
        const SizedBox(height: 16),
        const Text('Datos guardados localmente en tu dispositivo.'),
      ],
    );
  }

  void _showNotificationsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Sobre las notificaciones'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Las notificaciones te avisan automáticamente cuando:\n\n'
            '• Se ejecuta una transacción programada (sueldo, alquiler, suscripciones)\n'
            '• Tienes un egreso recurrente próximo a vencer\n'
            '• Un ingreso programado se ha depositado\n\n'
            'Las notificaciones se envían en segundo plano aunque la app esté cerrada. '
            'Puedes activarlas o desactivarlas en cualquier momento desde aquí.\n\n'
            'Nota: En la versión web las notificaciones push no están disponibles, '
            'pero se muestran dentro de la app cuando la abres.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}