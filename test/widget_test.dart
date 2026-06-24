import 'package:corporate_card_companion/app/app.dart';
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
    expect(find.text('ID: txn_business_001'), findsOneWidget);
  });
}

Widget _appWithRepository(TransactionRepository repository) {
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

Transaction _transaction() {
  return Transaction(
    id: 'txn_business_001',
    brandId: 'business',
    cardId: 'card_business_01',
    cardNickname: '開発チームカード',
    cardLast4: '4242',
    merchantName: 'AWS JAPAN',
    amount: const Money(minorUnits: 12800, currency: 'JPY'),
    authorizedAt: DateTime.utc(2026, 6, 22),
    status: TransactionStatus.cleared,
    receiptStatus: ReceiptStatus.missing,
    memo: null,
  );
}
