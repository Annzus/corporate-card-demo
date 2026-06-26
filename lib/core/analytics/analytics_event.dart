enum AnalyticsEventName {
  appOpened('app_opened'),
  transactionListViewed('transaction_list_viewed'),
  transactionFilterChanged('transaction_filter_changed'),
  transactionDetailOpened('transaction_detail_opened'),
  receiptAttachTapped('receipt_attach_tapped'),
  receiptImageSelected('receipt_image_selected'),
  receiptUploadStarted('receipt_upload_started'),
  receiptUploadSucceeded('receipt_upload_succeeded'),
  receiptUploadFailed('receipt_upload_failed'),
  receiptUploadRetried('receipt_upload_retried'),
  brandSwitched('brand_switched');

  const AnalyticsEventName(this.key);

  final String key;
}

final class AnalyticsEvent {
  AnalyticsEvent({
    required this.name,
    required this.createdAt,
    Map<String, Object> properties = const {},
  }) : properties = Map.unmodifiable(properties);

  final AnalyticsEventName name;
  final DateTime createdAt;
  final Map<String, Object> properties;
}
