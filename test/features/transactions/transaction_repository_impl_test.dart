import 'package:corporate_card_companion/features/transactions/data/transaction_fixture_data_source.dart';
import 'package:corporate_card_companion/features/transactions/data/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = TransactionRepositoryImpl(TransactionFixtureDataSource());

  test('loads business transactions only', () async {
    final transactions = await repository.fetchTransactions(
      brandId: 'business',
    );

    expect(transactions, hasLength(6));
    expect(
      transactions.every((transaction) => transaction.brandId == 'business'),
      isTrue,
    );
    expect(
      transactions.any(
        (transaction) => transaction.id.startsWith('txn_executive'),
      ),
      isFalse,
    );
  });

  test('loads executive transactions only', () async {
    final transactions = await repository.fetchTransactions(
      brandId: 'executive',
    );

    expect(transactions, hasLength(6));
    expect(
      transactions.every((transaction) => transaction.brandId == 'executive'),
      isTrue,
    );
    expect(
      transactions.any(
        (transaction) => transaction.id.startsWith('txn_business'),
      ),
      isFalse,
    );
  });
}
