import 'dart:async';
import 'dart:typed_data';

import 'package:corporate_card_companion/features/receipt_upload/application/receipt_image_picker.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/upload_queue_controller.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/receipt_upload_repository.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';
import 'package:corporate_card_companion/features/transactions/domain/money.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prevents duplicate active upload for the same transaction', () async {
    final uploadCompleter = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        receiptUploadRepositoryProvider.overrideWithValue(
          _FakeUploadRepository((job, onProgress) => uploadCompleter.future),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(uploadQueueControllerProvider.notifier);
    unawaited(
      controller.startUpload(transaction: _transaction(), image: _image()),
    );
    await Future<void>.delayed(Duration.zero);

    unawaited(
      controller.startUpload(transaction: _transaction(), image: _image()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(container.read(uploadQueueControllerProvider), hasLength(1));

    uploadCompleter.complete();
  });

  test('retry keeps the same idempotency key', () async {
    var shouldFail = true;
    final container = ProviderContainer(
      overrides: [
        receiptUploadRepositoryProvider.overrideWithValue(
          _FakeUploadRepository((job, onProgress) async {
            if (shouldFail) throw Exception('fail');
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(uploadQueueControllerProvider.notifier);
    await controller.startUpload(transaction: _transaction(), image: _image());

    final failedJob = container.read(uploadQueueControllerProvider).single;
    expect(failedJob.state, UploadJobState.failed);

    shouldFail = false;
    await controller.retry(_transaction());

    final retriedJob = container.read(uploadQueueControllerProvider).single;
    expect(retriedJob.state, UploadJobState.succeeded);
    expect(retriedJob.retryCount, 1);
    expect(retriedJob.idempotencyKey, failedJob.idempotencyKey);
  });

  test('keeps upload jobs separated by brand id', () async {
    final firstCompleter = Completer<void>();
    final secondCompleter = Completer<void>();
    var uploadCount = 0;
    final container = ProviderContainer(
      overrides: [
        receiptUploadRepositoryProvider.overrideWithValue(
          _FakeUploadRepository((job, onProgress) {
            uploadCount += 1;
            return uploadCount == 1
                ? firstCompleter.future
                : secondCompleter.future;
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(uploadQueueControllerProvider.notifier);
    unawaited(
      controller.startUpload(transaction: _transaction(), image: _image()),
    );
    await Future<void>.delayed(Duration.zero);

    unawaited(
      controller.startUpload(
        transaction: _transaction(brandId: 'executive'),
        image: _image(),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(container.read(uploadQueueControllerProvider), hasLength(2));

    firstCompleter.complete();
    secondCompleter.complete();
  });
}

final class _FakeUploadRepository implements ReceiptUploadRepository {
  const _FakeUploadRepository(this._upload);

  final Future<void> Function(UploadJob, void Function(double)) _upload;

  @override
  Future<void> upload({
    required UploadJob job,
    required void Function(double progress) onProgress,
  }) {
    return _upload(job, onProgress);
  }
}

Transaction _transaction({String brandId = 'business'}) {
  return Transaction(
    id: 'txn_business_001',
    brandId: brandId,
    cardId: 'card_business_01',
    cardNickname: '開発チームカード',
    cardLast4: '4242',
    merchantName: 'AWS JAPAN',
    amount: const Money(minorUnits: 12800, currency: 'JPY'),
    authorizedAt: DateTime.utc(2026, 6, 22),
    status: TransactionStatus.cleared,
    receiptStatus: ReceiptStatus.missing,
    memo: null,
  );
}

PickedReceiptImage _image() {
  return PickedReceiptImage(fileName: 'receipt.png', bytes: Uint8List(1));
}
