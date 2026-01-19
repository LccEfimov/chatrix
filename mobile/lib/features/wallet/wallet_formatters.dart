String formatKopeks(int value) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final rubles = absValue ~/ 100;
  final kopeks = absValue % 100;
  final rublesText = _formatThousands(rubles);
  final sign = isNegative ? '-' : '';
  return '$sign$rublesText,${kopeks.toString().padLeft(2, '0')} ₽';
}

String formatSignedKopeks(int value) {
  final prefix = value >= 0 ? '+' : '-';
  return '$prefix${formatKopeks(value.abs())}';
}

String formatRate(double value) {
  return value.toStringAsFixed(2);
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthLabel(date.month);
  return '$day $month ${date.year}';
}

String formatDateTime(DateTime date) {
  final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  return '${formatDate(date)} • $time';
}

String _formatThousands(int value) {
  final text = value.toString();
  return text.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');
}

String _monthLabel(int month) {
  const months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
  return months[month] ?? '';
}
