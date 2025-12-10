import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

enum CategoryType { food, transport, entertainment, other }

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType type;
  final CategoryType category;
  final String walletId;
  final String walletName;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    required this.category,
    required this.walletId,
    required this.walletName,
  });

  factory Transaction.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      type: TransactionType.values.firstWhere((e) => e.name == data['type']),
      category:
          CategoryType.values.firstWhere((e) => e.name == data['category']),
      walletId: data['walletId'] ?? '',
      walletName: data['walletName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'type': type.name,
      'category': category.name,
      'walletId': walletId,
      'walletName': walletName,
    };
  }
}
