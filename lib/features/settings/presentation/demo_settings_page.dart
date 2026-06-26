import 'package:corporate_card_companion/core/analytics/analytics_event.dart';
import 'package:corporate_card_companion/core/analytics/debug_analytics_service.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/upload_queue_controller.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemoSettingsPage extends ConsumerWidget {
  const DemoSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failNextLoad = ref.watch(failNextTransactionLoadProvider);
    final failNextUpload = ref.watch(failNextReceiptUploadProvider);
    final analyticsEvents = ref.watch(debugAnalyticsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('デモ設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('デモ専用'),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('次回読み込みを失敗させる'),
            value: failNextLoad,
            onChanged: (value) {
              ref.read(failNextTransactionLoadProvider.notifier).set(value);
              ref.invalidate(transactionListControllerProvider);
            },
          ),
          SwitchListTile(
            title: const Text('次回アップロードを失敗させる'),
            value: failNextUpload,
            onChanged: (value) {
              ref.read(failNextReceiptUploadProvider.notifier).set(value);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('最近の計測イベント', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: analyticsEvents.isEmpty
                    ? null
                    : () {
                        ref
                            .read(debugAnalyticsServiceProvider.notifier)
                            .clear();
                      },
                child: const Text('クリア'),
              ),
            ],
          ),
          if (analyticsEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('イベントはありません'),
            )
          else
            for (final event in analyticsEvents.reversed.take(10))
              ListTile(
                dense: true,
                title: Text(event.name.key),
                subtitle: Text(_propertiesText(event)),
              ),
        ],
      ),
    );
  }

  String _propertiesText(AnalyticsEvent event) {
    if (event.properties.isEmpty) return 'プロパティなし';
    return event.properties.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' / ');
  }
}
