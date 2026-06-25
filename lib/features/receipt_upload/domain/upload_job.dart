enum UploadJobState { uploading, succeeded, failed }

final class UploadJob {
  const UploadJob({
    required this.id,
    required this.transactionId,
    required this.brandId,
    required this.fileName,
    required this.idempotencyKey,
    required this.progress,
    required this.state,
    required this.retryCount,
    required this.errorMessage,
  });

  final String id;
  final String transactionId;
  final String brandId;
  final String fileName;
  final String idempotencyKey;
  final double progress;
  final UploadJobState state;
  final int retryCount;
  final String? errorMessage;

  UploadJob copyWith({
    double? progress,
    UploadJobState? state,
    int? retryCount,
    String? errorMessage,
  }) {
    return UploadJob(
      id: id,
      transactionId: transactionId,
      brandId: brandId,
      fileName: fileName,
      idempotencyKey: idempotencyKey,
      progress: progress ?? this.progress,
      state: state ?? this.state,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage,
    );
  }
}
