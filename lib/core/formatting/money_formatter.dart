import 'package:corporate_card_companion/features/transactions/domain/money.dart';

String formatMoney(Money money) {
  final sign = money.minorUnits < 0 ? '-' : '';
  final digits = money.minorUnits.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i += 1) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  if (money.currency == 'JPY') return '$sign¥$buffer';
  return '$sign${money.currency} $buffer';
}
