import 'package:intl/intl.dart';

String formatInr(int paise, {String? unit}) {
  final rupees = paise / 100.0;
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: (rupees % 1 == 0) ? 0 : 2,
  );
  final formatted = formatter.format(rupees);
  if (unit != null && unit.isNotEmpty) {
    return '$formatted / $unit';
  }
  return formatted;
}
