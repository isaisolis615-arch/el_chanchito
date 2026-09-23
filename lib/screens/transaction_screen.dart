import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;
  final String? divisionId;

  const TransactionScreen({super.key, required this.initialType, this.divisionId});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _motivoController = TextEditingController();
  final _lugarController = TextEditingController();

  late TransactionType _tipo;
  String _selectedDivisionId = '';
  double? _selectedAmount;
  String? _selectedCategory;
  bool get _isIncome => _tipo == TransactionType.ingreso;

  @override
  void initState() {
    super.initState();
    _tipo = widget.initialType;
    final divisiones = ref.read(divisionsProvider);
    _selectedDivisionId = widget.divisionId ?? (divisiones.isNotEmpty ? divisiones.first.id : '');
    _selectedCategory = Transaction.categoriasPara(_tipo).first;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _motivoController.dispose();
    _lugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisiones = ref.watch(divisionsProvider);
    final currency = ref.watch(currencyProvider);
    final isIncome = _isIncome;

    return Scaffold(
      appBar: AppBar(
        title: Text(isIncome ? 'Nuevo Ingreso' : 'Nuevo Egreso'),
        backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto (${currency.symbol})',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingresa un monto';
                final monto = double.tryParse(value);
                if (monto == null || monto <= 0) return 'Monto inválido';
                return null;
              },
              onChanged: (value) {
                final monto = double.tryParse(value);
                setState(() => _selectedAmount = monto);
              },
            ),
            const SizedBox(height: 16),
            QuickAmountButtons(
              selectedAmount: _selectedAmount,
              onAmountSelected: (amount) {
                _montoController.text = amount.toString();
                setState(() => _selectedAmount = amount);
              },
              currency: currency,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motivoController,
              decoration: InputDecoration(
                labelText: 'Motivo (Ej. Sueldo, Comida)',
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Ingresa un motivo' : null,
            ),
            const SizedBox(height: 16),
            if (!isIncome) ...[
              TextFormField(
                controller: _lugarController,
                decoration: InputDecoration(
                  labelText: 'Lugar de compra (Ej. Supermercado)',
                  prefixIcon: const Icon(Icons.store),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 16),
            ],
            CategoryChips(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
              tipo: _tipo,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDivisionId,
              decoration: InputDecoration(
                labelText: 'División / Fondo',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.account_balance_wallet),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              items: divisiones.map((d) => DropdownMenuItem(value: d.id, child: Text(d.nombre))).toList(),
              onChanged: (value) => setState(() => _selectedDivisionId = value!),
              validator: (value) => value == null ? 'Selecciona una división' : null,
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: _guardarTransaccion,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Transacción', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                backgroundColor: isIncome ? Colors.green : Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarTransaccion() async {
    if (!_formKey.currentState!.validate()) return;

    final monto = double.parse(_montoController.text);
    final divisiones = ref.read(divisionsProvider);
    final division = divisiones.firstWhere((d) => d.id == _selectedDivisionId);

    final transaccion = Transaction(
      monto: monto,
      motivo: _motivoController.text,
      divisionId: _selectedDivisionId,
      tipo: _tipo,
      lugar: !_isIncome && _lugarController.text.isNotEmpty ? _lugarController.text : null,
      categoria: _selectedCategory,
    );

    await ref.read(transactionsProvider.notifier).add(transaccion);

    final nuevoSaldo = _isIncome
        ? division.saldo + monto
        : division.saldo - monto;
    await ref.read(divisionsProvider.notifier).updateSaldo(_selectedDivisionId, nuevoSaldo);

    if (context.mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isIncome ? "Ingreso" : "Egreso"} registrado correctamente')),
      );
    }
  }
}