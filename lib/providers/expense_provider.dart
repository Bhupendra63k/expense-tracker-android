import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Expense> _expenses = [];

  List<Expense> get expenses => [..._expenses];

  /// Total expenses
  double get totalExpenses {
    return _expenses.fold(0.0, (total, expense) => total + expense.amount);
  }

  /// Expenses grouped by category
  Map<String, double> get categoryExpenses {
    final Map<String, double> categories = {};
    for (final expense in _expenses) {
      categories[expense.category] =
          (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }

  Future<void> loadExpenses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      _expenses = snapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toMap());
      _expenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }

  Future<void> updateExpense(String id, {required double amount, required String category, required DateTime date, required String description}) async {}
}
