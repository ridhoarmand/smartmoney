import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_transaction_model.dart';

/// **Transaction Stream Provider**
/// Mengambil daftar transaksi dari Firestore dalam bentuk stream.
final transactionStreamProvider =
    StreamProvider.family<List<UserTransaction>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users/$uid/transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserTransaction.fromFirestore({
        ...data,
        'id': doc.id, // Tambahkan ID dokumen
      });
    }).toList();
  });
});

/// **Create Transaction Provider**
/// Untuk membuat transaksi baru dan menyimpannya di Firestore.
final createTransactionProvider = Provider((ref) => CreateTransaction(ref));

class CreateTransaction {
  final Ref ref;
  CreateTransaction(this.ref);

  Future<void> createTransaction({
    required String uid,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
    required String type,
    required String walletId,
    String? imagePath, // Optional image path
  }) async {
    final transaction = UserTransaction(
      categoryId: categoryId,
      description: description,
      amount: amount,
      date: date,
      walletId: walletId,
      imagePath: imagePath, // Image path is optional
    );

    final transactionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(); // Generate doc reference

    await transactionRef.set(transaction.toMap());
  }
}
