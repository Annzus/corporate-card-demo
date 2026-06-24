import 'package:corporate_card_companion/features/transactions/data/transaction_dto.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps json to domain without floating point money', () {
    final transaction = TransactionDto.fromJson({
      'id': 'txn_business_001',
      'brandId': 'business',
      'cardId': 'card_business_01',
      'cardNickname': '開発チームカード',
      'cardLast4': '4242',
      'merchantName': 'AWS JAPAN',
      'amountMinor': 12800,
      'currency': 'JPY',
      'authorizedAt': '2026-06-22T09:31:00+09:00',
      'status': 'cleared',
      'receiptStatus': 'missing',
      'memo': null,
    }).toDomain();

    expect(transaction.amount.minorUnits, 12800);
    expect(transaction.amount.currency, 'JPY');
    expect(transaction.status, TransactionStatus.cleared);
    expect(transaction.receiptStatus, ReceiptStatus.missing);
    expect(transaction.authorizedAt.toUtc(), DateTime.utc(2026, 6, 22, 0, 31));
  });

  test('rejects unknown transaction status', () {
    expect(
      () => TransactionDto.fromJson({
        'id': 'txn_business_001',
        'brandId': 'business',
        'cardId': 'card_business_01',
        'cardNickname': '開発チームカード',
        'cardLast4': '4242',
        'merchantName': 'AWS JAPAN',
        'amountMinor': 12800,
        'currency': 'JPY',
        'authorizedAt': '2026-06-22T09:31:00+09:00',
        'status': 'settled',
        'receiptStatus': 'missing',
        'memo': null,
      }),
      throwsFormatException,
    );
  });
}
