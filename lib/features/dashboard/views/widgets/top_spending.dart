import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../category/service_providers/category_service_provider.dart';
import '../../../transaction/models/user_transaction_model.dart';
import '../../../transaction/service_providers/transaction_service_providers.dart';
import '../../../category/models/category.dart';

class TopSpendingWidget extends ConsumerStatefulWidget {
  const TopSpendingWidget({super.key});

  @override
  ConsumerState<TopSpendingWidget> createState() => _TopSpendingWidgetState();
}

class _TopSpendingWidgetState extends ConsumerState<TopSpendingWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final endOfMonth = DateTime(now.year, now.month - monthsAgo + 1, 0);

    return transactions
        .where(
            (t) => t.date.isAfter(startOfMonth) && t.date.isBefore(endOfMonth))
        .where((t) => t.categoryType == 'Expense')
        .toList();
  }

  List<UserTransaction> _filterWeeklyTransactions(
      List<UserTransaction> transactions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return transactions
        .where((t) => t.date.isAfter(startOfWeek))
        .where((t) => t.categoryType == 'Expense')
        .toList();
  }

  Map<String, dynamic> _aggregateByParentCategory(
      List<UserTransaction> transactions, List<Category> categories) {
    final categoryMap = {for (var cat in categories) cat.id: cat};
    final parentCategoryTotals = <String, Map<String, dynamic>>{};

    for (var transaction in transactions) {
      final category = categoryMap[transaction.categoryId];
      if (category == null) continue;

      final parentId = category.parentId ?? category.id;
      final parentCategory = categoryMap[parentId] ?? category;

      if (!parentCategoryTotals.containsKey(parentCategory.name)) {
        parentCategoryTotals[parentCategory.name] = {
          'total': 0.0,
          'icon': parentCategory.icon,
        };
      }

      parentCategoryTotals[parentCategory.name]!['total'] += transaction.amount;
    }

    return parentCategoryTotals;
  }

  Widget _buildSpendingList(
      List<UserTransaction> filteredTransactions, List<Category> categories) {
    if (filteredTransactions.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    final categoryTotals =
        _aggregateByParentCategory(filteredTransactions, categories);

    // Sort by amount and take top 5
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value['total'].compareTo(a.value['total']));
    final topSpending = sortedCategories.take(5).toList();

    // Calculate total spending for percentage
    final totalSpending =
        topSpending.fold(0.0, (sum, entry) => sum + entry.value['total']);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topSpending.length,
      itemBuilder: (context, index) {
        final categoryTotal = topSpending[index];
        final percentage = (categoryTotal.value['total'] / totalSpending * 100)
            .toStringAsFixed(1);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(categoryTotal.value['icon'], color: Colors.red),
          ),
          title: Text(categoryTotal.key),
          subtitle: Text(NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(categoryTotal.value['total'])),
          trailing: Text(
            '$percentage%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return ref.watch(transactionStreamProvider(uid)).when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const SizedBox.shrink();
            }

            return ref.watch(categoryStreamProvider(uid)).when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Top Spending',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/top-spending'),
                                  child: const Text('See Details'),
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            tabs: const [
                              Tab(text: 'Weekly'),
                              Tab(text: 'Month'),
                            ],
                          ),
                          SizedBox(
                            height: 250,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSpendingList(
                                  _filterWeeklyTransactions(transactions),
                                  categories,
                                ),
                                _buildSpendingList(
                                  _filterTransactions(transactions, 0),
                                  categories,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
  }
}
