// transaction_service_providers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_transaction_model.dart';

/// **Transaction Stream Provider**
final transactionStreamProvider =
    StreamProvider.family<List<UserTransaction>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users/$uid/transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserTransaction.fromFirestore(data, doc.id);
    }).toList();
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
    required String categoryName,
    required String categoryType,
    required double amount,
    required String description,
    required DateTime date,
    required String walletId,
    required String walletName,
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
      final currentBalance = walletDoc.data()!['balance'] as double;
      final updatedBalance = _calculateNewBalance(
        currentBalance: currentBalance,
        amount: amount,
        categoryType: categoryType,
        isNewTransaction: true,
      );

      // Create new transaction document
      final transactionRef =
          _firestore.collection('users/$uid/transactions').doc();
      final newTransaction = UserTransaction(
        id: transactionRef.id,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryType: categoryType,
        description: description,
        amount: amount,
        date: date,
        walletId: walletId,
        walletName: walletName,
        imagePath: imagePath,
      );

      // Perform updates atomically
      transaction.set(transactionRef, newTransaction.toMap());
      transaction.update(walletRef, {'balance': updatedBalance});
    });
  }

  /// Update existing transaction and recalculate wallet balance
  Future<void> updateTransaction({
    required String uid,
    required String transactionId,
    required UserTransaction oldTransaction,
    required String categoryId,
    required String categoryName,
    required String categoryType,
    required double amount,
    required String description,
    required DateTime date,
    required String walletId,
    required String walletName,
    String? imagePath,
  }) async {
    final oldWalletRef = _firestore
        .collection('users/$uid/wallets')
        .doc(oldTransaction.walletId);
    final newWalletRef =
        _firestore.collection('users/$uid/wallets').doc(walletId);
    final transactionRef =
        _firestore.collection('users/$uid/transactions').doc(transactionId);

    return _firestore.runTransaction((transaction) async {
      // Get wallet data
      final oldWalletDoc = await transaction.get(oldWalletRef);
      if (!oldWalletDoc.exists) {
        throw Exception('Old wallet not found');
      }

      double oldWalletBalance = oldWalletDoc.data()!['balance'] as double;
      double newWalletBalance = oldWalletBalance;

      // Handle wallet change
      if (walletId != oldTransaction.walletId) {
        final newWalletDoc = await transaction.get(newWalletRef);
        if (!newWalletDoc.exists) {
          throw Exception('New wallet not found');
        }
        newWalletBalance = newWalletDoc.data()!['balance'] as double;

        // Revert old wallet balance
        oldWalletBalance = _calculateNewBalance(
          currentBalance: oldWalletBalance,
          amount: oldTransaction.amount,
          categoryType: oldTransaction.categoryType,
          isNewTransaction: false,
        );

        // Update new wallet balance
        newWalletBalance = _calculateNewBalance(
          currentBalance: newWalletBalance,
          amount: amount,
          categoryType: categoryType,
          isNewTransaction: true,
        );

        transaction.update(oldWalletRef, {'balance': oldWalletBalance});
        transaction.update(newWalletRef, {'balance': newWalletBalance});
      } else {
        // Update balance for same wallet
        final balanceAdjustment = amount - oldTransaction.amount;
        oldWalletBalance = _calculateNewBalance(
          currentBalance: oldWalletBalance,
          amount: balanceAdjustment,
          categoryType: categoryType,
          isNewTransaction: true,
        );
        transaction.update(oldWalletRef, {'balance': oldWalletBalance});
      }

      // Update transaction
      final updatedTransaction = {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryType': categoryType,
        'description': description,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'walletId': walletId,
        'walletName': walletName,
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
      final currentBalance = walletDoc.data()!['balance'] as double;
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
  double _calculateNewBalance({
    required double currentBalance,
    required double amount,
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
