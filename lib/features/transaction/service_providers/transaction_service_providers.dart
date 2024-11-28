// transaction_service_providers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_transaction_model.dart';

/// **Transaction Stream Provider**
final transactionStreamProvider =
    StreamProvider.family<List<UserTransaction>, String>((ref, uid) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users/$uid/transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    // Jika tidak ada dokumen, kembalikan list kosong
    if (snapshot.docs.isEmpty) {
      return <UserTransaction>[];
    }

    try {
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserTransaction.fromFirestore(data, doc.id);
      }).toList();

      // Jika tidak ada transaksi, kembalikan list kosong
      if (transactions.isEmpty) {
        return <UserTransaction>[];
      }

      // Ambil wallet dan kategori secara paralel
      final walletIds = transactions.map((e) => e.walletId).toSet();
      final categoryIds = transactions.map((e) => e.categoryId).toSet();

      final walletsFuture = firestore
          .collection('users/$uid/wallets')
          .where(FieldPath.documentId, whereIn: walletIds.toList())
          .get();

      final categoriesFuture = firestore
          .collection('users/$uid/categories')
          .where(FieldPath.documentId, whereIn: categoryIds.toList())
          .get();

      // Tunggu semua dokumen diambil
      final results = await Future.wait([walletsFuture, categoriesFuture]);

      // Buat map dari dokumen yang diambil
      final walletDocs = results[0].docs;
      final categoryDocs = results[1].docs;

      final walletMap = {
        for (var doc in walletDocs) doc.id: doc.data(),
      };

      final categoryMap = {
        for (var doc in categoryDocs) doc.id: doc.data(),
      };

      // Perbarui data transaksi dengan informasi tambahan
      return transactions.map((transaction) {
        final walletData = walletMap[transaction.walletId];
        final categoryData = categoryMap[transaction.categoryId];

        return UserTransaction(
          id: transaction.id,
          categoryId: transaction.categoryId,
          categoryName: categoryData?['name'] ?? 'Unknown Category',
          categoryType: categoryData?['type'] ?? 'Unknown Type',
          description: transaction.description,
          amount: transaction.amount,
          date: transaction.date,
          walletId: transaction.walletId,
          walletName: walletData?['name'] ?? 'Unknown Wallet',
          imagePath: transaction.imagePath,
        );
      }).toList();
    } catch (e) {
      // Tangani kesalahan dengan mengembalikan list kosong
      return <UserTransaction>[];
    }
  });
});

/// **Transaction Service Provider**
final transactionServiceProvider = Provider((ref) => TransactionService());

class TransactionService {
  final _firestore = FirebaseFirestore.instance;

  /// Create new transaction and update wallet balance
  Future<void> createTransaction({
    required String uid,
    required String categoryId,
    required String categoryType,
    required num amount,
    required String description,
    required DateTime date,
    required String walletId,
    String? imagePath,
  }) async {
    final walletRef = _firestore.collection('users/$uid/wallets').doc(walletId);

    return _firestore.runTransaction((transaction) async {
      // Get current wallet balance
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception('Selected wallet not found');
      }

      // Calculate new balance
      final currentBalance = walletDoc.data()!['balance'] as num;
      final updatedBalance = _calculateNewBalance(
        currentBalance: currentBalance,
        amount: amount,
        categoryType: categoryType,
        isNewTransaction: true,
      );

      // Create new transaction document
      final transactionRef =
          _firestore.collection('users/$uid/transactions').doc();
      final newTransaction = {
        'id': transactionRef.id,
        'categoryId': categoryId,
        'description': description,
        'amount': amount,
        'date': date,
        'walletId': walletId,
        'imagePath': imagePath,
      };

      // Perform updates atomically
      transaction.set(transactionRef, newTransaction);
      transaction.update(walletRef, {'balance': updatedBalance});
    });
  }

  /// Update existing transaction and recalculate wallet balance
  Future<void> updateTransaction({
    required String uid,
    required String transactionId,
    required UserTransaction oldTransaction,
    required String categoryId,
    required String categoryType,
    required num amount,
    required String description,
    required DateTime date,
    required String walletId,
    String? imagePath,
  }) async {
    final oldWalletRef = _firestore
        .collection('users/$uid/wallets')
        .doc(oldTransaction.walletId);
    final newWalletRef =
        _firestore.collection('users/$uid/wallets').doc(walletId);
    final transactionRef =
        _firestore.collection('users/$uid/transactions').doc(transactionId);
    final categoryRef = _firestore
        .collection('users/$uid/categories')
        .doc(categoryId); // Perbaiki path kategori

    return _firestore.runTransaction((transaction) async {
      // Get category data
      final categoryDoc = await transaction.get(categoryRef);
      if (!categoryDoc.exists) {
        throw Exception('Category not found');
      }
      final String newCategoryType = categoryDoc.data()!['type'] as String;

      // Get wallet data
      final oldWalletDoc = await transaction.get(oldWalletRef);
      if (!oldWalletDoc.exists) {
        throw Exception('Old wallet not found');
      }

      num oldWalletBalance = oldWalletDoc.data()!['balance'] as num;
      num newWalletBalance = oldWalletBalance;

      // Handle category type change
      if (oldTransaction.categoryType != newCategoryType) {
        // First, revert the old transaction completely
        oldWalletBalance = _calculateNewBalance(
          currentBalance: oldWalletBalance,
          amount: oldTransaction.amount,
          categoryType: oldTransaction.categoryType,
          isNewTransaction: false,
        );

        // Then apply the new transaction with new category type
        oldWalletBalance = _calculateNewBalance(
          currentBalance: oldWalletBalance,
          amount: amount,
          categoryType: newCategoryType,
          isNewTransaction: true,
        );

        if (walletId == oldTransaction.walletId) {
          // Update balance for same wallet
          transaction.update(oldWalletRef, {'balance': oldWalletBalance});
        }
      }

      // Handle wallet change
      if (walletId != oldTransaction.walletId) {
        final newWalletDoc = await transaction.get(newWalletRef);
        if (!newWalletDoc.exists) {
          throw Exception('New wallet not found');
        }
        newWalletBalance = newWalletDoc.data()!['balance'] as num;

        if (oldTransaction.categoryType == newCategoryType) {
          // Revert old wallet balance only if category type hasn't changed
          oldWalletBalance = _calculateNewBalance(
            currentBalance: oldWalletBalance,
            amount: oldTransaction.amount,
            categoryType: oldTransaction.categoryType,
            isNewTransaction: false,
          );
        }

        // Update new wallet balance
        newWalletBalance = _calculateNewBalance(
          currentBalance: newWalletBalance,
          amount: amount,
          categoryType: newCategoryType,
          isNewTransaction: true,
        );

        transaction.update(oldWalletRef, {'balance': oldWalletBalance});
        transaction.update(newWalletRef, {'balance': newWalletBalance});
      } else if (oldTransaction.categoryType == newCategoryType) {
        // Update balance for same wallet and same category type
        final balanceAdjustment = amount - oldTransaction.amount;
        oldWalletBalance = _calculateNewBalance(
          currentBalance: oldWalletBalance,
          amount: balanceAdjustment,
          categoryType: newCategoryType,
          isNewTransaction: true,
        );
        transaction.update(oldWalletRef, {'balance': oldWalletBalance});
      }

      // Update transaction
      final updatedTransaction = {
        'categoryId': categoryId,
        'description': description,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'walletId': walletId,
        'imagePath': imagePath,
      };

      transaction.update(transactionRef, updatedTransaction);
    });
  }

  /// Delete transaction and update wallet balance
  Future<void> deleteTransaction({
    required String uid,
    required String transactionId,
    required UserTransaction transaction,
  }) async {
    final walletRef =
        _firestore.collection('users/$uid/wallets').doc(transaction.walletId);
    final transactionRef =
        _firestore.collection('users/$uid/transactions').doc(transactionId);

    return _firestore.runTransaction((txn) async {
      // Get current wallet balance
      final walletDoc = await txn.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception('Wallet not found');
      }

      // Calculate updated balance
      final currentBalance = walletDoc.data()!['balance'] as num;
      final updatedBalance = _calculateNewBalance(
        currentBalance: currentBalance,
        amount: transaction.amount,
        categoryType: transaction.categoryType,
        isNewTransaction: false,
      );

      // Perform updates atomically
      txn.delete(transactionRef);
      txn.update(walletRef, {'balance': updatedBalance});
    });
  }

  /// Calculate new balance based on transaction type
  num _calculateNewBalance({
    required num currentBalance,
    required num amount,
    required String categoryType,
    required bool isNewTransaction,
  }) {
    if (categoryType == 'Income') {
      return isNewTransaction
          ? currentBalance + amount
          : currentBalance - amount;
    } else {
      return isNewTransaction
          ? currentBalance - amount
          : currentBalance + amount;
    }
  }
}


