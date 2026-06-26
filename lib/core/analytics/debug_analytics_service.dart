import 'package:corporate_card_companion/core/analytics/analytics_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final debugAnalyticsServiceProvider =
    NotifierProvider<DebugAnalyticsService, List<AnalyticsEvent>>(
      DebugAnalyticsService.new,
    );

class DebugAnalyticsService extends Notifier<List<AnalyticsEvent>> {
  static const allowedPropertyKeys = {
    'brandId',
    'transactionStatus',
    'receiptStatus',
    'durationMs',
    'retryCount',
    'errorType',
  };

  @override
  List<AnalyticsEvent> build() => const [];

  void track(
    AnalyticsEventName name, {
    Map<String, Object?> properties = const {},
  }) {
    final safeProperties = <String, Object>{};
    for (final entry in properties.entries) {
      final value = entry.value;
      if (value != null && allowedPropertyKeys.contains(entry.key)) {
        safeProperties[entry.key] = value;
      }
    }

    final next = [
      ...state,
      AnalyticsEvent(
        name: name,
        createdAt: DateTime.now(),
        properties: safeProperties,
      ),
    ];
    state = next.length > 20 ? next.sublist(next.length - 20) : next;
  }

  void clear() {
    state = const [];
  }
}
