import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduledTransactionServiceProvider).processPendingTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(scheduledTransactionsProvider);
    final divisiones = ref.watch(divisionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Transacciones Programadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/schedule/new'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(scheduledTransactionsProvider);
        },
        child: schedules.isEmpty
            ? EmptyState(
                icon: Icons.schedule,
                title: 'Sin transacciones programadas',
                subtitle: 'Crea ingresos o egresos recurrentes automáticos',
                action: FilledButton.icon(
                  onPressed: () => context.push('/schedule/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear primera'),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final division = divisiones.firstWhere(
                    (d) => d.id == schedule.divisionId,
                    orElse: () => Division(nombre: 'Desconocida', icono: 'folder'),
                  );
                  return _ScheduleCard(
                    schedule: schedule,
                    division: division,
                    onTap: () => _showScheduleDialog(context, schedule),
                    onToggle: (activa) => ref.read(scheduledTransactionsProvider.notifier).toggleActive(schedule.id, activa),
                    onDelete: () => _confirmDelete(context, schedule),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/schedule/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Programada'),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, ScheduledTransaction schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ScheduleDetailSheet(schedule: schedule),
    );
  }

  void _confirmDelete(BuildContext context, ScheduledTransaction schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar programación?'),
        content: Text('Se eliminará "${schedule.motivo}" y no se ejecutará más.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              await ref.read(scheduledTransactionsProvider.notifier).delete(schedule.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduledTransaction schedule;
  final Division division;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.division,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = schedule.tipo == TransactionType.ingreso;
    final proxima = schedule.proximaOcurrencia;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.motivo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          '${division.nombre} • ${schedule.frecuencia.label}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Switch(value: schedule.activa, onChanged: onToggle),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? Colors.green : Colors.red,
                      label: isIncome ? 'Ingreso' : 'Egreso',
                      value: schedule.monto.toStringAsFixed(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                      label: 'Próxima',
                      value: proxima != null ? DateFormat('dd/MM/yyyy').format(proxima) : 'N/A',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.repeat,
                      color: Colors.purple,
                      label: 'Frecuencia',
                      value: schedule.frecuencia.label,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoChip({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScheduleDetailSheet extends StatelessWidget {
  final ScheduledTransaction schedule;

  const _ScheduleDetailSheet({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = schedule.tipo == TransactionType.ingreso;
    final proximas = schedule.calcularProximasOcurrencias(limite: 5);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: theme.colorScheme.outline, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.motivo, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${isIncome ? "Ingreso" : "Egreso"} programado', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(icon: Icons.attach_money, label: 'Monto', value: '${isIncome ? "+" : "-"}\$${schedule.monto.toStringAsFixed(2)}', color: isIncome ? Colors.green : Colors.red),
          _DetailRow(icon: Icons.account_balance_wallet, label: 'División', value: schedule.divisionId),
          _DetailRow(icon: Icons.repeat, label: 'Frecuencia', value: schedule.frecuencia.label),
          _DetailRow(icon: Icons.calendar_today, label: 'Inicio', value: DateFormat('dd/MM/yyyy').format(schedule.fechaInicio)),
          if (schedule.fechaFin != null)
            _DetailRow(icon: Icons.event_busy, label: 'Fin', value: DateFormat('dd/MM/yyyy').format(schedule.fechaFin!)),
          _DetailRow(icon: Icons.check_circle, label: 'Estado', value: schedule.activa ? 'Activa' : 'Inactiva', color: schedule.activa ? Colors.green : Colors.grey),
          const SizedBox(height: 16),
          if (proximas.isNotEmpty) ...[
            Text('Próximas ejecuciones:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...proximas.map((d) => ListTile(
              dense: true,
              leading: Icon(Icons.schedule, size: 20, color: theme.colorScheme.primary),
              title: Text(DateFormat('EEEE, dd/MM/yyyy').format(d)),
              trailing: Text(d.isBefore(DateTime.now()) ? 'Pendiente' : 'Programada', style: theme.textTheme.bodySmall?.copyWith(color: d.isBefore(DateTime.now()) ? Colors.orange : Colors.green)),
            )),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailRow({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text('$label:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color))),
        ],
      ),
    );
  }
}