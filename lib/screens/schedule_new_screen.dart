import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class ScheduleNewScreen extends ConsumerStatefulWidget {
  final ScheduledTransaction? scheduleToEdit;

  const ScheduleNewScreen({super.key, this.scheduleToEdit});

  @override
  ConsumerState<ScheduleNewScreen> createState() => _ScheduleNewScreenState();
}

class _ScheduleNewScreenState extends ConsumerState<ScheduleNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _motivoController = TextEditingController();

  late TransactionType _tipo;
  String _selectedDivisionId = '';
  ScheduleFrequency _frecuencia = ScheduleFrequency.monthly;
  int _diaDelMes = 1;
  int? _diaDeLaSemana;
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;
  double? _selectedAmount;
  String? _selectedCategory;
  bool _activa = true;
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.scheduleToEdit != null;
    if (_esEdicion) {
      final s = widget.scheduleToEdit!;
      _tipo = s.tipo;
      _selectedDivisionId = s.divisionId;
      _montoController.text = s.monto.toString();
      _motivoController.text = s.motivo;
      _frecuencia = s.frecuencia;
      _diaDelMes = s.diaDelMes;
      _diaDeLaSemana = s.diaDeLaSemana;
      _fechaInicio = s.fechaInicio;
      _fechaFin = s.fechaFin;
      _activa = s.activa;
      _selectedCategory = s.motivo;
    } else {
      final divisiones = ref.read(divisionsProvider);
      _selectedDivisionId = divisiones.isNotEmpty ? divisiones.first.id : '';
      _selectedCategory = Transaction.categoriasPara(TransactionType.egreso).first;
      _tipo = TransactionType.egreso;
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisiones = ref.watch(divisionsProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Programada' : 'Nueva Transacción Programada')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.ingreso, label: Text('Ingreso'), icon: Icon(Icons.arrow_downward)),
                ButtonSegment(value: TransactionType.egreso, label: Text('Egreso'), icon: Icon(Icons.arrow_upward)),
              ],
              selected: {_tipo},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _tipo = newSelection.first;
                  _selectedCategory = Transaction.categoriasPara(_tipo).first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Monto (${currency.symbol})', prefixIcon: const Icon(Icons.attach_money), border: const OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty || double.tryParse(v)! <= 0 ? 'Monto inválido' : null,
              onChanged: (v) => setState(() => _selectedAmount = double.tryParse(v)),
            ),
            const SizedBox(height: 16),
            QuickAmountButtons(selectedAmount: _selectedAmount, onAmountSelected: (a) { _montoController.text = a.toString(); setState(() => _selectedAmount = a); }, currency: currency),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motivoController,
              decoration: InputDecoration(labelText: 'Motivo', prefixIcon: const Icon(Icons.description), border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Ingresa un motivo' : null,
            ),
            const SizedBox(height: 16),
            CategoryChips(selectedCategory: _selectedCategory, onCategorySelected: (c) => setState(() => _selectedCategory = c), tipo: _tipo),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDivisionId,
              decoration: InputDecoration(labelText: 'División', prefixIcon: const Icon(Icons.account_balance_wallet), border: OutlineInputBorder()),
              items: divisiones.map((d) => DropdownMenuItem(value: d.id, child: Text(d.nombre))).toList(),
              onChanged: (v) => setState(() => _selectedDivisionId = v!),
              validator: (v) => v == null ? 'Selecciona una división' : null,
            ),
            const SizedBox(height: 24),
            Text('Programación', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<ScheduleFrequency>(
              initialValue: _frecuencia,
              decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
              items: ScheduleFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(),
              onChanged: (v) => setState(() => _frecuencia = v!),
            ),
            const SizedBox(height: 16),
            _buildFrequencySpecificFields(),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de inicio'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaInicio)),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _fechaInicio, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365 * 10)));
                if (date != null && mounted) setState(() => _fechaInicio = date);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tiene fecha de fin'),
              subtitle: Text(_fechaFin != null ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_fechaFin!)}' : 'Sin límite'),
              value: _fechaFin != null,
              onChanged: (v) async {
                if (v) {
                  final date = await showDatePicker(context: context, initialDate: _fechaFin ?? _fechaInicio.add(const Duration(days: 365)), firstDate: _fechaInicio, lastDate: DateTime.now().add(const Duration(days: 365 * 10)));
                  if (date != null && mounted) setState(() => _fechaFin = date);
                } else {
                  setState(() => _fechaFin = null);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activa'),
              value: _activa,
              onChanged: (v) => setState(() => _activa = v),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Actualizar' : 'Crear Programada', style: const TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySpecificFields() {
    switch (_frecuencia) {
      case ScheduleFrequency.monthly:
      case ScheduleFrequency.quarterly:
      case ScheduleFrequency.yearly:
        return Column(
          children: [
            Text('Día del mes (1-28)', style: Theme.of(context).textTheme.bodyMedium),
            Slider(value: _diaDelMes.toDouble(), min: 1, max: 28, divisions: 27, label: _diaDelMes.toString(), onChanged: (v) => setState(() => _diaDelMes = v.round())),
            Text('Se ejecutará el día $_diaDelMes de cada mes', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        );
      case ScheduleFrequency.weekly:
        return Column(
          children: [
            Text('Día de la semana', style: Theme.of(context).textTheme.bodyMedium),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) => ChoiceChip(
                label: Text(['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][i]),
                selected: _diaDeLaSemana == i + 1,
                onSelected: (_) => setState(() => _diaDeLaSemana = i + 1),
              )),
            ),
          ],
        );
      case ScheduleFrequency.biweekly:
        return const Text('Se ejecutará el día 1 y 15 de cada mes', style: TextStyle(color: Colors.grey));
      case ScheduleFrequency.daily:
        return const Text('Se ejecutará todos los días', style: TextStyle(color: Colors.grey));
      case ScheduleFrequency.custom:
        return const Text('Frecuencia personalizada (próximamente)', style: TextStyle(color: Colors.grey));
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frecuencia == ScheduleFrequency.weekly && _diaDeLaSemana == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un día de la semana')));
      return;
    }

    final monto = double.parse(_montoController.text);
    final schedule = ScheduledTransaction(
      id: _esEdicion ? widget.scheduleToEdit!.id : null,
      monto: monto,
      motivo: _motivoController.text,
      divisionId: _selectedDivisionId,
      tipo: _tipo,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      frecuencia: _frecuencia,
      diaDelMes: _diaDelMes,
      diaDeLaSemana: _diaDeLaSemana,
      activa: _activa,
    );

    if (_esEdicion) {
      await ref.read(scheduledTransactionsProvider.notifier).update(schedule);
    } else {
      await ref.read(scheduledTransactionsProvider.notifier).add(schedule);
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_esEdicion ? 'Programada actualizada' : 'Transacción programada creada')));
    }
  }
}