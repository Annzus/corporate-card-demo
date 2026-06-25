import 'dart:async';
import 'dart:typed_data';

import 'package:corporate_card_companion/app/app.dart';
import 'package:corporate_card_companion/app/router.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/receipt_image_picker.dart';
import 'package:corporate_card_companion/features/receipt_upload/application/upload_queue_controller.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/receipt_upload_repository.dart';
import 'package:corporate_card_companion/features/receipt_upload/domain/upload_job.dart';
import 'package:corporate_card_companion/features/transactions/application/transaction_list_controller.dart';
import 'package:corporate_card_companion/features/transactions/domain/money.dart';
import 'package:corporate_card_companion/features/transactions/domain/receipt_status.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_repository.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading state', (tester) async {
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(
          () => Future<List<Transaction>>.delayed(const Duration(days: 1)),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error and retries to empty state', (tester) async {
    var shouldFail = true;
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async {
          if (shouldFail) throw Exception('fail');
          return [];
        }),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('明細を読み込めませんでした'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('再読み込み'));
    await tester.pumpAndSettle();

    expect(find.text('該当する明細はありません'), findsOneWidget);
  });

  testWidgets('shows data and navigates between pages', (tester) async {
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async => [_transaction()]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('利用明細'), findsOneWidget);
    expect(find.text('AWS JAPAN'), findsOneWidget);
    expect(find.text('証憑未提出 1件'), findsOneWidget);

    await tester.tap(find.byTooltip('デモ設定'));
    await tester.pumpAndSettle();

    expect(find.text('デモ設定'), findsOneWidget);
    expect(find.text('デモ専用'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('利用明細'), findsOneWidget);

    await tester.tap(find.text('AWS JAPAN'));
    await tester.pumpAndSettle();

    expect(find.text('利用明細詳細'), findsOneWidget);
    expect(find.text('¥12,800'), findsWidgets);
    expect(find.text('証憑が未提出です'), findsOneWidget);
    expect(find.text('開発チームカード ・ •••• 4242'), findsOneWidget);
  });

  testWidgets('filters missing receipts and keeps filter after detail pop', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(
          () async => [
            _transaction(
              id: 'txn_business_003',
              cardId: 'card_business_02',
              cardNickname: '営業カード',
              cardLast4: '8181',
              merchantName: 'SHINKANSEN ONLINE',
              amountMinor: 9999,
              receiptStatus: ReceiptStatus.attached,
            ),
            _transaction(),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SHINKANSEN ONLINE'), findsOneWidget);
    expect(find.text('今月の利用額 ¥9,999'), findsOneWidget);
    expect(find.text('今月の利用額 ¥22,799'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, '証憑未提出'));
    await tester.pumpAndSettle();

    expect(find.text('AWS JAPAN'), findsOneWidget);
    expect(find.text('SHINKANSEN ONLINE'), findsNothing);

    await tester.tap(find.text('AWS JAPAN'));
    await tester.pumpAndSettle();

    expect(find.text('利用明細詳細'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('AWS JAPAN'), findsOneWidget);
    expect(find.text('SHINKANSEN ONLINE'), findsNothing);
  });

  testWidgets('detail load error retries without showing not found', (
    tester,
  ) async {
    var shouldFail = true;
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async {
          if (shouldFail) throw Exception('fail');
          return [_transaction()];
        }),
        initialLocation: '/transactions/txn_business_001',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('明細を読み込めませんでした'), findsOneWidget);
    expect(find.text('対象の明細が見つかりません'), findsNothing);

    shouldFail = false;
    await tester.tap(find.text('再読み込み'));
    await tester.pumpAndSettle();

    expect(find.text('利用明細詳細'), findsOneWidget);
    expect(find.text('AWS JAPAN'), findsOneWidget);
  });

  testWidgets('selects and removes receipt image with memo limit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async => [_transaction()]),
        initialLocation: '/transactions/txn_business_001',
        imagePicker: _FakeReceiptImagePicker(
          () async => PickedReceiptImage(
            fileName: 'receipt.png',
            bytes: _transparentPngBytes(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('証憑を添付'));
    await tester.pumpAndSettle();

    expect(find.text('receipt.png'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '削除'));
    await tester.pumpAndSettle();

    expect(find.text('receipt.png'), findsNothing);
    expect(find.text('証憑が未提出です'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'あ' * 201);
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.controller.text.length, 200);
  });

  testWidgets('handles cancelled and failed receipt selection', (tester) async {
    var fail = false;
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async => [_transaction()]),
        initialLocation: '/transactions/txn_business_001',
        imagePicker: _FakeReceiptImagePicker(() async {
          if (fail) throw Exception('permission_denied');
          return null;
        }),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('証憑を添付'));
    await tester.pumpAndSettle();

    expect(find.text('画像を選択できませんでした。設定を確認して再度お試しください。'), findsNothing);

    fail = true;
    await tester.tap(find.text('証憑を添付'));
    await tester.pumpAndSettle();

    expect(find.text('画像を選択できませんでした。設定を確認して再度お試しください。'), findsOneWidget);
  });

  testWidgets('keeps upload visible after returning to list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final uploadCompleter = Completer<void>();

    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async => [_transaction()]),
        initialLocation: '/transactions/txn_business_001',
        imagePicker: _FakeReceiptImagePicker(
          () async => PickedReceiptImage(
            fileName: 'receipt.png',
            bytes: _transparentPngBytes(),
          ),
        ),
        uploadRepository: _FakeUploadRepository(
          (job, onProgress) => uploadCompleter.future,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('証憑を添付'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'アップロード'));
    await tester.pump();

    expect(find.text('アップロード中 0%'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('アップロード中 0%'), findsOneWidget);
    expect(find.text('receipt.png'), findsOneWidget);

    uploadCompleter.complete();
  });

  testWidgets('retries failed receipt upload', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var shouldFail = true;
    await tester.pumpWidget(
      _appWithRepository(
        _FakeTransactionRepository(() async => [_transaction()]),
        initialLocation: '/transactions/txn_business_001',
        imagePicker: _FakeReceiptImagePicker(
          () async => PickedReceiptImage(
            fileName: 'receipt.png',
            bytes: _transparentPngBytes(),
          ),
        ),
        uploadRepository: _FakeUploadRepository((job, onProgress) async {
          if (shouldFail) throw Exception('fail');
        }),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('証憑を添付'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'アップロード'));
    await tester.pumpAndSettle();

    expect(find.text('アップロードに失敗しました。再試行してください。'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '証憑を添付'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '削除'))
          .onPressed,
      isNull,
    );

    shouldFail = false;
    await tester.tap(find.text('再試行'));
    await tester.pumpAndSettle();

    expect(find.text('提出済み'), findsWidgets);
  });
}

Widget _appWithRepository(
  TransactionRepository repository, {
  String initialLocation = '/',
  ReceiptImagePicker? imagePicker,
  ReceiptUploadRepository? uploadRepository,
}) {
  appRouter.go(initialLocation);
  return ProviderScope(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(repository),
      if (imagePicker != null)
        receiptImagePickerProvider.overrideWithValue(imagePicker),
      if (uploadRepository != null)
        receiptUploadRepositoryProvider.overrideWithValue(uploadRepository),
    ],
    child: const BizCardDemoApp(),
  );
}

final class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._fetch);

  final Future<List<Transaction>> Function() _fetch;

  @override
  Future<List<Transaction>> fetchTransactions({required String brandId}) {
    return _fetch();
  }
}

final class _FakeReceiptImagePicker implements ReceiptImagePicker {
  const _FakeReceiptImagePicker(this._pick);

  final Future<PickedReceiptImage?> Function() _pick;

  @override
  Future<PickedReceiptImage?> pickImage() => _pick();
}

final class _FakeUploadRepository implements ReceiptUploadRepository {
  const _FakeUploadRepository(this._upload);

  final Future<void> Function(UploadJob, void Function(double)) _upload;

  @override
  Future<void> upload({
    required UploadJob job,
    required void Function(double progress) onProgress,
  }) {
    return _upload(job, onProgress);
  }
}

Transaction _transaction({
  String id = 'txn_business_001',
  String cardId = 'card_business_01',
  String cardNickname = '開発チームカード',
  String cardLast4 = '4242',
  String merchantName = 'AWS JAPAN',
  int amountMinor = 12800,
  ReceiptStatus receiptStatus = ReceiptStatus.missing,
}) {
  return Transaction(
    id: id,
    brandId: 'business',
    cardId: cardId,
    cardNickname: cardNickname,
    cardLast4: cardLast4,
    merchantName: merchantName,
    amount: Money(minorUnits: amountMinor, currency: 'JPY'),
    authorizedAt: DateTime.utc(2026, 6, 22),
    status: TransactionStatus.cleared,
    receiptStatus: receiptStatus,
    memo: null,
  );
}

Uint8List _transparentPngBytes() {
  return Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    13,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    248,
    255,
    255,
    63,
    0,
    5,
    254,
    2,
    254,
    167,
    53,
    129,
    132,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130,
  ]);
}
