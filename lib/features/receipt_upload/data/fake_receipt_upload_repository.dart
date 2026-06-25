import 'package:corporate_card_companion/features/receipt_upload/domain/receipt_upload_repository.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';

final class FakeReceiptUploadRepository implements ReceiptUploadRepository {
  const FakeReceiptUploadRepository(this._shouldFail);

  final bool Function() _shouldFail;

  @override
  Future<void> upload({
    required UploadJob job,
    required void Function(double progress) onProgress,
  }) async {
    final shouldFail = _shouldFail();
    for (var step = 1; step <= 5; step += 1) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      onProgress(step / 5);
      if (shouldFail && step == 3) {
        throw Exception('receipt_upload_failed');
      }
    }
  }
}
