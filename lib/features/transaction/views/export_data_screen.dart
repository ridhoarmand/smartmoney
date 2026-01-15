import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smartmoney/core/snackbar_helper.dart';
import 'package:smartmoney/features/auth/providers/auth_provider.dart';
import 'package:smartmoney/features/transaction/services/export_service.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  DateTime _selectedDate = DateTime.now();
  ExportFormat _selectedFormat = ExportFormat.csv;

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(currentYear),
      lastDate: DateTime(currentYear + 5, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _exportData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final exportService = ref.read(exportServiceProvider);
    // Pastikan currentUser tidak null sebelum mengakses uid
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      SnackBarHelper.showError(
          context, 'User tidak ditemukan. Silakan login kembali.');
      return;
    }

    final result = await exportService.exportTransactions(
      userId: user.uid,
      date: _selectedDate,
      format: _selectedFormat,
    );

    SnackBarHelper.showSuccess(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Bulan dan Tahun', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Pilih'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Pilih Format Dokumen', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            RadioListTile<ExportFormat>(
              title: const Text('CSV (.csv)'),
              value: ExportFormat.csv,
              groupValue: _selectedFormat,
              onChanged: (ExportFormat? value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                  });
                }
              },
            ),
            RadioListTile<ExportFormat>(
              title: const Text('PDF (.pdf)'),
              value: ExportFormat.pdf,
              groupValue: _selectedFormat,
              onChanged: (ExportFormat? value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                  });
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exportData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Export Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
