import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:flutter/material.dart';

class ReceiptStatusBadge extends StatelessWidget {
  const ReceiptStatusBadge({super.key, required this.status});

  final ReceiptStatus status;

  @override
  Widget build(BuildContext context) {
    final data = switch (status) {
      ReceiptStatus.missing => (
        icon: Icons.error_outline,
        label: '証憑未提出',
        color: Colors.deepOrange,
      ),
      ReceiptStatus.selected => (
        icon: Icons.attach_file,
        label: '選択済み',
        color: Colors.blueGrey,
      ),
      ReceiptStatus.uploading => (
        icon: Icons.cloud_upload_outlined,
        label: 'アップロード中',
        color: Colors.blue,
      ),
      ReceiptStatus.attached => (
        icon: Icons.check_circle_outline,
        label: '提出済み',
        color: Colors.green,
      ),
      ReceiptStatus.failed => (
        icon: Icons.report_gmailerrorred,
        label: '失敗',
        color: Colors.red,
      ),
    };

    return Semantics(
      label: '証憑状態: ${data.label}',
      child: _StatusChip(icon: data.icon, label: data.label, color: data.color),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
