import 'package:corporate_card_companion/features/transactions/domain/money.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';

final class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.brandId,
    required this.cardId,
    required this.cardNickname,
    required this.cardLast4,
    required this.merchantName,
    required this.amountMinor,
    required this.currency,
    required this.authorizedAt,
    required this.status,
    required this.receiptStatus,
    required this.memo,
  });

  factory TransactionDto.fromJson(Map<String, Object?> json) {
    return TransactionDto(
      id: _string(json, 'id'),
      brandId: _string(json, 'brandId'),
      cardId: _string(json, 'cardId'),
      cardNickname: _string(json, 'cardNickname'),
      cardLast4: _string(json, 'cardLast4'),
      merchantName: _string(json, 'merchantName'),
      amountMinor: _int(json, 'amountMinor'),
      currency: _string(json, 'currency'),
      authorizedAt: _string(json, 'authorizedAt'),
      status: _status(_string(json, 'status')),
      receiptStatus: _receiptStatus(_string(json, 'receiptStatus')),
      memo: json['memo'] as String?,
    );
  }

  final String id;
  final String brandId;
  final String cardId;
  final String cardNickname;
  final String cardLast4;
  final String merchantName;
  final int amountMinor;
  final String currency;
  final String authorizedAt;
  final TransactionStatus status;
  final ReceiptStatus receiptStatus;
  final String? memo;

  Transaction toDomain() {
    return Transaction(
      id: id,
      brandId: brandId,
      cardId: cardId,
      cardNickname: cardNickname,
      cardLast4: cardLast4,
      merchantName: merchantName,
      amount: Money(minorUnits: amountMinor, currency: currency),
      authorizedAt: DateTime.parse(authorizedAt),
      status: status,
      receiptStatus: receiptStatus,
      memo: memo,
    );
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('Expected string for $key');
  }

  static int _int(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw FormatException('Expected int for $key');
  }

  static TransactionStatus _status(String value) {
    return switch (value) {
      'authorized' => TransactionStatus.authorized,
      'cleared' => TransactionStatus.cleared,
      'reversed' => TransactionStatus.reversed,
      'refunded' => TransactionStatus.refunded,
      _ => throw FormatException('Unknown transaction status: $value'),
    };
  }

  static ReceiptStatus _receiptStatus(String value) {
    return switch (value) {
      'missing' => ReceiptStatus.missing,
      'selected' => ReceiptStatus.selected,
      'uploading' => ReceiptStatus.uploading,
      'attached' => ReceiptStatus.attached,
      'failed' => ReceiptStatus.failed,
      _ => throw FormatException('Unknown receipt status: $value'),
    };
  }
}
