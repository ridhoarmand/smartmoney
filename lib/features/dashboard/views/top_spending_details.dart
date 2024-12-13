import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../auth/providers/auth_provider.dart';
import '../../category/models/category.dart';
import '../../category/service_providers/category_service_provider.dart';
import '../../transaction/models/user_transaction_model.dart';
import '../../transaction/service_providers/transaction_service_providers.dart';

class TopSpendingDetailsScreen extends ConsumerStatefulWidget {
  const TopSpendingDetailsScreen({super.key});

  @override
  ConsumerState<TopSpendingDetailsScreen> createState() =>
      _TopSpendingDetailsScreenState();
}

class _TopSpendingDetailsScreenState
    extends ConsumerState<TopSpendingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showParentCategories = true;
  bool _isDetailsExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, initialIndex: 11, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserTransaction> _filterTransactions(
      List<UserTransaction> transactions, int monthsAgo) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month - monthsAgo, 1);
    final endOfMonth =
        DateTime(now.year, now.month - monthsAgo + 1, 0, 23, 59, 59, 999);

    return transactions
        .where((t) =>
            t.date.isAtSameMomentAs(startOfMonth) ||
            t.date.isAtSameMomentAs(endOfMonth) ||
            (t.date.isAfter(startOfMonth) && t.date.isBefore(endOfMonth)))
        .where((t) => t.categoryType == 'Expense')
        .toList();
  }

  Map<String, dynamic> _aggregateCategories(List<UserTransaction> transactions,
      List<Category> categories, bool useParentCategories) {
    final categoryMap = {for (var cat in categories) cat.id: cat};
    final categoryTotals = <String, Map<String, dynamic>>{};

    for (var transaction in transactions) {
      final category = categoryMap[transaction.categoryId];
      if (category == null) continue;

      String categoryKey;
      IconData categoryIcon;

      if (useParentCategories) {
        final parentId = category.parentId ?? category.id;
        final parentCategory = categoryMap[parentId] ?? category;
        categoryKey = parentCategory.name;
        categoryIcon = parentCategory.icon;
      } else {
        categoryKey = category.name;
        categoryIcon = category.icon;
      }

      if (!categoryTotals.containsKey(categoryKey)) {
        categoryTotals[categoryKey] = {
          'total': 0.0,
          'icon': categoryIcon,
        };
      }

      categoryTotals[categoryKey]!['total'] += transaction.amount;
    }

    // Sort categories by total in descending order
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value['total'].compareTo(a.value['total']));

    return Map.fromEntries(sortedCategories);
  }

  Widget _buildCategoryBreakdownWidget(
      Map<String, dynamic> categoryTotals, double totalSpending) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height:
          _isDetailsExpanded ? MediaQuery.of(context).size.height * 0.5 : 100,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            // If dragging down, collapse the widget
            _isDetailsExpanded = details.delta.dy > 0 ? false : true;
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag indicator
              Container(
                width: 50,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categoryTotals.entries.length,
                  itemBuilder: (context, index) {
                    final entry = categoryTotals.entries.toList()[index];
                    final percentage =
                        (entry.value['total'] / totalSpending * 100)
                            .toStringAsFixed(1);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Vertical line
                          Container(
                            width: 2,
                            height: 50,
                            color: Colors
                                .primaries[index % Colors.primaries.length],
                          ),
                          const SizedBox(width: 16),

                          // Category icon
                          CircleAvatar(
                            backgroundColor: Colors
                                .primaries[index % Colors.primaries.length]
                                .withOpacity(0.2),
                            child: Icon(entry.value['icon'],
                                color: Colors.primaries[
                                    index % Colors.primaries.length]),
                          ),
                          const SizedBox(width: 16),

                          // Category name and amount
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(entry.value['total']),
                                  style: TextStyle(color: Colors.grey[600]))
                            ],
                          )),

                          // Percentage
                          Text('$percentage%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.primaries[
                                      index % Colors.primaries.length]))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: Icon(_showParentCategories
                ? Icons.account_tree_outlined
                : Icons.account_tree),
            onPressed: () {
              setState(() {
                _showParentCategories = !_showParentCategories;
              });
            },
          ),
        ],
      ),
      body: ref.watch(transactionStreamProvider(uid)).when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }

              return ref.watch(categoryStreamProvider(uid)).when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Center(child: Text('No categories found'));
                      }

                      return Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabs: List.generate(12, (index) {
                              final now = DateTime.now();
                              final targetMonth = now
                                  .subtract(Duration(days: 30 * (11 - index)));
                              return Tab(
                                text: DateFormat('MMM y').format(targetMonth),
                              );
                            }),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: List.generate(12, (monthIndex) {
                                final filteredTransactions =
                                    _filterTransactions(
                                        transactions, 11 - monthIndex);

                                final categoryTotals = _aggregateCategories(
                                    filteredTransactions,
                                    categories,
                                    _showParentCategories);

                                final totalSpending = categoryTotals.values
                                    .fold(0.0,
                                        (sum, value) => sum + value['total']);

                                final daysInMonth = DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month -
                                            (11 - monthIndex) +
                                            1,
                                        0)
                                    .day;

                                final dailyAverage =
                                    totalSpending / daysInMonth;

                                final dataMap =
                                    categoryTotals.map((key, value) {
                                  final percentage = (value['total'] /
                                      totalSpending *
                                      100) as double;
                                  return MapEntry(key, percentage);
                                });

                                final colorList = List.generate(
                                    categoryTotals.length,
                                    (_) => Colors.primaries[
                                        _ % Colors.primaries.length]);

                                return Column(
                                  children: [
                                    // Total dan rata-rata harian
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total: ${NumberFormat.currency(
                                              locale: 'id_ID',
                                              symbol: 'Rp ',
                                              decimalDigits: 0,
                                            ).format(totalSpending)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Avg/Day: ${NumberFormat.currency(
                                              locale: 'id_ID',
                                              symbol: 'Rp ',
                                              decimalDigits: 0,
                                            ).format(dailyAverage)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Pie Chart
                                    if (dataMap.isNotEmpty) ...[
                                      Expanded(
                                        flex: 2,
                                        child: PieChart(
                                          dataMap: dataMap,
                                          colorList: colorList,
                                          chartType: ChartType.disc,
                                          chartRadius: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          ringStrokeWidth: 32,
                                          chartValuesOptions:
                                              const ChartValuesOptions(
                                            showChartValueBackground: true,
                                            showChartValues: true,
                                            chartValueStyle:
                                                TextStyle(color: Colors.black),
                                            decimalPlaces: 1,
                                            showChartValuesInPercentage: true,
                                          ),
                                          legendOptions: LegendOptions(
                                            showLegendsInRow: false,
                                            legendPosition: _isDetailsExpanded
                                                ? LegendPosition.right
                                                : LegendPosition.bottom,
                                            showLegends: true,
                                            legendShape: BoxShape.circle,
                                            legendTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    // Category Breakdown Widget
                                    _buildCategoryBreakdownWidget(
                                        categoryTotals, totalSpending)
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
    );
  }
}
