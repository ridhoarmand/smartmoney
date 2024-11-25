import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router_provider.dart';
import 'core/shared_preference_provider.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPrefs = ref.watch(sharedPreferencesProvider);

    return sharedPrefs.when(
      data: (prefs) {
        final router = ref.watch(goRouterProvider);
        final theme = ref.watch(themeProvider);

        return MaterialApp.router(
          title: 'Smart Money',
          themeMode: theme.currentTheme,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: Text('Error'),
      ),
    );
  }
}
