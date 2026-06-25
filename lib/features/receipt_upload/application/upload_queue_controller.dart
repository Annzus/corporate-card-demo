import 'package:corporate_card_companion/features/receipt_upload/application/receipt_image_picker.dart';
import 'package:corporate_card_companion/features/receipt_upload/data/fake_receipt_upload_repository.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/receipt_upload_repository.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final failNextReceiptUploadProvider =
    NotifierProvider<FailNextReceiptUpload, bool>(FailNextReceiptUpload.new);

class FailNextReceiptUpload extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }

  bool take() {
    final value = state;
    state = false;
    return value;
  }
}

final receiptUploadRepositoryProvider = Provider<ReceiptUploadRepository>((
  ref,
) {
  return FakeReceiptUploadRepository(
    () => ref.read(failNextReceiptUploadProvider.notifier).take(),
  );
});

final uploadQueueControllerProvider =
    NotifierProvider<UploadQueueController, List<UploadJob>>(
      UploadQueueController.new,
    );

class UploadQueueController extends Notifier<List<UploadJob>> {
  @override
  List<UploadJob> build() => const [];

  UploadJob? jobFor({required String brandId, required String transactionId}) {
    return state
        .where(
          (job) => job.brandId == brandId && job.transactionId == transactionId,
        )
        .firstOrNull;
  }

  Future<void> startUpload({
    required Transaction transaction,
    required PickedReceiptImage image,
  }) async {
    final existing = jobFor(
      brandId: transaction.brandId,
      transactionId: transaction.id,
    );
    if (existing != null) return;

    final job = UploadJob(
      id: 'job_${transaction.id}',
      transactionId: transaction.id,
      brandId: transaction.brandId,
      fileName: image.fileName,
      idempotencyKey:
          '${transaction.id}_${DateTime.now().microsecondsSinceEpoch}',
      progress: 0,
      state: UploadJobState.uploading,
      retryCount: 0,
      errorMessage: null,
    );
    _upsert(job);
    await _run(job);
  }

  Future<void> retry(Transaction transaction) async {
    final job = jobFor(
      brandId: transaction.brandId,
      transactionId: transaction.id,
    );
    if (job == null || job.state != UploadJobState.failed) return;
    final retryJob = job.copyWith(
      progress: 0,
      state: UploadJobState.uploading,
      retryCount: job.retryCount + 1,
      errorMessage: null,
    );
    _upsert(retryJob);
    await _run(retryJob);
  }

  ReceiptStatus receiptStatusFor(Transaction transaction) {
    final job = jobFor(
      brandId: transaction.brandId,
      transactionId: transaction.id,
    );
    if (job == null) return transaction.receiptStatus;
    return switch (job.state) {
      UploadJobState.uploading => ReceiptStatus.uploading,
      UploadJobState.succeeded => ReceiptStatus.attached,
      UploadJobState.failed => ReceiptStatus.failed,
    };
  }

  Future<void> _run(UploadJob job) async {
    try {
      await ref
          .read(receiptUploadRepositoryProvider)
          .upload(
            job: job,
            onProgress: (progress) => _updateProgress(job, progress),
          );
      _upsert(job.copyWith(progress: 1, state: UploadJobState.succeeded));
    } catch (_) {
      _upsert(
        job.copyWith(
          state: UploadJobState.failed,
          errorMessage: 'アップロードに失敗しました。再試行してください。',
        ),
      );
    }
  }

  void _updateProgress(UploadJob job, double progress) {
    final current = jobFor(
      brandId: job.brandId,
      transactionId: job.transactionId,
    );
    if (current?.idempotencyKey != job.idempotencyKey) return;
    _upsert(current!.copyWith(progress: progress));
  }

  void _upsert(UploadJob job) {
    state = [
      for (final current in state)
        if (current.brandId == job.brandId &&
            current.transactionId == job.transactionId)
          job
        else
          current,
      if (!state.any(
        (current) =>
            current.brandId == job.brandId &&
            current.transactionId == job.transactionId,
      ))
        job,
    ];
  }
}
