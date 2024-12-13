class ReportData {
  final List<double> incomeData;
  final List<double> expenseData;
  final int xCount;
  final String Function(int index) labelFormatter;
  final List<dynamic> filteredTransactions;

  const ReportData({
    required this.incomeData,
    required this.expenseData,
    required this.xCount,
    required this.labelFormatter,
    required this.filteredTransactions,
  });

  // Optional helper methods can be added here
  double getTotalIncome() {
    return incomeData.reduce((a, b) => a + b);
  }

  double getTotalExpense() {
    return expenseData.reduce((a, b) => a + b);
  }

  double getNetBalance() {
    return getTotalIncome() - getTotalExpense();
  }
}
