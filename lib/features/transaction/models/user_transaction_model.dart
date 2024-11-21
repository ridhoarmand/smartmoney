import 'package:cloud_firestore/cloud_firestore.dart';

class UserTransaction {
  final String categoryId;
  final String description;
  final double amount;
  final DateTime date;
  final String walletId;
  final String? imagePath;

  UserTransaction({
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.date,
    required this.walletId,
    this.imagePath, // Image path is optional
  });

  // Firestore document -> UserTransaction
  factory UserTransaction.fromFirestore(Map<String, dynamic> data) {
    return UserTransaction(
      categoryId: data['categoryId'] ?? '',
      description: data['description'] ?? 'No Description',
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      walletId: data['walletId'] ?? 'Unknown',
      imagePath: data['imagePath'],
    );
  }

  // UserTransaction -> Firestore document
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'walletId': walletId,
      'imagePath': imagePath, // Image path can be null
    };
  }
}
