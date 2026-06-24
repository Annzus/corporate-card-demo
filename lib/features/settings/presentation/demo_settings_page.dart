import 'package:flutter/material.dart';

class DemoSettingsPage extends StatelessWidget {
  const DemoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('デモ設定')),
      body: const Padding(padding: EdgeInsets.all(16), child: Text('デモ専用')),
    );
  }
}
