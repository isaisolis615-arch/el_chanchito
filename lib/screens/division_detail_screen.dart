import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class DivisionDetailScreen extends ConsumerWidget {
  final String divisionId;

  const DivisionDetailScreen({super.key, required this.divisionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final divisiones = ref.watch(divisionsProvider);
    final transacciones = ref.watch(transactionsProvider);
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);

    final division = divisiones.firstWhere((d) => d.id == divisionId, orElse: () => Division(nombre: 'Desconocida', icono: 'folder'));
    final divTransacciones = transacciones.where((t) => t.divisionId == divisionId).toList();
    final ingresos = divTransacciones.where((t) => t.esIngreso).fold(0.0, (s, t) => s + t.monto);
    final egresos = divTransacciones.where((t) => !t.esIngreso).fold(0.0, (s, t) => s + t.monto);

    return Scaffold(
      appBar: AppBar(title: Text(division.nombre)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (division.colorHex != null ? Color(int.parse(division.colorHex!.replaceFirst('#', '0xFF'))) : theme.colorScheme.primary).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getIconData(division.icono),
                              color: division.colorHex != null ? Color(int.parse(division.colorHex!.replaceFirst('#', '0xFF'))) : theme.colorScheme.primary,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(division.nombre, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                if (division.esPrincipal)
                                  Text('División principal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(division.saldo.toCurrency(currency), style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: division.saldo >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(label: 'Ingresos', value: ingresos.toCurrencyWithSign(currency), color: Colors.green),
                          _StatColumn(label: 'Egresos', value: egresos.toCurrencyWithSign(currency, showPlus: false), color: Colors.red),
                          _StatColumn(label: 'Movimientos', value: divTransacciones.length.toString(), color: theme.colorScheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Historial', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(onPressed: () => _showTransactionDialog(context, ref, divisionId), icon: const Icon(Icons.add, size: 18), label: const Text('Registrar')),
                ],
              ),
            ),
          ),
          if (divTransacciones.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(icon: Icons.receipt_long, title: 'Sin movimientos', subtitle: 'Esta división no tiene transacciones aún'),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final t = divTransacciones[index];
                  return TransactionTile(
                    transaction: t,
                    division: division,
                    currency: currency,
                    onLongPress: () => _showDeleteDialog(context, ref, t, division),
                  );
                },
                childCount: divTransacciones.length,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wallet': return Icons.account_balance_wallet;
      case 'savings': return Icons.savings;
      case 'account_balance': return Icons.account_balance;
      case 'credit_card': return Icons.credit_card;
      case 'payments': return Icons.payments;
      case 'attach_money': return Icons.attach_money;
      case 'money': return Icons.money;
      case 'currency_exchange': return Icons.currency_exchange;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      case 'folder': default: return Icons.folder;
    }
  }

  void _showTransactionDialog(BuildContext context, WidgetRef ref, String divisionId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Qué deseas registrar?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle), child: const Icon(Icons.arrow_downward, color: Colors.green, size: 28)),
              title: const Text('Nuevo Ingreso'),
              onTap: () { Navigator.pop(context); context.push('/transaction?type=ingreso&divisionId=$divisionId'); },
            ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.red, size: 28)),
              title: const Text('Nuevo Egreso'),
              onTap: () { Navigator.pop(context); context.push('/transaction?type=egreso&divisionId=$divisionId'); },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Transaction t, Division division) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ¿Borrar movimiento?'),
        content: const Text('Se eliminará del historial y el saldo se reajustará.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              final nuevoSaldo = t.esIngreso ? division.saldo - t.monto : division.saldo + t.monto;
              await ref.read(divisionsProvider.notifier).updateSaldo(t.divisionId, nuevoSaldo);
              await ref.read(transactionsProvider.notifier).delete(t.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento eliminado')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}