import 'package:corporate_card_companion/features/transactions/application/transaction_filter.dart';
import 'package:corporate_card_companion/features/transactions/domain/money.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters transactions without changing source list', () {
    final transactions = [
      _transaction(
        id: 'missing',
        status: TransactionStatus.cleared,
        receiptStatus: ReceiptStatus.missing,
      ),
      _transaction(
        id: 'processing',
        status: TransactionStatus.authorized,
        receiptStatus: ReceiptStatus.attached,
      ),
      _transaction(
        id: 'refunded',
        status: TransactionStatus.refunded,
        receiptStatus: ReceiptStatus.attached,
      ),
    ];

    expect(
      TransactionFilter.missingReceipt
          .apply(transactions)
          .map((transaction) => transaction.id),
      ['missing'],
    );
    expect(
      TransactionFilter.processing
          .apply(transactions)
          .map((transaction) => transaction.id),
      ['processing'],
    );
    expect(
      TransactionFilter.cancelledOrRefunded
          .apply(transactions)
          .map((transaction) => transaction.id),
      ['refunded'],
    );
    expect(transactions.length, 3);
  });
}

Transaction _transaction({
  required String id,
  required TransactionStatus status,
  required ReceiptStatus receiptStatus,
}) {
  return Transaction(
    id: id,
    brandId: 'business',
    cardId: 'card_business_01',
    cardNickname: '開発チームカード',
    cardLast4: '4242',
    merchantName: id,
    amount: const Money(minorUnits: 1000, currency: 'JPY'),
    authorizedAt: DateTime.utc(2026, 6, 22),
    status: status,
    receiptStatus: receiptStatus,
    memo: null,
  );
}
