class MonthlyBudget {
  final String id;
  final double monthlyIncome;
  final double fixedExpenses;
  final double savingsGoal;
  final double availableBudget;
  final String month;
  final String userId;

  MonthlyBudget({
    required this.id,
    required this.monthlyIncome,
    required this.fixedExpenses,
    required this.savingsGoal,
    required this.availableBudget,
    required this.month,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthlyIncome': monthlyIncome,
      'fixedExpenses': fixedExpenses,
      'savingsGoal': savingsGoal,
      'availableBudget': availableBudget,
      'month': month,
      'userId': userId,
    };
  }

  factory MonthlyBudget.fromMap(Map<String, dynamic> map, String id) {
    return MonthlyBudget(
      id: id,
      monthlyIncome: map['monthlyIncome']?.toDouble() ?? 0.0,
      fixedExpenses: map['fixedExpenses']?.toDouble() ?? 0.0,
      savingsGoal: map['savingsGoal']?.toDouble() ?? 0.0,
      availableBudget: map['availableBudget']?.toDouble() ?? 0.0,
      month: map['month'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}