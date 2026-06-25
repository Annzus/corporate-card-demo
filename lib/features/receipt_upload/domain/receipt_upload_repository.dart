import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';

abstract interface class ReceiptUploadRepository {
  Future<void> upload({
    required UploadJob job,
    required void Function(double progress) onProgress,
  });
}
