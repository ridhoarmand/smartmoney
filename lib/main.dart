import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router_provider.dart';
import 'core/shared_preference_provider.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'firebase_options.dart'; // Ensure this is included for initialization.

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Background message: ${message.notification?.title}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request permissions (iOS specific)
  if (!kIsWeb) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) {
      if (kDebugMode) {
        print('Token: $value');
      }
    });
    await messaging.requestPermission();

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

    // Initialize Firebase App Check for added security (you already have it in your code)
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  }

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
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            },
          ),
          builder: (context, child) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 550, // Maksimal lebar aplikasi
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: child),
                ),
              ),
            );
          },
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
