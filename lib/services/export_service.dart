import 'package:flutter/services.dart';
import '../models/models.dart';

class ExportService {
  static String generateCSV(List<Transaction> transacciones, List<Division> divisiones, Currency currency) {
    final buffer = StringBuffer();
    final divisionMap = {for (var d in divisiones) d.id: d.nombre};

    buffer.writeln('Fecha,Motivo,Categoría,División,Tipo,Monto,Lugar');

    for (final t in transacciones) {
      final fecha = t.fecha.toIso8601String().substring(0, 16).replaceAll('T', ' ');
      final division = divisionMap[t.divisionId] ?? 'Desconocida';
      final tipo = t.esIngreso ? 'Ingreso' : 'Egreso';
      final monto = t.monto.toStringAsFixed(currency.decimalDigits);
      final lugar = t.lugar ?? '';
      final categoria = t.categoria ?? '';

      buffer.writeln('$fecha,"${t.motivo}","$categoria","$division",$tipo,$monto,"$lugar"');
    }

    return buffer.toString();
  }

  static Future<void> copyToClipboard(String csv) async {
    await Clipboard.setData(ClipboardData(text: csv));
  }

  static String generateSummaryCSV(
    List<Transaction> transacciones,
    List<Division> divisiones,
    Currency currency,
    DateTime desde,
    DateTime hasta,
  ) {
    final buffer = StringBuffer();
    final divisionMap = {for (var d in divisiones) d.id: d.nombre};

    final filtradas = transacciones.where((t) {
      return t.fecha.isAfter(desde.subtract(const Duration(days: 1))) &&
          t.fecha.isBefore(hasta.add(const Duration(days: 1)));
    }).toList();

    final totalIngresos = filtradas.where((t) => t.esIngreso).fold(0.0, (s, t) => s + t.monto);
    final totalEgresos = filtradas.where((t) => !t.esIngreso).fold(0.0, (s, t) => s + t.monto);

    buffer.writeln('Resumen del ${desde.day}/${desde.month}/${desde.year} al ${hasta.day}/${hasta.month}/${hasta.year}');
    buffer.writeln('Moneda,${currency.code} (${currency.symbol})');
    buffer.writeln('Total Ingresos,${totalIngresos.toStringAsFixed(currency.decimalDigits)}');
    buffer.writeln('Total Egresos,${totalEgresos.toStringAsFixed(currency.decimalDigits)}');
    buffer.writeln('Balance,${(totalIngresos - totalEgresos).toStringAsFixed(currency.decimalDigits)}');
    buffer.writeln('');
    buffer.writeln('Detalle por División');
    buffer.writeln('División,Ingresos,Egresos,Balance');

    for (final d in divisiones) {
      final divTrans = filtradas.where((t) => t.divisionId == d.id).toList();
      final ingresos = divTrans.where((t) => t.esIngreso).fold(0.0, (s, t) => s + t.monto);
      final egresos = divTrans.where((t) => !t.esIngreso).fold(0.0, (s, t) => s + t.monto);
      buffer.writeln('${d.nombre},${ingresos.toStringAsFixed(currency.decimalDigits)},${egresos.toStringAsFixed(currency.decimalDigits)},${(ingresos - egresos).toStringAsFixed(currency.decimalDigits)}');
    }

    return buffer.toString();
  }
}