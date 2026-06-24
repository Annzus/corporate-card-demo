import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemoSettingsPage extends ConsumerWidget {
  const DemoSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failNextLoad = ref.watch(failNextTransactionLoadProvider);

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
        ],
      ),
    );
  }
}
