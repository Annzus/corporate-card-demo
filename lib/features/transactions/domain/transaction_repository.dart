import 'package:corporate_card_companion/features/transactions/domain/transaction.dart';

abstract interface class TransactionRepository {
  Future<List<Transaction>> fetchTransactions({required String brandId});
}
