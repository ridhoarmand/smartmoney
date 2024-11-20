import '../models/user_transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;

  TransactionService(this._repository);

  Future<List<UserTransaction>> fetchTransactions(String uid) async {
    return await _repository.getTransactions(uid);
  }

  Future<void> createTransaction({
    required String uid,
    required String type,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    await _repository.addTransaction(
      uid: uid,
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: date,
    );
  }
}
