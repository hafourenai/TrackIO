import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static double parse(String formattedString) {
    final cleanString = formattedString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanString) ?? 0.0;
  }
}
