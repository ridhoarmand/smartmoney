// ignore_for_file: unused_import
import 'package:flutter/material.dart';
// ignore: duplicate_ignore
// ignore: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../category/models/category.dart';
import '../../category/service_providers/category_service_provider.dart';
import '../../category/views/category_form_screen.dart';

class TransactionFilterScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilter;

  const TransactionFilterScreen({super.key, required this.onApplyFilter});

  @override
  _TransactionFilterScreenState createState() =>
      _TransactionFilterScreenState();
}

class _TransactionFilterScreenState extends State<TransactionFilterScreen> {
  String _selectedTimeRange = '7 Hari Terakhir';
  String _selectedTransactionType = 'Semua Transaksi';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedMonth;

  // List bulan untuk dropdown
  final List<String> _months = [
    'Januari 2024',
    'Februari 2024',
    'Maret 2024',
    'April 2024',
    'Mei 2024',
    'Juni 2024',
    'Juli 2024',
    'Agustus 2024',
    'September 2024',
    'Oktober 2024',
    'November 2024',
    'Desember 2024'
  ];

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedTimeRange = 'Pilih Tanggal';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tranasaksi'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pilihan Rentang Waktu
            ListTile(
              title: const Text('Hari Ini'),
              trailing: Radio<String>(
                value: 'Hari Ini',
                groupValue: _selectedTimeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                    _startDate = null;
                    _endDate = null;
                    _selectedMonth = null;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('7 Hari Terakhir'),
              trailing: Radio<String>(
                value: '7 Hari Terakhir',
                groupValue: _selectedTimeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                    _startDate = null;
                    _endDate = null;
                    _selectedMonth = null;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Pilih Bulan'),
              trailing: Radio<String>(
                value: 'Pilih Bulan',
                groupValue: _selectedTimeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                    _startDate = null;
                    _endDate = null;
                  });
                },
              ),
            ),
            if (_selectedTimeRange == 'Pilih Bulan')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedMonth,
                  hint: const Text('Pilih Bulan'),
                  items: _months
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                ),
              ),
            ListTile(
              title: const Text('Pilih Tanggal'),
              trailing: Radio<String>(
                value: 'Pilih Tanggal',
                groupValue: _selectedTimeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                    _selectedMonth = null;
                  });
                },
              ),
            ),
            if (_selectedTimeRange == 'Pilih Tanggal')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _selectDateRange,
                        child: Text(
                          _startDate != null && _endDate != null
                              ? '${_startDate!.day} ${_months[_startDate!.month - 1]} ${_startDate!.year} - ${_endDate!.day} ${_months[_endDate!.month - 1]} ${_endDate!.year}'
                              : 'Pilih Tanggal',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(),

            // Pilihan Jenis Transaksi
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jenis Transaksi', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selectedTransactionType,
                    items: const [
                      DropdownMenuItem(
                        value: 'Semua Transaksi',
                        child: Text('Semua Transaksi'),
                      ),
                      DropdownMenuItem(
                        value: 'Pemasukan',
                        child: Text('Pemasukan'),
                      ),
                      DropdownMenuItem(
                        value: 'Pengeluaran',
                        child: Text('Pengeluaran'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTransactionType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Tombol Terapkan
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilter({
                    'timeRange': _selectedTimeRange,
                    'transactionType': _selectedTransactionType,
                    'startDate': _startDate?.toIso8601String(),
                    'endDate': _endDate?.toIso8601String(),
                    'selectedMonth': _selectedMonth,
                  });
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
