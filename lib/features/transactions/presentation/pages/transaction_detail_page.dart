import 'package:corporate_card_companion/core/formatting/date_formatter.dart';
import 'package:corporate_card_companion/core/formatting/money_formatter.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/presentation/widgets/receipt_status_badge.dart';
import 'package:corporate_card_companion/features/transactions/presentation/widgets/transaction_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('利用明細詳細')),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _LoadErrorMessage(
          onRetry: () {
            ref.read(transactionListControllerProvider.notifier).retry();
          },
        ),
        data: (items) {
          final transaction = items
              .where((item) => item.id == transactionId)
              .firstOrNull;
          if (transaction == null) return const _NotFoundMessage();
          return _TransactionDetailContent(transaction: transaction);
        },
      ),
    );
  }
}

class _TransactionDetailContent extends StatelessWidget {
  const _TransactionDetailContent({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          transaction.merchantName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          formatMoney(transaction.amount),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            TransactionStatusBadge(status: transaction.status),
            ReceiptStatusBadge(status: transaction.receiptStatus),
          ],
        ),
        const SizedBox(height: 16),
        _InfoTile(
          label: '利用日時',
          value: formatTransactionDateTime(transaction.authorizedAt),
        ),
        _InfoTile(
          label: 'カード',
          value: '${transaction.cardNickname} ・ •••• ${transaction.cardLast4}',
        ),
        _InfoTile(label: '取引ID', value: _shortId(transaction.id)),
        _InfoTile(label: 'メモ', value: transaction.memo ?? 'なし'),
        const SizedBox(height: 16),
        _ReceiptSection(status: transaction.receiptStatus),
      ],
    );
  }

  String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 12)}...';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({required this.status});

  final ReceiptStatus status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      ReceiptStatus.missing => '証憑が未提出です',
      ReceiptStatus.selected => '証憑が選択されています',
      ReceiptStatus.uploading => 'アップロード中',
      ReceiptStatus.attached => '提出済み',
      ReceiptStatus.failed => 'アップロードに失敗しました',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('証憑', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(text),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.attach_file),
              label: const Text('証憑を添付'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadErrorMessage extends StatelessWidget {
  const _LoadErrorMessage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('明細を読み込めませんでした'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('再読み込み')),
          ],
        ),
      ),
    );
  }
}

class _NotFoundMessage extends StatelessWidget {
  const _NotFoundMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(padding: EdgeInsets.all(16), child: Text('対象の明細が見つかりません')),
    );
  }
}
