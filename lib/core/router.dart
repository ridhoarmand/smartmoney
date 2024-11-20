import 'package:go_router/go_router.dart';
import '../features/auth/views/forgot_password_screen.dart';
import '../features/auth/views/signin_screen.dart';
import '../features/auth/views/signup_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/profile/views/darkmode_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/wallet/views/wallet_screen.dart';

class AppRouter {
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
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/darkmode',
              builder: (context, state) => const DarkModeScreen(),
            ),
            GoRoute(
              path: '/wallets',
              builder: (context, state) {
                final uid = state.extra as String;
                return WalletScreen(uid: uid);
              },
            ),
          ],
        );
}
