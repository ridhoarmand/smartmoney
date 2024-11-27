import 'package:cloud_firestore/cloud_firestore.dart';

class UserTransaction {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final String description;
  final num amount;
  final DateTime date;
  final String walletId;
  final String walletName;
  final String? imagePath;

  UserTransaction({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.description,
    required this.amount,
    required this.date,
    required this.walletId,
    required this.walletName,
    this.imagePath,
  });

  // Firestore document -> UserTransaction
  factory UserTransaction.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return UserTransaction(
      id: docId,
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? 'Unknown Category',
      categoryType: data['categoryType'] ?? 'Unknown Type',
      description: data['description'] ?? 'No Description',
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      walletId: data['walletId'] ?? 'Unknown',
      walletName: data['walletName'] ?? 'Unknown Wallet',
      imagePath: data['imagePath'],
    );
  }

  // UserTransaction -> Firestore document
  Map<String, dynamic> toMap() {
    return {
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
  }
}
