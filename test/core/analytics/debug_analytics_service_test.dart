import 'package:corporate_card_companion/core/analytics/analytics_event.dart';
import 'package:corporate_card_companion/core/analytics/debug_analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps only whitelisted analytics properties', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(debugAnalyticsServiceProvider.notifier)
        .track(
          AnalyticsEventName.receiptUploadStarted,
          properties: {
            'brandId': 'business',
            'merchantName': 'AWS JAPAN',
            'memo': 'private memo',
            'imagePath': 'C:/secret/receipt.png',
            'transactionId': 'txn_business_001',
          },
        );

    final event = container.read(debugAnalyticsServiceProvider).single;
    expect(event.properties, {'brandId': 'business'});
  });
}
