import 'package:go_router/go_router.dart';
import '../features/auth/view/signin_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/auth/view/splash.dart';
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
              path: '/login',
              builder: (context, state) => const SignInScreen(),
            ),
            GoRoute(
              path: '/signup',
              builder: (context, state) => const SignUpScreen(),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeScreen(),
            )
          ],
        );
}
