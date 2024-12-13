import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../transaction/service_providers/transaction_service_providers.dart';
import '../models/report_data.dart';

class ReportDetailsScreen extends ConsumerStatefulWidget {
  const ReportDetailsScreen({super.key});

  @override
  ConsumerState<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends ConsumerState<ReportDetailsScreen> {
  String _selectedFilter = 'Year';
  String _selectedTransactionType = 'Income';

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;

    if (uid == null) {
      return _buildUnauthenticatedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: ref.watch(transactionStreamProvider(uid)).when(
            data: (transactions) => _buildReportContent(transactions),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
    );
  }

  Widget _buildUnauthenticatedScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: const Center(child: Text('User not logged in')),
    );
  }

  Widget _buildReportContent(List<dynamic> transactions) {
    final reportData = _processTransactionData(transactions);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterButtons(),
            const SizedBox(height: 8),
            _buildReportChart(reportData),
            const SizedBox(height: 8),
            _buildTransactionSection(reportData.filteredTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['Week', 'Month', 'Year'].map((filter) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedFilter = filter),
            style: _getFilterButtonStyle(filter),
            child: Text(filter),
          ),
        );
      }).toList(),
    );
  }

  ButtonStyle _getFilterButtonStyle(String filter) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor: _selectedFilter == filter
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withOpacity(0.2),
      foregroundColor: _selectedFilter == filter
          ? Colors.white
          : theme.colorScheme.onSurface,
    );
  }

  Widget _buildReportChart(ReportData reportData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildBarChart(reportData),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(ReportData reportData) {
    return SizedBox(
      width: reportData.xCount * 84.0,
      child: BarChart(
        BarChartData(
          barGroups: _generateBarGroups(reportData),
          titlesData: _buildChartTitlesData(reportData),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          barTouchData: _buildBarTouchData(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(ReportData reportData) {
    return List.generate(reportData.xCount, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          _createBarRod(reportData.incomeData[index], Colors.green),
          _createBarRod(reportData.expenseData[index], Colors.red),
        ],
      );
    });
  }

  BarChartRodData _createBarRod(double value, Color color) {
    return BarChartRodData(
      toY: value,
      color: color,
      width: 20,
      borderRadius: BorderRadius.circular(4),
    );
  }

  FlTitlesData _buildChartTitlesData(ReportData reportData) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              reportData.labelFormatter(value.toInt()),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipMargin: 0,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final label = rodIndex == 0 ? 'Income' : 'Expense';
          return BarTooltipItem(
            '$label\n ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(rod.toY)}',
            const TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildTransactionSection(List<dynamic> filteredTransactions) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 500,
        minHeight: 150,
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildTransactionTypeButtons(),
            const SizedBox(height: 4),
            _buildTransactionList(filteredTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['Income', 'Expense'].map((type) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedTransactionType = type),
            style: _getTransactionTypeButtonStyle(type),
            child: Text(type),
          ),
        );
      }).toList(),
    );
  }

  ButtonStyle _getTransactionTypeButtonStyle(String type) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor: _selectedTransactionType == type
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withOpacity(0.2),
      foregroundColor: _selectedTransactionType == type
          ? Colors.white
          : theme.colorScheme.onSurface,
    );
  }

  Widget _buildTransactionList(List<dynamic> filteredTransactions) {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) =>
            _buildTransactionItem(filteredTransactions[index]),
      ),
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceBright,
      child: ListTile(
        leading: _buildTransactionLeadingIcon(transaction),
        title: Text(
          transaction.description.isNotEmpty
              ? transaction.description
              : transaction.categoryName,
        ),
        subtitle: Text(_formatTransactionDate(transaction.date)),
        trailing: Text(
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits:
                transaction.amount == transaction.amount.toInt() ? 0 : 2,
          ).format(transaction.amount),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTransactionLeadingIcon(dynamic transaction) {
    final isIncome = transaction.categoryType == 'Income';
    return CircleAvatar(
      backgroundColor: isIncome ? Colors.green : Colors.red,
      child: Icon(
        transaction.categoryIcon,
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  ReportData _processTransactionData(List<dynamic> transactions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = now.add(const Duration(days: 6));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final currentYear = now.year;

    // Initialize data lists
    final weeklyIncome = List.filled(7, 0.0);
    final weeklyExpense = List.filled(7, 0.0);
    final monthlyIncome = List.filled(4, 0.0);
    final monthlyExpense = List.filled(4, 0.0);
    final yearlyIncome = List.filled(12, 0.0);
    final yearlyExpense = List.filled(12, 0.0);
    final filteredTransactions = <dynamic>[];

    // Process transactions
    for (var transaction in transactions) {
      _processTransaction(
        transaction,
        now,
        startOfWeek,
        endOfWeek,
        startOfMonth,
        currentYear,
        weeklyIncome,
        weeklyExpense,
        monthlyIncome,
        monthlyExpense,
        yearlyIncome,
        yearlyExpense,
        filteredTransactions,
      );
    }

    // Determine data based on selected filter
    List<double> incomeData;
    List<double> expenseData;
    int xCount;
    String Function(int index) labelFormatter;

    switch (_selectedFilter) {
      case 'Week':
        incomeData = weeklyIncome;
        expenseData = weeklyExpense;
        xCount = 7;
        labelFormatter = (index) => DateFormat.E()
            .format(startOfWeek.add(Duration(days: index)))
            .substring(0, 3);
        break;
      case 'Month':
        incomeData = monthlyIncome;
        expenseData = monthlyExpense;
        xCount = 4;
        labelFormatter = (index) => 'Week ${index + 1}';
        break;
      default: // Year
        incomeData = yearlyIncome;
        expenseData = yearlyExpense;
        xCount = 12;
        labelFormatter = (index) {
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          return months[index];
        };
    }

    // Filter transactions by selected type
    final typedFilteredTransactions = filteredTransactions
        .where((transaction) =>
            transaction.categoryType == _selectedTransactionType)
        .toList();

    return ReportData(
      incomeData: incomeData,
      expenseData: expenseData,
      xCount: xCount,
      labelFormatter: labelFormatter,
      filteredTransactions: typedFilteredTransactions,
    );
  }

  void _processTransaction(
    dynamic transaction,
    DateTime now,
    DateTime startOfWeek,
    DateTime endOfWeek,
    DateTime startOfMonth,
    int currentYear,
    List<double> weeklyIncome,
    List<double> weeklyExpense,
    List<double> monthlyIncome,
    List<double> monthlyExpense,
    List<double> yearlyIncome,
    List<double> yearlyExpense,
    List<dynamic> filteredTransactions,
  ) {
    final date = transaction.date;

    // Filter transactions based on selected period
    if (_selectedFilter == 'Week' &&
        date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
      filteredTransactions.add(transaction);
    } else if (_selectedFilter == 'Month' &&
        (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth))) {
      filteredTransactions.add(transaction);
    } else if (_selectedFilter == 'Year' && date.year == currentYear) {
      filteredTransactions.add(transaction);
    }

    // Aggregate yearly data
    if (date.year == currentYear) {
      final monthIndex = date.month - 1;
      if (transaction.categoryType == 'Income') {
        yearlyIncome[monthIndex] += transaction.amount;
      } else if (transaction.categoryType == 'Expense') {
        yearlyExpense[monthIndex] += transaction.amount;
      }
    }

    // Aggregate monthly data
    if (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth)) {
      final weekIndex = ((date.day - 1) ~/ 7).clamp(0, 3);
      if (transaction.categoryType == 'Income') {
        monthlyIncome[weekIndex] += transaction.amount;
      } else if (transaction.categoryType == 'Expense') {
        monthlyExpense[weekIndex] += transaction.amount;
      }
    }

    // Aggregate weekly data
    if (date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
      final dayIndex = date.weekday - 1;
      if (transaction.categoryType == 'Income') {
        weeklyIncome[dayIndex] += transaction.amount;
      } else if (transaction.categoryType == 'Expense') {
        weeklyExpense[dayIndex] += transaction.amount;
      }
    }
  }
}
