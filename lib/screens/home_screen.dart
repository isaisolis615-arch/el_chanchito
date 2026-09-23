import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processScheduledTransactions();
    });
  }

  Future<void> _processScheduledTransactions() async {
    final service = ref.read(scheduledTransactionServiceProvider);
    await service.processPendingTransactions();
    ref.invalidate(transactionsProvider);
    ref.invalidate(divisionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisiones = ref.watch(divisionsProvider);
    final transacciones = ref.watch(filteredTransactionsProvider);
    final profile = ref.watch(userProfileProvider);
    final currency = ref.watch(currencyProvider);
    final filter = ref.watch(filterProvider);

    final totalIngresos = transacciones
        .where((t) => t.esIngreso)
        .fold(0.0, (sum, t) => sum + t.monto);
    final totalEgresos = transacciones
        .where((t) => !t.esIngreso)
        .fold(0.0, (sum, t) => sum + t.monto);
    final balance = totalIngresos - totalEgresos;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'El Chanchito',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                profile.nombre.isNotEmpty ? profile.nombre[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Transacción', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(divisionsProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(scheduledTransactionsProvider);
        },
        child: CustomScrollView(
          slivers: [
            if (divisiones.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mis Divisiones',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/divisions'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: divisiones.length + 1,
                    itemBuilder: (context, index) {
                      if (index == divisiones.length) {
                        return _AddDivisionCard(onTap: () => _showDivisionDialog(context));
                      }
                      final division = divisiones[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 180,
                          child: DivisionCard(
                            division: division,
                            currency: currency,
                            onEdit: () => _showDivisionDialog(context, division: division),
                            onDelete: () => _confirmDeleteDivision(context, division),
                            onDuplicate: () => _duplicateDivision(context, division),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryColumn(
                          label: 'Ingresos',
                          value: totalIngresos.toCurrencyWithSign(currency),
                          color: Colors.green,
                        ),
                        Container(width: 1, height: 40, color: theme.colorScheme.outline),
                        _SummaryColumn(
                          label: 'Egresos',
                          value: totalEgresos.toCurrencyWithSign(currency, showPlus: false),
                          color: Colors.red,
                        ),
                        Container(width: 1, height: 40, color: theme.colorScheme.outline),
                        _SummaryColumn(
                          label: 'Balance',
                          value: balance.toCurrencyWithSign(currency),
                          color: balance >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Movimientos',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (filter.busqueda != null || filter.tipo != FilterType.todos || filter.tiempo != 'Todo')
                          TextButton.icon(
                            onPressed: () => ref.read(filterProvider.notifier).reset(),
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Limpiar'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const FilterChips(),
                    const SizedBox(height: 8),
                    const SearchField(),
                  ],
                ),
              ),
            ),
            if (transacciones.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.receipt_long,
                  title: 'Sin movimientos',
                  subtitle: _getEmptyMessage(filter),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaccion = transacciones[index];
                    final division = divisiones.firstWhere(
                      (d) => d.id == transaccion.divisionId,
                      orElse: () => Division(nombre: 'Desconocida', icono: 'folder'),
                    );
                    return TransactionTile(
                      transaction: transaccion,
                      division: division,
                      currency: currency,
                      onLongPress: () => _showDeleteDialog(context, transaccion),
                    );
                  },
                  childCount: transacciones.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(profile.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(profile.email ?? 'Sin email configurado'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  profile.nombre.isNotEmpty ? profile.nombre[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Mis Divisiones'),
              onTap: () {
                Navigator.pop(context);
                context.push('/divisions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Transacciones Programadas'),
              onTap: () {
                Navigator.pop(context);
                context.push('/schedule');
              },
            ),
            ListTile(
              leading: Icon(profile.modoOscuro ? Icons.light_mode : Icons.dark_mode),
              title: Text(profile.modoOscuro ? 'Modo Claro' : 'Modo Oscuro'),
              onTap: () {
                Navigator.pop(context);
                ref.read(userProfileProvider.notifier).updateModoOscuro(!profile.modoOscuro);
                ref.read(themeServiceProvider).setThemeMode(
                  profile.modoOscuro ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage(FilterState filter) {
    if (filter.busqueda != null) return 'No se encontraron movimientos con "$filter.busqueda"';
    if (filter.tipo == FilterType.ingresos) return 'No hay ingresos en este período';
    if (filter.tipo == FilterType.egresos) return 'No hay egresos en este período';
    if (filter.tipo == FilterType.programados) return 'No hay transacciones programadas';
    if (filter.tiempo != 'Todo') return 'No hay movimientos en los últimos ${filter.tiempo.replaceAll('d', ' días')}';
    return 'Registra tu primera transacción';
  }

  void _showTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Qué deseas registrar?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_downward, color: Colors.green, size: 28),
              ),
              title: const Text('Nuevo Ingreso'),
              subtitle: const Text('Registrar dinero que entra'),
              onTap: () {
                Navigator.pop(context);
                context.push('/transaction?type=ingreso');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward, color: Colors.red, size: 28),
              ),
              title: const Text('Nuevo Egreso'),
              subtitle: const Text('Registrar dinero que sale'),
              onTap: () {
                Navigator.pop(context);
                context.push('/transaction?type=egreso');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.schedule, color: Colors.blue, size: 28),
              ),
              title: const Text('Transacción Programada'),
              subtitle: const Text('Crear ingreso/egreso recurrente'),
              onTap: () {
                Navigator.pop(context);
                context.push('/schedule/new');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDivisionDialog(BuildContext context, {Division? division}) {
    showDialog(
      context: context,
      builder: (context) => _DivisionDialog(division: division),
    );
  }

  void _showDeleteDialog(BuildContext context, Transaction transaccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ¿Borrar movimiento?'),
        content: const Text('Se eliminará del historial y el saldo de la división afectada se reajustará automáticamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              final divisiones = ref.read(divisionsProvider);
              final division = divisiones.firstWhere((d) => d.id == transaccion.divisionId);
              final nuevoSaldo = transaccion.esIngreso
                  ? division.saldo - transaccion.monto
                  : division.saldo + transaccion.monto;

              await ref.read(divisionsProvider.notifier).updateSaldo(transaccion.divisionId, nuevoSaldo);
              await ref.read(transactionsProvider.notifier).delete(transaccion.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Movimiento eliminado y saldo recalculado')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDivision(BuildContext context, Division division) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar división?'),
        content: Text('Se eliminará "${division.nombre}". Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              await ref.read(divisionsProvider.notifier).delete(division.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('División eliminada')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _duplicateDivision(BuildContext context, Division division) {
    final nueva = division.copyWith(
      id: null,
      nombre: '${division.nombre} (copia)',
    );
    ref.read(divisionsProvider.notifier).add(nueva);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('División duplicada')));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Se cerrará la sesión actual. Los datos locales se mantendrán.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _AddDivisionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddDivisionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text('Nueva División', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _DivisionDialog extends ConsumerStatefulWidget {
  final Division? division;

  const _DivisionDialog({this.division});

  @override
  ConsumerState<_DivisionDialog> createState() => _DivisionDialogState();
}

class _DivisionDialogState extends ConsumerState<_DivisionDialog> {
  late final TextEditingController _nombreController;
  late final TextEditingController _saldoController;
  late String _selectedIcon;
  late String? _selectedColor;
  late bool _esEdicion;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.division != null;
    _nombreController = TextEditingController(text: widget.division?.nombre ?? '');
    _saldoController = TextEditingController(text: widget.division?.saldo.toString() ?? '0');
    _selectedIcon = widget.division?.icono ?? 'folder';
    _selectedColor = widget.division?.colorHex;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_esEdicion ? 'Editar División' : 'Nueva División'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _saldoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Saldo inicial', border: OutlineInputBorder(), prefixText: '\$ '),
            ),
            const SizedBox(height: 16),
            IconPicker(selectedIcon: _selectedIcon, onIconSelected: (icon) => setState(() => _selectedIcon = icon)),
            const SizedBox(height: 16),
            ColorPicker(selectedColor: _selectedColor, onColorSelected: (color) => setState(() => _selectedColor = color)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            if (_nombreController.text.trim().isEmpty) return;
            final saldo = double.tryParse(_saldoController.text.trim()) ?? 0.0;

            if (_esEdicion) {
              final updated = widget.division!.copyWith(
                nombre: _nombreController.text.trim(),
                saldo: saldo,
                icono: _selectedIcon,
                colorHex: _selectedColor,
              );
              await ref.read(divisionsProvider.notifier).update(updated);
            } else {
              final nueva = Division(
                nombre: _nombreController.text.trim(),
                saldo: saldo,
                icono: _selectedIcon,
                colorHex: _selectedColor,
              );
              await ref.read(divisionsProvider.notifier).add(nueva);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(_esEdicion ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}