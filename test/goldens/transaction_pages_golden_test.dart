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
  testWidgets('transaction list golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpApp(tester, '/');
    await _pumpReady(tester);

    await expectLater(
      find.byType(BizCardDemoApp),
      matchesGoldenFile('transaction_list.png'),
    );
  });

  testWidgets('transaction detail golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpApp(tester, '/transactions/txn_business_001');
    await _pumpReady(tester);

    await expectLater(
      find.byType(BizCardDemoApp),
      matchesGoldenFile('transaction_detail_missing_receipt.png'),
    );
  });
}

Future<void> _pumpApp(WidgetTester tester, String initialLocation) {
  appRouter.go(initialLocation);
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          _GoldenTransactionRepository(),
        ),
      ],
      child: const BizCardDemoApp(),
    ),
  );
}

Future<void> _pumpReady(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 20; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  expect(find.byType(CircularProgressIndicator), findsNothing);
}

final class _GoldenTransactionRepository implements TransactionRepository {
  @override
  Future<List<Transaction>> fetchTransactions({required String brandId}) async {
    return [
      _transaction(),
      _transaction(
        id: 'txn_business_002',
        merchantName: 'TOKYO STATIONERY SUPPLY',
        status: TransactionStatus.authorized,
      ),
      _transaction(
        id: 'txn_business_003',
        merchantName: 'SHINKANSEN ONLINE',
        receiptStatus: ReceiptStatus.attached,
      ),
    ];
  }
}

Transaction _transaction({
  String id = 'txn_business_001',
  String merchantName = 'AWS JAPAN',
  TransactionStatus status = TransactionStatus.cleared,
  ReceiptStatus receiptStatus = ReceiptStatus.missing,
}) {
  return Transaction(
    id: id,
    brandId: 'business',
    cardId: 'card_business_01',
    cardNickname: '開発チームカード',
    cardLast4: '4242',
    merchantName: merchantName,
    amount: const Money(minorUnits: 12800, currency: 'JPY'),
    authorizedAt: DateTime.utc(2026, 6, 22, 9, 31),
    status: status,
    receiptStatus: receiptStatus,
    memo: null,
  );
}
