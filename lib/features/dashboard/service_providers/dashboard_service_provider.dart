import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/shared_preference_provider.dart';

const String balanceVisibilityKey = 'is_balance_visible';

final balanceVisibilityProvider =
    StateNotifierProvider<BalanceVisibilityNotifier, bool>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider).value;
  return BalanceVisibilityNotifier(sharedPrefs);
});

class BalanceVisibilityNotifier extends StateNotifier<bool> {
  final SharedPreferences? _prefs;

  BalanceVisibilityNotifier(this._prefs)
      : super(_prefs?.getBool(balanceVisibilityKey) ?? true);

  void toggleVisibility() {
    state = !state;
    _prefs?.setBool(balanceVisibilityKey, state);
  }
}
