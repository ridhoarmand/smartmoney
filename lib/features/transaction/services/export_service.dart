import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smartmoney/core/providers/firebase_provider.dart';
import 'package:smartmoney/features/transaction/models/transaction.dart'
    as model;
import 'package:open_file/open_file.dart';

enum ExportFormat { csv, pdf }

final exportServiceProvider = Provider((ref) => ExportService(ref));

class ExportService {
  final Ref _ref;
  ExportService(this._ref);

  FirebaseFirestore get _firestore => _ref.read(firebaseFirestoreProvider);

  Future<String> exportTransactions({
    required String userId,
    required DateTime date,
    required ExportFormat format,
  }) async {
    try {
      final transactions = await _fetchTransactions(userId, date);
      if (transactions.isEmpty) {
        return 'Tidak ada data transaksi untuk diexport pada bulan ini.';
      }

      if (format == ExportFormat.csv) {
        return await _createCsv(transactions, date);
      } else {
        return await _createPdf(transactions, date);
      }
    } catch (e) {
      return 'Gagal export data: $e';
    }
  }

  Future<List<model.Transaction>> _fetchTransactions(
      String userId, DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => model.Transaction.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<String> _createCsv(
      List<model.Transaction> transactions, DateTime date) async {
    // Header
    List<List<dynamic>> rows = [
      ['Tanggal', 'Tipe', 'Kategori', 'Nominal', 'Deskripsi', 'Dompet']
    ];

    // Data
    for (final tx in transactions) {
      rows.add([
        DateFormat('dd-MM-yyyy').format(tx.date),
        tx.type.name,
        tx.category.name,
        tx.amount,
        tx.description,
        tx.walletName,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final monthYear = DateFormat('MMMM-yyyy').format(date);
    final filePath = '${directory.path}/SmartMoney_History_$monthYear.csv';
    final file = File(filePath);

    await file.writeAsString(csvData);

    await OpenFile.open(filePath);

    return 'Berhasil! File disimpan di: $filePath';
  }

  Future<String> _createPdf(
      List<model.Transaction> transactions, DateTime date) async {
    final pdf = pw.Document();
    final monthYear = DateFormat('MMMM yyyy').format(date);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Header(
          level: 0,
          child: pw.Text('History Transaksi - $monthYear',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headers: [
              'Tanggal',
              'Tipe',
              'Kategori',
              'Nominal',
              'Deskripsi',
              'Dompet'
            ],
            data: transactions
                .map((tx) => [
                      DateFormat('dd-MM-yyyy').format(tx.date),
                      tx.type.name,
                      tx.category.name,
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                          .format(tx.amount),
                      tx.description,
                      tx.walletName,
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());

    return 'Membuka pratinjau cetak PDF...';
  }
}
