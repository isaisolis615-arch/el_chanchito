import 'package:flutter/material.dart';
import '../models/models.dart';

class QuickAmountButtons extends StatelessWidget {
  final double? selectedAmount;
  final ValueChanged<double> onAmountSelected;
  final Currency currency;

  const QuickAmountButtons({
    super.key,
    this.selectedAmount,
    required this.onAmountSelected,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montos rápidos',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Transaction.quickAmounts.map((amount) {
            final isSelected = selectedAmount == amount;
            return ChoiceChip(
              label: Text('${currency.symbol}${amount.toStringAsFixed(currency.decimalDigits)}'),
              selected: isSelected,
              onSelected: (_) => onAmountSelected(amount),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final TransactionType tipo;

  const CategoryChips({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categorias = Transaction.categoriasPara(tipo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categorias.map((categoria) {
            final isSelected = selectedCategory == categoria;
            return ChoiceChip(
              label: Text(categoria),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(categoria),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}