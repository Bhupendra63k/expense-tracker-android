import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final filteredExpenses = expenseProvider.expenses.where((expense) {
      final query = _searchQuery.toLowerCase();
      return expense.category.toLowerCase().contains(query) ||
             expense.description.toLowerCase().contains(query) ||
             expense.amount.toString().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search expenses...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(expense.category[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(expense.category, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(expense.date)),
              trailing: Text('₹${expense.amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}