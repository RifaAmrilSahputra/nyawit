import 'package:intl/intl.dart';

String formatPerawatanCurrency(num value) =>
    'Rp${NumberFormat('#,##0', 'id_ID').format(value)}';

String formatPerawatanDateRange(DateTime start, DateTime end) {
  final startDate = start.toLocal();
  final endDate = end.toLocal();
  final startText =
      '${startDate.day.toString().padLeft(2, '0')}/'
      '${startDate.month.toString().padLeft(2, '0')}/'
      '${startDate.year}';
  final endText =
      '${endDate.day.toString().padLeft(2, '0')}/'
      '${endDate.month.toString().padLeft(2, '0')}/'
      '${endDate.year}';

  return '$startText - $endText';
}
