import 'package:intl/intl.dart';

final _leiFormat = NumberFormat.currency(
  locale: 'ro_RO',
  symbol: 'lei',
  decimalDigits: 2,
);
final _numberFormat = NumberFormat('#,##0.##', 'ro_RO');

String formatLei(double amount) => _leiFormat.format(amount);

/// Formatează un număr cu până la 2 zecimale, fără zerouri inutile — pentru
/// cantități (Kg, damigene) unde 6 arată mai bine decât 6,00.
String formatNumber(double amount) => _numberFormat.format(amount);
