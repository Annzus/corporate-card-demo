import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';

enum TransactionFilter {
  all('すべて'),
  missingReceipt('証憑未提出'),
  processing('処理中'),
  cleared('確定'),
  cancelledOrRefunded('取消・返金');

  const TransactionFilter(this.label);

  final String label;

  List<Transaction> apply(List<Transaction> transactions) {
    return switch (this) {
      TransactionFilter.all => transactions,
      TransactionFilter.missingReceipt =>
        transactions
            .where(
              (transaction) =>
                  transaction.receiptStatus == ReceiptStatus.missing,
            )
            .toList(),
      TransactionFilter.processing =>
        transactions
            .where(
              (transaction) =>
                  transaction.status == TransactionStatus.authorized,
            )
            .toList(),
      TransactionFilter.cleared =>
        transactions
            .where(
              (transaction) => transaction.status == TransactionStatus.cleared,
            )
            .toList(),
      TransactionFilter.cancelledOrRefunded =>
        transactions
            .where(
              (transaction) =>
                  transaction.status == TransactionStatus.reversed ||
                  transaction.status == TransactionStatus.refunded,
            )
            .toList(),
    };
  }
}
