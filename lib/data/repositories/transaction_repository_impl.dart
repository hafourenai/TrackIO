import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/app_database.dart';
import '../models/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

class TransactionRepositoryImpl implements TransactionRepository {
  final _controller = StreamController<List<Transaction>>.broadcast();
  List<Transaction> _cache = [];
  bool _loaded = false;

  Database get _db => AppDatabase.instance;

  Future<void> _loadFromDb() async {
    if (_loaded) return;
    final models = await _db.query('transactions', orderBy: 'date DESC');
    _cache = models.map((m) => TransactionModel.fromMap(m).toEntity()).toList();
    _loaded = true;
  }

  Future<void> _emit() async {
    await _loadFromDb();
    if (_controller.hasListener) {
      _controller.add(_cache);
    }
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    await _loadFromDb();
    return _cache;
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final models = await _db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return models.map((m) => TransactionModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Transaction?> getTransactionById(int id) async {
    final models = await _db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (models.isEmpty) return null;
    return TransactionModel.fromMap(models.first).toEntity();
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    final map = model.toMap();
    if (transaction.id != null) {
      await _db.update('transactions', map, where: 'id = ?', whereArgs: [transaction.id]);
    } else {
      map.remove('id');
      await _db.insert('transactions', map);
    }
    _loaded = false;
    _emit();
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _loaded = false;
    _emit();
  }

  @override
  Stream<List<Transaction>> watchTransactions() async* {
    await _loadFromDb();
    yield List.from(_cache);
    await for (final txns in _controller.stream) {
      yield txns;
    }
  }

  void dispose() {
    _controller.close();
  }
}
