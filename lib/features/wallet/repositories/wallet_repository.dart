import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet.dart';
import '../services/wallet_service.dart';

final walletProvider =
    StateNotifierProvider<WalletNotifier, List<Wallet>>((ref) {
  return WalletNotifier();
});
