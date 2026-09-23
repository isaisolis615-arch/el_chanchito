import '../models/models.dart';

extension CurrencyFormatter on double {
  String toCurrency(Currency currency) {
    final sign = this >= 0 ? '' : '-';
    final absValue = abs();
    return '$sign${currency.symbol}${absValue.toStringAsFixed(currency.decimalDigits)}';
  }

  String toCurrencyWithSign(Currency currency, {bool showPlus = true}) {
    if (this > 0) {
      return showPlus ? '+${currency.symbol}${toStringAsFixed(currency.decimalDigits)}' : '${currency.symbol}${toStringAsFixed(currency.decimalDigits)}';
    } else if (this < 0) {
      return '-${currency.symbol}${abs().toStringAsFixed(currency.decimalDigits)}';
    }
    return '${currency.symbol}0.00';
  }
}

extension TransactionExtension on Transaction {
  String formattedAmount(Currency currency, {bool showPlus = true}) {
    if (esIngreso) {
      return showPlus
          ? '+${currency.symbol}${monto.toStringAsFixed(currency.decimalDigits)}'
          : '${currency.symbol}${monto.toStringAsFixed(currency.decimalDigits)}';
    } else {
      return '-${currency.symbol}${monto.toStringAsFixed(currency.decimalDigits)}';
    }
  }
}