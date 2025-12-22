import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/monthly_budget.dart';
import 'dart:developer' as developer;

class BudgetProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MonthlyBudget? _currentBudget;

  MonthlyBudget? get currentBudget => _currentBudget;

  Future<void> loadBudget(String userId) async {
    try {
      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: month)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _currentBudget = MonthlyBudget.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error loading budget: $e', name: 'BudgetProvider');
    }
  }

  Future<void> saveBudget(MonthlyBudget budget) async {
    try {
      await _firestore.collection('budgets').add(budget.toMap());
      _currentBudget = budget;
      notifyListeners();
    } catch (e) {
      developer.log('Error saving budget: $e', name: 'BudgetProvider');
    }
  }
}
