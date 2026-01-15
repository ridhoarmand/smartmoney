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
    // Safely parse TransactionType
    TransactionType parsedType;
    try {
      final typeStr = (data['type'] ?? data['categoryType'] ?? 'expense')
          .toString()
          .toLowerCase();
      parsedType = TransactionType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr,
        orElse: () => TransactionType.expense,
      );
    } catch (_) {
      parsedType = TransactionType.expense;
    }

    // Safely parse CategoryType
    CategoryType parsedCategory;
    try {
      final categoryStr = (data['category'] ?? data['categoryName'] ?? 'other')
          .toString()
          .toLowerCase();
      parsedCategory = CategoryType.values.firstWhere(
        (e) => e.name.toLowerCase() == categoryStr,
        orElse: () => CategoryType.other,
      );
    } catch (_) {
      parsedCategory = CategoryType.other;
    }

    return Transaction(
      id: documentId,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      description: data['description']?.toString() ?? '',
      type: parsedType,
      category: parsedCategory,
      walletId: data['walletId']?.toString() ?? '',
      walletName: data['walletName']?.toString() ?? '',
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
