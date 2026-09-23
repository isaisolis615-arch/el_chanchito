import 'package:flutter/material.dart';
import '../models/models.dart';

class DivisionCard extends StatelessWidget {
  final Division division;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final Currency currency;

  const DivisionCard({
    super.key,
    required this.division,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = division.colorHex != null
        ? Color(int.parse(division.colorHex!.replaceFirst('#', '0xFF')))
        : theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(division.icono),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        division.nombre,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (division.esPrincipal)
                        Text(
                          'División principal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'duplicate':
                        onDuplicate?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar', style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _formatCurrency(division.saldo),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: division.saldo >= 0 ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'payments':
        return Icons.payments;
      case 'attach_money':
        return Icons.attach_money;
      case 'money':
        return Icons.money;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'folder':
      default:
        return Icons.folder;
    }
  }

  String _formatCurrency(double amount) {
    final sign = amount >= 0 ? '' : '-';
    final absAmount = amount.abs();
    return '$sign${currency.symbol}${absAmount.toStringAsFixed(currency.decimalDigits)}';
  }
}