import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_transaction_model.dart';

/// **Transaction Stream Provider**
/// Mendapatkan daftar transaksi dari Firestore dalam bentuk stream.
final transactionStreamProvider =
    StreamProvider.family<List<UserTransaction>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users/$uid/transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserTransaction.fromFirestore(data, doc.id); // Sertakan doc.id
    }).toList();
  });
});

/// **Create Transaction Provider**
/// Untuk membuat transaksi baru di Firestore.
final createTransactionProvider = Provider((ref) => CreateTransaction(ref));

class CreateTransaction {
  final Ref ref;
  CreateTransaction(this.ref);

  Future<void> createTransaction({
    required String uid,
    required String categoryId,
    required String categoryName, // Tambahkan
    required String categoryType, // Tambahkan
    required double amount,
    required String description,
    required DateTime date,
    required String type,
    required String walletId,
    required String walletName, // Tambahkan
    String? imagePath,
  }) async {
    final transaction = UserTransaction(
      id: '', // ID akan di-generate oleh Firestore
      categoryId: categoryId,
      categoryName: categoryName, // Tambahkan
      categoryType: categoryType, // Tambahkan
      description: description,
      amount: amount,
      date: date,
      walletId: walletId,
      walletName: walletName, // Tambahkan
      imagePath: imagePath,
    );

    final transactionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(); // Generate doc reference

    await transactionRef.set(transaction.toMap());
  }
}


/// **Update Transaction Provider**
/// Untuk mengupdate transaksi yang sudah ada di Firestore.
final updateTransactionProvider = Provider((ref) => UpdateTransaction(ref));

class UpdateTransaction {
  final Ref ref;
  UpdateTransaction(this.ref);

  Future<void> updateTransaction({
    required String uid,
    required String transactionId,
    required String categoryId,
    required String categoryName, // Tambahkan
    required String categoryType, // Tambahkan
    required double amount,
    required String description,
    required DateTime date,
    required String type,
    required String walletId,
    required String walletName, // Tambahkan
    String? imagePath,
  }) async {
    final transactionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId);

    final updatedData = {
      'categoryId': categoryId,
      'categoryName': categoryName, // Tambahkan
      'categoryType': categoryType, // Tambahkan
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'walletId': walletId,
      'walletName': walletName, // Tambahkan
      'imagePath': imagePath,
    };

    await transactionRef.update(updatedData);
  }
}


/// **Delete Transaction Provider**
/// Untuk menghapus transaksi dari Firestore.
final deleteTransactionProvider = Provider((ref) => DeleteTransaction(ref));

class DeleteTransaction {
  final Ref ref;
  DeleteTransaction(this.ref);

  Future<void> deleteTransaction({
    required String uid,
    required String transactionId,
  }) async {
    final transactionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId);

    await transactionRef.delete();
  }
}
