import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/snackbar_helper.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transaction/service_providers/transaction_service_providers.dart';
import '../../../transaction/services/export_service.dart';
import '../../../wallet/models/wallet.dart';

class ReportCardWidget extends ConsumerStatefulWidget {
  final Wallet? selectedWallet;

  const ReportCardWidget({
    super.key,
    this.selectedWallet,
  });

  @override
  ConsumerState<ReportCardWidget> createState() => _ReportCardWidgetState();
}

class _ReportCardWidgetState extends ConsumerState<ReportCardWidget> {
  bool isWeekly = true;
  DateTime _selectedExportDate = DateTime.now();

  void _showDownloadDialog(BuildContext context) {
    ExportFormat selectedFormat = ExportFormat.csv;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Download Laporan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Bulan dan Tahun:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('MMMM yyyy').format(_selectedExportDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedExportDate,
                            firstDate: DateTime(DateTime.now().year - 5),
                            lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                            initialDatePickerMode: DatePickerMode.year,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              _selectedExportDate = picked;
                            });
                          }
                        },
                        child: const Text('Pilih'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Format:'),
                  RadioListTile<ExportFormat>(
                    title: const Text('CSV (.csv)'),
                    value: ExportFormat.csv,
                    groupValue: selectedFormat,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedFormat = value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  RadioListTile<ExportFormat>(
                    title: const Text('PDF (.pdf)'),
                    value: ExportFormat.pdf,
                    groupValue: selectedFormat,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedFormat = value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _downloadReport(selectedFormat);
                  },
                  child: const Text('Download'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadReport(ExportFormat format) async {
    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) {
      SnackBarHelper.showError(
          context, 'User tidak ditemukan. Silakan login kembali.');
      return;
    }

    final exportService = ref.read(exportServiceProvider);
    final result = await exportService.exportTransactions(
      userId: uid,
      date: _selectedExportDate,
      format: format,
    );

    if (mounted) {
      if (result.contains('Berhasil') || result.contains('Membuka')) {
        SnackBarHelper.showSuccess(context, result);
      } else {
        SnackBarHelper.showError(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return ref.watch(transactionStreamProvider(uid)).when(
          data: (transactions) {
            // Filter transactions by date range
            DateTime now = DateTime.now();
            final startOfWeek =
                DateTime(now.year, now.month, now.day - (now.weekday - 1));
            DateTime startOfMonth = DateTime(now.year, now.month, 1);

            // Calculate totals
            num totalIncomeWeek = transactions
                .where((transaction) =>
                    (transaction.date.isAtSameMomentAs(startOfWeek) ||
                        transaction.date.isAfter(startOfWeek)) &&
                    transaction.categoryType == 'Income')
                .fold(0, (sum, transaction) => sum + transaction.amount);

            num totalExpenseWeek = transactions
                .where((transaction) =>
                    (transaction.date.isAtSameMomentAs(startOfWeek) ||
                        transaction.date.isAfter(startOfWeek)) &&
                    transaction.categoryType == 'Expense')
                .fold(0, (sum, transaction) => sum + transaction.amount);

            num totalIncomeMonth = transactions
                .where((transaction) =>
                    (transaction.date.isAtSameMomentAs(startOfMonth) ||
                        transaction.date.isAfter(startOfMonth)) &&
                    transaction.categoryType == 'Income')
                .fold(0, (sum, transaction) => sum + transaction.amount);

            num totalExpenseMonth = transactions
                .where((transaction) =>
                    (transaction.date.isAtSameMomentAs(startOfMonth) ||
                        transaction.date.isAfter(startOfMonth)) &&
                    transaction.categoryType == 'Expense')
                .fold(0, (sum, transaction) => sum + transaction.amount);

            return _buildReportCard(
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

  Widget _buildReportCard({
    required num totalIncomeWeek,
    required num totalExpenseWeek,
    required num totalIncomeMonth,
    required num totalExpenseMonth,
  }) {
    final theme = Theme.of(context);
    final totalIncome = isWeekly ? totalIncomeWeek : totalIncomeMonth;
    final totalExpense = isWeekly ? totalExpenseWeek : totalExpenseMonth;

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, size: 20),
                      tooltip: 'Download Report',
                      onPressed: () => _showDownloadDialog(context),
                    ),
                    TextButton(
                      onPressed: () => context.push('/report-transactions'),
                      child: const Text('See Details'),
                    ),
                  ],
                ),
              ],
            ),
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
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        isWeekly
                            ? theme.colorScheme.primary.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.2),
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        isWeekly
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
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
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        !isWeekly
                            ? theme.colorScheme.primary.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.2),
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        !isWeekly
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    child: const Text('Month'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bar Chart
            SizedBox(
              height: 200,
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
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipMargin: 0,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = group.x == 0 ? 'Income' : 'Expense';
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
