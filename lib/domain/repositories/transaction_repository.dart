import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<Transaction?> getTransactionById(int id);
  Future<void> saveTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
  Stream<List<Transaction>> watchTransactions();
}
