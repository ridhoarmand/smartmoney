import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil semua transaksi berdasarkan UID
  Future<List<UserTransaction>> getTransactions(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(
              'transactions') // Pastikan collection 'transactions' sudah benar
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserTransaction.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Tambahkan transaksi baru
  Future<void> addTransaction({
    required String uid,
    required String type,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    try {
      final transaction = UserTransaction(
        type: type,
        amount: amount,
        category: category,
        description: description,
        date: date,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection(
              'transactions') // Pastikan collection 'transactions' sudah benar
          .add(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }
}
