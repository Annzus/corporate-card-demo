import 'package:corporate_card_companion/features/receipt_upload/application/receipt_image_picker.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:flutter/material.dart';

class ReceiptAttachmentSection extends StatelessWidget {
  const ReceiptAttachmentSection({
    super.key,
    required this.receiptStatus,
    required this.image,
    required this.memoController,
    required this.isPicking,
    required this.errorMessage,
    required this.onPick,
    required this.onRemove,
  });

  final ReceiptStatus receiptStatus;
  final PickedReceiptImage? image;
  final TextEditingController memoController;
  final bool isPicking;
  final String? errorMessage;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('証憑', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (image == null)
              Text(_statusText(receiptStatus))
            else
              _SelectedImage(image: image!, onRemove: onRemove),
            const SizedBox(height: 12),
            TextField(
              controller: memoController,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'メモ',
                hintText: '任意',
                border: OutlineInputBorder(),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isPicking ? null : onPick,
                  icon: isPicking
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file),
                  label: Text(isPicking ? '選択中' : '証憑を添付'),
                ),
                const FilledButton(onPressed: null, child: Text('アップロード')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(ReceiptStatus status) {
    return switch (status) {
      ReceiptStatus.missing => '証憑が未提出です',
      ReceiptStatus.selected => '証憑が選択されています',
      ReceiptStatus.uploading => 'アップロード中',
      ReceiptStatus.attached => '提出済み',
      ReceiptStatus.failed => 'アップロードに失敗しました',
    };
  }
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({required this.image, required this.onRemove});

  final PickedReceiptImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            image.bytes,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                image.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('削除'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
