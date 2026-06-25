import 'package:corporate_card_companion/core/formatting/date_formatter.dart';
import 'package:corporate_card_companion/core/formatting/money_formatter.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/receipt_image_picker.dart';
import 'package:corporate_card_companion/features/receipt_upload/presentation/widgets/receipt_attachment_section.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
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

class _TransactionDetailContent extends ConsumerStatefulWidget {
  const _TransactionDetailContent({required this.transaction});

  final Transaction transaction;

  @override
  ConsumerState<_TransactionDetailContent> createState() =>
      _TransactionDetailContentState();
}

class _TransactionDetailContentState
    extends ConsumerState<_TransactionDetailContent> {
  final _memoController = TextEditingController();
  PickedReceiptImage? _image;
  String? _errorMessage;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _memoController.text = widget.transaction.memo ?? '';
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

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
        const SizedBox(height: 16),
        ReceiptAttachmentSection(
          receiptStatus: transaction.receiptStatus,
          image: _image,
          memoController: _memoController,
          isPicking: _isPicking,
          errorMessage: _errorMessage,
          onPick: _pickImage,
          onRemove: () {
            setState(() {
              _image = null;
              _errorMessage = null;
            });
          },
        ),
      ],
    );
  }

  String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 12)}...';
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPicking = true;
      _errorMessage = null;
    });
    try {
      final image = await ref.read(receiptImagePickerProvider).pickImage();
      if (!mounted) return;
      setState(() {
        if (image != null) _image = image;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '画像を選択できませんでした。設定を確認して再度お試しください。';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
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
