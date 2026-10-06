import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class DivisionsScreen extends ConsumerWidget {
  const DivisionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final divisiones = ref.watch(divisionsProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Divisiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showDivisionDialog(context, ref),
          ),
        ],
      ),
      body: divisiones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay divisiones aún',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera división para organizar tu dinero',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showDivisionDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear división'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: divisiones.length,
              itemBuilder: (context, index) {
                final division = divisiones[index];
                return DivisionCard(
                  division: division,
                  currency: currency,
                  onEdit: () => _showDivisionDialog(context, ref, division: division),
                  onDelete: () => _confirmDeleteDivision(context, ref, division),
                  onDuplicate: () => _duplicateDivision(context, ref, division),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDivisionDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva División'),
      ),
    );
  }

  void _showDivisionDialog(BuildContext context, WidgetRef ref, {Division? division}) {
    showDialog(
      context: context,
      builder: (context) => _DivisionDialog(division: division),
    );
  }

  void _confirmDeleteDivision(BuildContext context, WidgetRef ref, Division division) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('División eliminada')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _duplicateDivision(BuildContext context, WidgetRef ref, Division division) {
    final nueva = division.copyWith(
      id: null,
      nombre: '${division.nombre} (copia)',
    );
    ref.read(divisionsProvider.notifier).add(nueva);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('División duplicada')),
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