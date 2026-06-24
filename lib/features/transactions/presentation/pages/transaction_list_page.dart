import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用明細'),
        actions: [
          IconButton(
            tooltip: 'デモ設定',
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('BizCard Demo'),
              subtitle: const Text('証憑未提出の明細を確認できます'),
              trailing: FilledButton(
                onPressed: () {
                  context.push('/transactions/demo');
                },
                child: const Text('詳細'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
