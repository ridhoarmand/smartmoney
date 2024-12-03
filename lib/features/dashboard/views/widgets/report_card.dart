import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../transaction/service_providers/transaction_service_providers.dart';

class ReportCard extends ConsumerWidget {
  final String uid;

  const ReportCard({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsyncValue = ref.watch(transactionStreamProvider(uid));

    return transactionAsyncValue.when(
      data: (transactions) {
        // Filter transactions by date range
        DateTime now = DateTime.now();
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime startOfMonth = DateTime(now.year, now.month, 1);

        // Calculate totals
        num totalIncomeWeek = transactions
            .where((transaction) =>
                transaction.date.isAfter(startOfWeek) &&
                transaction.categoryType == 'Income')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        num totalExpenseWeek = transactions
            .where((transaction) =>
                transaction.date.isAfter(startOfWeek) &&
                transaction.categoryType == 'Expense')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        num totalIncomeMonth = transactions
            .where((transaction) =>
                transaction.date.isAfter(startOfMonth) &&
                transaction.categoryType == 'Income')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        num totalExpenseMonth = transactions
            .where((transaction) =>
                transaction.date.isAfter(startOfMonth) &&
                transaction.categoryType == 'Expense')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        return ReportContent(
          totalIncomeWeek: totalIncomeWeek,
          totalExpenseWeek: totalExpenseWeek,
          totalIncomeMonth: totalIncomeMonth,
          totalExpenseMonth: totalExpenseMonth,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class ReportContent extends StatefulWidget {
  final num totalIncomeWeek;
  final num totalExpenseWeek;
  final num totalIncomeMonth;
  final num totalExpenseMonth;

  const ReportContent({
    Key? key,
    required this.totalIncomeWeek,
    required this.totalExpenseWeek,
    required this.totalIncomeMonth,
    required this.totalExpenseMonth,
  }) : super(key: key);

  @override
  State<ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<ReportContent> {
  bool isWeekly = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalIncome =
        isWeekly ? widget.totalIncomeWeek : widget.totalIncomeMonth;
    final totalExpense =
        isWeekly ? widget.totalExpenseWeek : widget.totalExpenseMonth;

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Report',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to details screen
                  },
                  child: const Text(
                    'See details',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Toggle Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isWeekly = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWeekly
                          ? theme.colorScheme.primary.withOpacity(0.8)
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      foregroundColor: isWeekly
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    child: const Text('Week'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isWeekly = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isWeekly
                          ? theme.colorScheme.primary.withOpacity(0.8)
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      foregroundColor: !isWeekly
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    child: const Text('Month'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bar Chart
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalIncome.toDouble(),
                          color: Colors.green,
                          width: 50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalExpense.toDouble(),
                          color: Colors.red,
                          width: 50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Income');
                            case 1:
                              return const Text('Expense');
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipMargin: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label =
                            group.x == 0 ? 'Income' : 'Expense';
                        return BarTooltipItem(
                          '$label\n${formatCurrency.format(rod.toY)}',
                          TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
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
    );
  }
}