import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';
import 'package:flutter/material.dart';

class UploadStatusBanner extends StatelessWidget {
  const UploadStatusBanner({super.key, required this.job, required this.onTap});

  final UploadJob job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (job.progress * 100).round();
    final title = switch (job.state) {
      UploadJobState.uploading => 'アップロード中 $percent%',
      UploadJobState.succeeded => '提出済み',
      UploadJobState.failed => 'アップロード失敗',
    };

    return Semantics(
      button: true,
      label: 'アップロード状態: $title',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_upload_outlined),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (job.state == UploadJobState.uploading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: job.progress,
                    semanticsLabel: 'アップロード進捗',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
