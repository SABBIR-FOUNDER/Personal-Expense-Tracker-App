const _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '$day ${_monthNames[date.month - 1]} ${date.year}';
}

String formatCurrency(double amount, {bool includeSymbol = true}) {
  final fixed = amount.abs().toStringAsFixed(2).split('.');
  final digits = fixed.first;
  final grouped = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      grouped.write(',');
    }
    grouped.write(digits[index]);
  }

  final value = '${grouped.toString()}.${fixed.last}';
  return includeSymbol ? '৳ $value' : value;
}
