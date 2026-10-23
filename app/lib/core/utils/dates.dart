import 'package:intl/intl.dart';

String formatDate(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '';
  try {
    final dt = DateTime.parse(isoString).toLocal();
    return DateFormat('dd MMM, h:mm a').format(dt);
  } catch (_) {
    return isoString;
  }
}
