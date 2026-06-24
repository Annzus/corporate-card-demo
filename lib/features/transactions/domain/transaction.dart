import 'package:corporate_card_companion/features/transactions/domain/money.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';

final class Transaction {
  const Transaction({
    required this.id,
    required this.brandId,
    required this.cardId,
    required this.cardNickname,
    required this.cardLast4,
    required this.merchantName,
    required this.amount,
    required this.authorizedAt,
    required this.status,
    required this.receiptStatus,
    required this.memo,
  });

  final String id;
  final String brandId;
  final String cardId;
  final String cardNickname;
  final String cardLast4;
  final String merchantName;
  final Money amount;
  final DateTime authorizedAt;
  final TransactionStatus status;
  final ReceiptStatus receiptStatus;
  final String? memo;

  Transaction copyWith({ReceiptStatus? receiptStatus}) {
    return Transaction(
      id: id,
      brandId: brandId,
      cardId: cardId,
      cardNickname: cardNickname,
      cardLast4: cardLast4,
      merchantName: merchantName,
      amount: amount,
      authorizedAt: authorizedAt,
      status: status,
      receiptStatus: receiptStatus ?? this.receiptStatus,
      memo: memo,
    );
  }
}
