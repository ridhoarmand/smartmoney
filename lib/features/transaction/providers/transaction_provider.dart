import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../services/transaction_service.dart';

// Service Provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final repository = ref.read(transactionRepositoryProvider);
  return TransactionService(repository);
});

// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// FutureProvider untuk mengambil transaksi berdasarkan UID
final transactionListProvider =
    FutureProvider.family<List<UserTransaction>, String>((ref, uid) async {
  final transactionService = ref.read(transactionServiceProvider);
  return await transactionService.fetchTransactions(uid);
});
