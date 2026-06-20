import '../../domain/entities/transaction.dart';

class TransactionModel {
  final int? id;
  final String title;
  final DateTime date;
  final String type;
  final String category;
  final double amount;
  final String? note;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  Transaction toEntity() {
    return Transaction(
      id: id,
      title: title,
      date: date,
      type: type,
      category: category,
      amount: amount,
      note: note,
      createdAt: createdAt,
    );
  }

  static TransactionModel fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      type: entity.type,
      category: entity.category,
      amount: entity.amount,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
