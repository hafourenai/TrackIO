class Transaction {
  final int? id;
  final String title;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const Transaction({
    this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  Transaction copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? type,
    String? category,
    double? amount,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
