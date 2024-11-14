import 'package:go_router/go_router.dart';
import 'package:smartmoney/features/auth/view/forgot_password_screen.dart';
import 'package:smartmoney/features/profile/view/darkmode_screen.dart';
import 'package:smartmoney/features/profile/view/edit_profile_screen.dart';

import '../features/auth/view/signin_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/auth/view/splash_screen.dart';
import '../features/home/view/home_screen.dart';

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
          ],
        );
}
