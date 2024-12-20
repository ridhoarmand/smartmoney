import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet.dart';

final walletProvider =
    StateNotifierProvider<WalletNotifier, List<Wallet>>((ref) {
  return WalletNotifier();
});

class WalletNotifier extends StateNotifier<List<Wallet>> {
  WalletNotifier() : super([]);

  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchWallets(String uid) async {
    final snapshot = await _firestore.collection('users/$uid/wallets').get();
    state =
        snapshot.docs.map((doc) => Wallet.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> addOrUpdateWallet(String uid, Wallet wallet) async {
    if (wallet.id.isEmpty) {
      await _firestore.collection('users/$uid/wallets').add(wallet.toMap());
    } else {
      await _firestore
          .collection('users/$uid/wallets')
          .doc(wallet.id)
          .update(wallet.toMap());
    }
    await fetchWallets(uid);
  }

  Future<bool> isWalletUsedInTransactions(String uid, String walletId) async {
    final transactionsSnapshot = await _firestore
        .collection('users/$uid/transactions')
        .where('walletId', isEqualTo: walletId)
        .limit(1)
        .get();

    return transactionsSnapshot.docs.isNotEmpty;
  }

  Future<bool> deleteWallet(String uid, String id) async {
    final isUsed = await isWalletUsedInTransactions(uid, id);

    if (isUsed) {
      return false;
    }

    await _firestore.collection('users/$uid/wallets').doc(id).delete();
    await fetchWallets(uid);
    return true;
  }
}

// PROVIDER untuk mengambil stream Wallet berdasarkan UID pengguna
final walletStreamProvider =
    StreamProvider.family<List<Wallet>, String>((ref, uid) {
  final firestore = FirebaseFirestore.instance;

  return firestore.collection('users/$uid/wallets').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Wallet.fromFirestore(
          doc.data()..['id'] = doc.id); // Add 'id' from document ID
    }).toList();
  });
});

// Provider untuk menyimpan wallet yang dipilih
final selectedWalletProvider = StateProvider<String>((ref) => 'All Wallets');

// Provider untuk stream wallet
final walletsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users/$uid/wallets')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] as String,
                'balance': doc.data()['balance'] as num,
              })
          .toList());
});
