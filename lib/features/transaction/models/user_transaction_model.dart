class UserTransaction {
  final String type;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;

  UserTransaction({
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
  });

  // Konversi dari Map (Firestore) ke model UserTransaction
  factory UserTransaction.fromFirestore(Map<String, dynamic> data) {
    return UserTransaction(
      type: data['type'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      description: data['description'] as String?,
      date: DateTime.parse(data['date'] as String),
    );
  }

  // Konversi dari model UserTransaction ke Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
