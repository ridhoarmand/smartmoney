import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../transaction/service_providers/transaction_service_providers.dart';

class ReportDetails extends ConsumerStatefulWidget {
  const ReportDetails({super.key});

  @override
  ConsumerState<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends ConsumerState<ReportDetails> {
  String selectedFilter = 'Year'; // Default filter
  String selectedTransactionType = 'Income'; // Default transaction type filter

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Details')),
        body: const Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: ref.watch(transactionStreamProvider(uid)).when(
            data: (transactions) {
              final now = DateTime.now();
              final startOfWeek =
                  now.subtract(Duration(days: now.weekday)); // Start of week
              final startOfMonth =
                  DateTime(now.year, now.month, 1); // Start of month
              final currentYear = now.year;

              // Data grouping
              List<double> weeklyIncome = List.filled(7, 0.0);
              List<double> weeklyExpense = List.filled(7, 0.0);
              List<double> monthlyIncome = List.filled(4, 0.0);
              List<double> monthlyExpense = List.filled(4, 0.0);
              List<double> yearlyIncome = List.filled(12, 0.0);
              List<double> yearlyExpense = List.filled(12, 0.0);
              List<dynamic> filteredTransactions = [];

              for (var transaction in transactions) {
                final date = transaction.date;

                if (selectedFilter == 'Week' &&
                    (date.isAfter(startOfWeek) ||
                        date.isAtSameMomentAs(startOfWeek))) {
                  filteredTransactions.add(transaction);
                } else if (selectedFilter == 'Month' &&
                    (date.isAfter(startOfMonth) ||
                        date.isAtSameMomentAs(startOfMonth))) {
                  filteredTransactions.add(transaction);
                } else if (selectedFilter == 'Year' &&
                    date.year == currentYear) {
                  filteredTransactions.add(transaction);
                }

                if (date.year == currentYear) {
                  final monthIndex = date.month - 1;
                  if (transaction.categoryType == 'Income') {
                    yearlyIncome[monthIndex] += transaction.amount;
                  } else if (transaction.categoryType == 'Expense') {
                    yearlyExpense[monthIndex] += transaction.amount;
                  }
                }

                if (date.isAfter(startOfMonth) ||
                    date.isAtSameMomentAs(startOfMonth)) {
                  final weekIndex = ((date.day - 1) ~/ 7).clamp(0, 3);
                  if (transaction.categoryType == 'Income') {
                    monthlyIncome[weekIndex] += transaction.amount;
                  } else if (transaction.categoryType == 'Expense') {
                    monthlyExpense[weekIndex] += transaction.amount;
                  }
                }

                if (date.isAfter(startOfWeek) ||
                    date.isAtSameMomentAs(startOfWeek)) {
                  final dayIndex =
                      date.difference(startOfWeek).inDays.clamp(0, 6);
                  if (transaction.categoryType == 'Income') {
                    weeklyIncome[dayIndex] += transaction.amount;
                  } else if (transaction.categoryType == 'Expense') {
                    weeklyExpense[dayIndex] += transaction.amount;
                  }
                }
              }

              filteredTransactions = filteredTransactions
                  .where((transaction) =>
                      transaction.categoryType == selectedTransactionType)
                  .toList();

              List<double> incomeData;
              List<double> expenseData;
              int xCount;
              String Function(int index) labelFormatter;

              if (selectedFilter == 'Week') {
                incomeData = weeklyIncome;
                expenseData = weeklyExpense;
                xCount = 7;
                labelFormatter = (index) => DateFormat.E()
                    .format(startOfWeek.add(Duration(days: index)))
                    .substring(0, 3);
              } else if (selectedFilter == 'Month') {
                incomeData = monthlyIncome;
                expenseData = monthlyExpense;
                xCount = 4;
                labelFormatter = (index) => 'Week ${index + 1}';
              } else {
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

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Filter Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['Week', 'Month', 'Year'].map((filter) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedFilter = filter;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedFilter == filter
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                foregroundColor: selectedFilter == filter
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              child: Text(filter),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: xCount * 84.0,
                                    child: BarChart(
                                      BarChartData(
                                        barGroups:
                                            List.generate(xCount, (index) {
                                          return BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: incomeData[index],
                                                color: Colors.green,
                                                width: 20,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              BarChartRodData(
                                                toY: expenseData[index],
                                                color: Colors.red,
                                                width: 20,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ],
                                          );
                                        }),
                                        titlesData: FlTitlesData(
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) =>
                                                  Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  labelFormatter(value.toInt()),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        gridData: const FlGridData(show: true),
                                        barTouchData: BarTouchData(
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipMargin: 0,
                                            fitInsideHorizontally: true,
                                            fitInsideVertically: true,
                                            getTooltipItem: (group, groupIndex,
                                                rod, rodIndex) {
                                              final label = rodIndex == 0
                                                  ? 'Income'
                                                  : 'Expense';
                                              return BarTooltipItem(
                                                '$label\n ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(rod.toY)}',
                                                const TextStyle(
                                                    color: Colors.white),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Transaksi dan Filter
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 400,
                          minHeight: 150,
                        ),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Tombol Income/Expense
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: ['Income', 'Expense'].map((type) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedTransactionType = type;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              selectedTransactionType == type
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.2),
                                          foregroundColor:
                                              selectedTransactionType == type
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                        ),
                                        child: Text(type),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                // Daftar Transaksi
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredTransactions.length,
                                    itemBuilder: (context, index) {
                                      final transaction =
                                          filteredTransactions[index];
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: transaction
                                                        .categoryType ==
                                                    'Income'
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            child: Icon(
                                              transaction.categoryType ==
                                                      'Income'
                                                  ? Icons.arrow_downward
                                                  : Icons.arrow_upward,
                                              color: transaction.categoryType ==
                                                      'Income'
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          title: Text(transaction.description),
                                          subtitle: Text(DateFormat.yMMMd()
                                              .format(transaction.date)),
                                          trailing: Text(
                                            NumberFormat.currency(
                                                    locale: 'id_ID',
                                                    symbol: 'Rp ')
                                                .format(transaction.amount),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error: ${error.toString()}')),
          ),
    );
  }
}
