import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';
import 'package:flutter/material.dart';

class TransactionStatusBadge extends StatelessWidget {
  const TransactionStatusBadge({super.key, required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final data = switch (status) {
      TransactionStatus.authorized => (
        icon: Icons.schedule,
        label: '処理中',
        color: Colors.blue,
      ),
      TransactionStatus.cleared => (
        icon: Icons.check_circle_outline,
        label: '確定',
        color: Colors.green,
      ),
      TransactionStatus.reversed => (
        icon: Icons.block,
        label: '取消',
        color: Colors.grey,
      ),
      TransactionStatus.refunded => (
        icon: Icons.reply,
        label: '返金',
        color: Colors.purple,
      ),
    };

    return Semantics(
      label: '取引状態: ${data.label}',
      child: Chip(
        avatar: Icon(data.icon, size: 16, color: data.color),
        label: Text(data.label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
