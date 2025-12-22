import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../models/monthly_budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _fixedController = TextEditingController();
  final _savingsController = TextEditingController();
  double _availableBudget = 0;

  @override
  void initState() {
    super.initState();
    _incomeController.addListener(_calculateAvailable);
    _fixedController.addListener(_calculateAvailable);
    _savingsController.addListener(_calculateAvailable);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _fixedController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  void _calculateAvailable() {
    final income = double.tryParse(_incomeController.text) ?? 0;
    final fixed = double.tryParse(_fixedController.text) ?? 0;
    final savings = double.tryParse(_savingsController.text) ?? 0;
    setState(() {
      _availableBudget = income - fixed - savings;
    });
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final budget = MonthlyBudget(
      id: DateTime.now().toString(),
      monthlyIncome: double.parse(_incomeController.text),
      fixedExpenses: double.tryParse(_fixedController.text) ?? 0,
      savingsGoal: double.tryParse(_savingsController.text) ?? 0,
      availableBudget: _availableBudget,
      month: month,
      userId: authProvider.userId,
    );

    await budgetProvider.saveBudget(budget);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Budget saved! Available: ₹${_availableBudget.toStringAsFixed(2)}'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final currentBudget = budgetProvider.currentBudget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentBudget != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✓ Current Month Budget Active',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available Budget: ₹${currentBudget.availableBudget.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildInputCard(
                'Monthly Income',
                _incomeController,
                'Enter your monthly income',
                true,
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                'Fixed Expenses (Rent, Bills, etc.)',
                _fixedController,
                'Enter fixed monthly expenses',
                false,
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                'Savings Goal',
                _savingsController,
                'How much do you want to save?',
                false,
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Available for Expenses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_availableBudget.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _availableBudget >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '💾 Save Budget',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
    String label,
    TextEditingController controller,
    String hint,
    bool required,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (required && (value == null || value.isEmpty)) {
                  return 'This field is required';
                }
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}