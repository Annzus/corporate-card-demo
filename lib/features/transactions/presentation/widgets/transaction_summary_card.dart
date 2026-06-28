import 'package:corporate_card_companion/core/formatting/money_formatter.dart';
import 'package:corporate_card_companion/features/transactions/domain/money.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:flutter/material.dart';

class TransactionSummaryCard extends StatelessWidget {
  const TransactionSummaryCard({
    super.key,
    required this.transactions,
    required this.cardLabel,
  });

  final List<Transaction> transactions;
  final String cardLabel;

  @override
  Widget build(BuildContext context) {
    final first = transactions.first;
    final summaryTransactions = transactions
        .where((transaction) => transaction.cardId == first.cardId)
        .toList();
    final missingCount = summaryTransactions
        .where(
          (transaction) => transaction.receiptStatus == ReceiptStatus.missing,
        )
        .length;
    final total = summaryTransactions.fold<int>(
      0,
      (sum, transaction) => sum + transaction.amount.minorUnits,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cardLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              first.cardNickname,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('•••• ${first.cardLast4} ・ 利用可能'),
            const SizedBox(height: 12),
            Text(
              '今月の利用額 ${formatMoney(Money(minorUnits: total, currency: first.amount.currency))}',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 18),
                const SizedBox(width: 6),
                Text('証憑未提出 $missingCount件'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
