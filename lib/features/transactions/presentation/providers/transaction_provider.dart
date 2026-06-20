import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/repositories/transaction_repository.dart';

final transactionListStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions();
});

final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
final transactionTypeFilterProvider = StateProvider<String>((ref) => 'all');
final transactionCategoryFilterProvider = StateProvider<String>((ref) => 'all');
final transactionDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionListStreamProvider);
  final query = ref.watch(transactionSearchQueryProvider).toLowerCase();
  final type = ref.watch(transactionTypeFilterProvider);
  final category = ref.watch(transactionCategoryFilterProvider);
  final dateRange = ref.watch(transactionDateRangeProvider);

  return transactionsAsync.whenData((transactions) {
    return transactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(query) ||
          (tx.note?.toLowerCase().contains(query) ?? false);
      
      final matchesType = type == 'all' || tx.type == type;
      
      final matchesCategory = category == 'all' || tx.category.toLowerCase() == category.toLowerCase();
      
      bool matchesDate = true;
      if (dateRange != null) {
        matchesDate = tx.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesType && matchesCategory && matchesDate;
    }).toList();
  });
});

final transactionControllerProvider = Provider<TransactionController>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionController(repository);
});

class TransactionController {
  final TransactionRepository _repository;

  TransactionController(this._repository);

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.saveTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.saveTransaction(transaction);
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
  }
}
