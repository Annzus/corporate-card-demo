import 'package:corporate_card_companion/features/transactions/data/transaction_fixture_data_source.dart';
import 'package:corporate_card_companion/features/transactions/data/transaction_repository_impl.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';
import 'package:corporate_card_companion/features/transactions/domain/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final failNextTransactionLoadProvider =
    NotifierProvider<FailNextTransactionLoad, bool>(
      FailNextTransactionLoad.new,
    );

class FailNextTransactionLoad extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(TransactionFixtureDataSource());
});

final transactionListControllerProvider =
    AsyncNotifierProvider<TransactionListController, List<Transaction>>(
      TransactionListController.new,
    );

class TransactionListController extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    if (ref.read(failNextTransactionLoadProvider)) {
      ref.read(failNextTransactionLoadProvider.notifier).set(false);
      throw Exception('transaction_load_failed');
    }
    return ref
        .watch(transactionRepositoryProvider)
        .fetchTransactions(brandId: 'business');
  }

  void retry() {
    ref.invalidateSelf();
  }
}
