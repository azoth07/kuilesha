class Transaction {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    this.category = '',
    this.description = '',
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String? ?? '',
        description: map['description'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  Transaction copyWith({
    double? amount,
    String? category,
    String? description,
    DateTime? date,
  }) =>
      Transaction(
        id: id,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        description: description ?? this.description,
        date: date ?? this.date,
        createdAt: createdAt,
      );
}
