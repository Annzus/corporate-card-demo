import 'package:corporate_card_companion/features/transactions/data/transaction_fixture_data_source.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_repository.dart';

final class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dataSource);

  final TransactionFixtureDataSource _dataSource;

  @override
  Future<List<Transaction>> fetchTransactions({required String brandId}) async {
    final transactions = (await _dataSource.load(
      brandId: brandId,
    )).map((dto) => dto.toDomain()).toList();

    if (transactions.any((transaction) => transaction.brandId != brandId)) {
      throw StateError('Fixture contains another brand');
    }
    return transactions;
  }
}
