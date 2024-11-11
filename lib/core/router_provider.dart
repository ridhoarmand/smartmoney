import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';

final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = ref.watch(routerProvider);
  return router.appRouter;
});
