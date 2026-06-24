import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          transaction.merchantName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_transactionStatusLabel(transaction.status)} ・ '
          '${_receiptStatusLabel(transaction.receiptStatus)}',
        ),
        trailing: Text('¥${transaction.amount.minorUnits}'),
        onTap: () {
          context.push('/transactions/${transaction.id}');
        },
      ),
    );
  }

  String _transactionStatusLabel(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.authorized => '処理中',
      TransactionStatus.cleared => '確定',
      TransactionStatus.reversed => '取消',
      TransactionStatus.refunded => '返金',
    };
  }

  String _receiptStatusLabel(ReceiptStatus status) {
    return switch (status) {
      ReceiptStatus.missing => '証憑未提出',
      ReceiptStatus.selected => '選択済み',
      ReceiptStatus.uploading => 'アップロード中',
      ReceiptStatus.attached => '提出済み',
      ReceiptStatus.failed => '失敗',
    };
  }
}
