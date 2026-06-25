String formatDateGroup(DateTime value) {
  final date = value.toLocal();
  return '${date.year}年${date.month}月${date.day}日';
}

String formatTransactionTime(DateTime value) {
  final date = value.toLocal();
  return '${_two(date.hour)}:${_two(date.minute)}';
}

String formatTransactionDateTime(DateTime value) {
  return '${formatDateGroup(value)} ${formatTransactionTime(value)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
