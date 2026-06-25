import 'package:corporate_card_companion/app/app.dart';
import 'package:corporate_card_companion/app/router.dart';
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
}

Widget _appWithRepository(
  TransactionRepository repository, {
  String initialLocation = '/',
}) {
  appRouter.go(initialLocation);
  return ProviderScope(
    overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
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
