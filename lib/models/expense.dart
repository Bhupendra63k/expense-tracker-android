class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String userId;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'userId': userId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}