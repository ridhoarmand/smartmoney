import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet.dart';

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

  Future<void> deleteWallet(String uid, String id) async {
    await _firestore.collection('users/$uid/wallets').doc(id).delete();
    await fetchWallets(uid);
  }
}
