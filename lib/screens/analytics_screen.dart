import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';


import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  
  Map<String, double> getMonthlyExpenses(List<Expense> expenses) {
    Map<String, double> monthly = {};
    for (var expense in expenses) {
      final month = DateFormat('MMM yyyy').format(expense.date);
      monthly[month] = (monthly[month] ?? 0) + expense.amount;
    }
    return monthly;
  }

  Map<String, double> getCategoryExpenses(List<Expense> expenses) {
    Map<String, double> categories = {};
    for (var expense in expenses) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }

  double getCurrentMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses.where((e) => 
      e.date.year == now.year && e.date.month == now.month
    ).fold(0.0, (sum, e) => sum + e.amount);
  }

  double getLastMonthTotal(List<Expense> expenses) {
    final lastMonth = DateTime(DateTime.now().year, DateTime.now().month - 1);
    return expenses.where((e) => 
      e.date.year == lastMonth.year && e.date.month == lastMonth.month
    ).fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final expenses = expenseProvider.expenses;
    final currentMonth = getCurrentMonthTotal(expenses);
    final lastMonth = getLastMonthTotal(expenses);
    final difference = currentMonth - lastMonth;
    final double percentageChange = lastMonth > 0 ? ((difference / lastMonth) * 100) : 0;
    
    final monthlyData = getMonthlyExpenses(expenses);
    final categoryData = getCategoryExpenses(expenses);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Analytics & Insights', style: GoogleFonts.poppins()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildComparisonCard(currentMonth, lastMonth, difference, percentageChange, isDark),
          const SizedBox(height: 20),
          _buildMonthlyChart(monthlyData, isDark),
          const SizedBox(height: 20),
          _buildCategoryPieChart(categoryData, isDark),
          const SizedBox(height: 20),
          _buildSpendingTrend(expenses, isDark),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(double current, double last, double diff, double percent, bool isDark) {
    final isIncrease = diff > 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isIncrease 
            ? [Colors.red.shade400, Colors.red.shade600]
            : [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isIncrease ? Colors.red : Colors.green).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncrease ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Month Comparison',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '₹${current.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Month',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '₹${last.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${percent.abs().toStringAsFixed(1)}% ${isIncrease ? 'more' : 'less'} than last month',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(Map<String, double> data, bool isDark) {
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.toList();
    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252B48) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Monthly Spending',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < entries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entries[value.toInt()].key,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${(value / 1000).toStringAsFixed(0)}K',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 5,
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> data, bool isDark) {
    if (data.isEmpty) return const SizedBox.shrink();

    final colors = [
      Colors.blue, Colors.purple, Colors.orange, Colors.green,
      Colors.red, Colors.teal, Colors.pink, Colors.amber,
    ];

    final total = data.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252B48) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🥧 Category Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final percentage = (category.value / total) * 100;
                        
                        return PieChartSectionData(
                          value: category.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: colors[index % colors.length],
                          radius: 100,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.key,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrend(List<Expense> expenses, bool isDark) {
    final last7Days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i)));
    final dailySpending = <double>[];

    for (var day in last7Days) {
      final dayTotal = expenses.where((e) => 
        e.date.year == day.year && 
        e.date.month == day.month && 
        e.date.day == day.day
      ).fold(0.0, (sum, e) => sum + e.amount);
      dailySpending.add(dayTotal);
    }

    final maxValue = dailySpending.isEmpty ? 100.0 : dailySpending.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252B48) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 7-Day Trend',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < last7Days.length) {
                          return Text(
                            DateFormat('E').format(last7Days[value.toInt()]),
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxValue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: dailySpending.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
                    ),
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withValues(alpha:0.3),
                         const Color(0xFF8B83FF).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}