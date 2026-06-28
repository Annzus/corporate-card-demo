import 'package:corporate_card_companion/core/analytics/analytics_event.dart';
import 'package:corporate_card_companion/core/analytics/debug_analytics_service.dart';
import 'package:corporate_card_companion/core/formatting/date_formatter.dart';
import 'package:corporate_card_companion/core/formatting/money_formatter.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/receipt_image_picker.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/upload_queue_controller.dart';
import 'package:corporate_card_companion/features/receipt_upload/presentation/widgets/receipt_attachment_section.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/presentation/widgets/receipt_status_badge.dart';
import 'package:corporate_card_companion/features/transactions/presentation/widgets/transaction_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionDetailPage extends ConsumerStatefulWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailPage> createState() =>
      _TransactionDetailPageState();
}

class _TransactionDetailPageState extends ConsumerState<TransactionDetailPage> {
  bool _trackedOpen = false;

  @override
  Widget build(BuildContext context) {
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
              .where((item) => item.id == widget.transactionId)
              .firstOrNull;
          if (transaction == null) return const _NotFoundMessage();
          _trackOpen(transaction);
          return _TransactionDetailContent(transaction: transaction);
        },
      ),
    );
  }

  void _trackOpen(Transaction transaction) {
    if (_trackedOpen) return;
    _trackedOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(debugAnalyticsServiceProvider.notifier)
          .track(
            AnalyticsEventName.transactionDetailOpened,
            properties: {
              'brandId': transaction.brandId,
              'transactionStatus': transaction.status.name,
              'receiptStatus': transaction.receiptStatus.name,
            },
          );
    });
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
    final job = ref.watch(
      uploadQueueControllerProvider.select(
        (jobs) => jobs
            .where(
              (job) =>
                  job.brandId == transaction.brandId &&
                  job.transactionId == transaction.id,
            )
            .firstOrNull,
      ),
    );
    final ReceiptStatus receiptStatus = ref
        .read(uploadQueueControllerProvider.notifier)
        .receiptStatusFor(transaction);

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
            ReceiptStatusBadge(status: receiptStatus),
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
          receiptStatus: receiptStatus,
          image: _image,
          job: job,
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
          onUpload: () {
            final image = _image;
            if (image == null) return;
            ref
                .read(uploadQueueControllerProvider.notifier)
                .startUpload(transaction: transaction, image: image);
          },
          onRetry: () {
            ref.read(uploadQueueControllerProvider.notifier).retry(transaction);
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
    final transaction = widget.transaction;
    ref
        .read(debugAnalyticsServiceProvider.notifier)
        .track(
          AnalyticsEventName.receiptAttachTapped,
          properties: {
            'brandId': transaction.brandId,
            'transactionStatus': transaction.status.name,
            'receiptStatus': transaction.receiptStatus.name,
          },
        );
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
      if (image != null) {
        ref
            .read(debugAnalyticsServiceProvider.notifier)
            .track(
              AnalyticsEventName.receiptImageSelected,
              properties: {
                'brandId': transaction.brandId,
                'transactionStatus': transaction.status.name,
                'receiptStatus': ReceiptStatus.selected.name,
              },
            );
      }
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
