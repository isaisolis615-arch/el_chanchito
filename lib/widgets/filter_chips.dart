import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por tipo',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Todo',
                selected: filter.tipo == FilterType.todos,
                onTap: () => ref.read(filterProvider.notifier).setTipo(FilterType.todos),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Ingresos',
                selected: filter.tipo == FilterType.ingresos,
                color: Colors.green,
                onTap: () => ref.read(filterProvider.notifier).setTipo(FilterType.ingresos),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Egresos',
                selected: filter.tipo == FilterType.egresos,
                color: Colors.red,
                onTap: () => ref.read(filterProvider.notifier).setTipo(FilterType.egresos),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Programados',
                selected: filter.tipo == FilterType.programados,
                color: Colors.blue,
                onTap: () => ref.read(filterProvider.notifier).setTipo(FilterType.programados),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Filtrar por tiempo',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Todo',
                selected: filter.tiempo == 'Todo',
                onTap: () => ref.read(filterProvider.notifier).setTiempo('Todo'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '7 días',
                selected: filter.tiempo == '7d',
                onTap: () => ref.read(filterProvider.notifier).setTiempo('7d'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '30 días',
                selected: filter.tiempo == '30d',
                onTap: () => ref.read(filterProvider.notifier).setTiempo('30d'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '90 días',
                selected: filter.tiempo == '90d',
                onTap: () => ref.read(filterProvider.notifier).setTiempo('90d'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor.withValues(alpha: 0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: selected ? chipColor : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? chipColor : theme.colorScheme.outline,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class SearchField extends ConsumerWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final theme = Theme.of(context);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar motivo, lugar, categoría...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: filter.busqueda != null && filter.busqueda!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => ref.read(filterProvider.notifier).setBusqueda(null),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) => ref.read(filterProvider.notifier).setBusqueda(value.isEmpty ? null : value),
    );
  }
}