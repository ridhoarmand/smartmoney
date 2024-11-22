import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../features/account/views/darkmode_screen.dart';
import '../features/account/views/edit_profile_screen.dart';
import '../features/account/views/account_screen.dart';
import '../features/auth/views/forgot_password_screen.dart';
import '../features/auth/views/signin_screen.dart';
import '../features/auth/views/signup_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/category/views/category_form_screen.dart';
import '../features/category/views/category_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/product/view/product_screen.dart';
import '../features/transaction/views/add_transaction_screen.dart';
import '../features/transaction/views/transaction_screen.dart';
import '../features/wallet/views/wallet_screen.dart';

class AppRouter {
  static void configureRouter() {
    setUrlStrategy(PathUrlStrategy());
  }

  final GoRouter appRouter;

  AppRouter()
      : appRouter = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: '/signin',
              builder: (context, state) => const SignInScreen(),
            ),
            GoRoute(
              path: '/signup',
              builder: (context, state) => const SignUpScreen(),
            ),
            GoRoute(
              path: '/forgot-password',
              builder: (context, state) => const ForgotPasswordScreen(),
            ),
            ShellRoute(
              builder: (context, state, child) {
                return const HomeScreen();
              },
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: ProductScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                ),
                GoRoute(
                  path: '/transactions',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const TransactionScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                ),
                GoRoute(
                  path: '/categories',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const CategoryScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        final uid = state.extra as String;
                        return CategoryFormScreen(uid: uid);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: '/account',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const BodyAccountScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/add-transaction',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const AddTransactionScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            ),
            GoRoute(
              path: '/account/wallets',
              builder: (context, state) {
                final uid = state.extra as String;
                return WalletScreen(uid: uid);
              },
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/setting/darkmode',
              builder: (context, state) => const DarkModeScreen(),
            ),
          ],
        );
}
