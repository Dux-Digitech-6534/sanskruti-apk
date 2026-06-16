import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
  static final _date = DateFormat('dd/MM/yyyy');

  static String currency(num value) => _currency.format(value);

  static String date(DateTime value) => _date.format(value);

  static String dateString(String? value, {String fallback = '-'}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return trimmed;
    return date(parsed);
  }

  static String apiDate(DateTime value) =>
      DateFormat('yyyy-MM-dd').format(value);
}
