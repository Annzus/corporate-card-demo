import 'package:corporate_card_companion/core/formatting/date_formatter.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/upload_queue_controller.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';
import 'package:corporate_card_companion/features/receipt_upload/presentation/widgets/upload_status_banner.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_filter.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:corporate_card_companion/features/transactions/presentation/widgets/transaction_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() =>
      _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  TransactionFilter _filter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListControllerProvider);
    final uploadJobs = ref.watch(uploadQueueControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('利用明細'),
        actions: [
          IconButton(
            tooltip: 'デモ設定',
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('明細を読み込めませんでした'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(transactionListControllerProvider.notifier)
                        .retry();
                  },
                  child: const Text('再読み込み'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('該当する明細はありません'));
          }
          final rows = _buildRows(items, _filter, uploadJobs);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return switch (row) {
                _SummaryRow(:final transactions) => TransactionSummaryCard(
                  transactions: transactions,
                ),
                _FilterRow() => _FilterChips(
                  selected: _filter,
                  onSelected: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
                _DateHeaderRow(:final label) => Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _UploadRow(:final job) => UploadStatusBanner(
                  job: job,
                  onTap: () {
                    context.push('/transactions/${job.transactionId}');
                  },
                ),
                _TransactionRow(:final transaction) => TransactionListItem(
                  transaction: transaction,
                  receiptStatus: ref
                      .read(uploadQueueControllerProvider.notifier)
                      .receiptStatusFor(transaction),
                ),
                _EmptyRow() => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text('該当する明細はありません')),
                ),
              };
            },
          );
        },
      ),
    );
  }

  List<_ListRow> _buildRows(
    List<Transaction> transactions,
    TransactionFilter filter,
    List<UploadJob> uploadJobs,
  ) {
    final filtered = filter.apply(transactions);
    final rows = <_ListRow>[_SummaryRow(transactions), const _FilterRow()];
    final visibleJob = uploadJobs
        .where((job) => job.state != UploadJobState.succeeded)
        .firstOrNull;
    if (visibleJob != null) rows.add(_UploadRow(visibleJob));
    if (filtered.isEmpty) return [...rows, const _EmptyRow()];

    String? currentDate;
    for (final transaction in filtered) {
      final date = formatDateGroup(transaction.authorizedAt);
      if (date != currentDate) {
        rows.add(_DateHeaderRow(date));
        currentDate = date;
      }
      rows.add(_TransactionRow(transaction));
    }
    return rows;
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          for (final filter in TransactionFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: filter == selected,
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

sealed class _ListRow {
  const _ListRow();
}

final class _SummaryRow extends _ListRow {
  const _SummaryRow(this.transactions);

  final List<Transaction> transactions;
}

final class _FilterRow extends _ListRow {
  const _FilterRow();
}

final class _DateHeaderRow extends _ListRow {
  const _DateHeaderRow(this.label);

  final String label;
}

final class _UploadRow extends _ListRow {
  const _UploadRow(this.job);

  final UploadJob job;
}

final class _TransactionRow extends _ListRow {
  const _TransactionRow(this.transaction);

  final Transaction transaction;
}

final class _EmptyRow extends _ListRow {
  const _EmptyRow();
}
