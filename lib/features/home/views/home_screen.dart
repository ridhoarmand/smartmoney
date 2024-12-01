import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../account/views/account_screen.dart';
import '../../category/views/category_screen.dart';
import '../../transaction/views/transaction_screen.dart';
import '../../dashboard/views/dashboard_screen.dart';
import '../providers/bottom_navbar_provider.dart';

class MenuItem {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final BottomNavigationBarItem bottomNavigationBarItem;
  final String route;

  MenuItem({
    required this.appBar,
    required this.body,
    required this.bottomNavigationBarItem,
    required this.route,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<MenuItem> menus = [
    MenuItem(
      appBar: null,
      body: const DashboardScreen(),
      route: '/dashboard',
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Dashboard',
      ),
    ),
    MenuItem(
      appBar: null,
      body: const TransactionScreen(),
      route: '/transactions',
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.receipt),
        label: 'Transactions',
      ),
    ),
    MenuItem(
      appBar: null,
      body: const SizedBox.shrink(),
      route: '/add-transaction',
      bottomNavigationBarItem: BottomNavigationBarItem(
        icon: Builder(
          builder: (context) =>
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
        ),
        label: '',
      ),
    ),
    MenuItem(
      appBar: null,
      body: const CategoryScreen(),
      route: '/categories',
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.pie_chart),
        label: 'Categories',
      ),
    ),
    MenuItem(
      appBar: const AppbarAccountScreen(),
      body: const BodyAccountScreen(),
      route: '/account',
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Account',
      ),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      _updateIndexBasedOnRoute();
    });
  }

  void _updateIndexBasedOnRoute() {
    if (!mounted) return;

    final location = GoRouterState
        .of(context)
        .uri
        .toString();
    final index = menus.indexWhere((menu) => menu.route == location);
    if (index != -1 && index != ref.read(bottomNavIndexProvider)) {
      ref
          .read(bottomNavIndexProvider.notifier)
          .state = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      appBar: menus[currentIndex].appBar,
      body: menus[currentIndex].body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.push('/add-transaction');
          } else {
            ref
                .read(bottomNavIndexProvider.notifier)
                .state = index;
            context.go(menus[index].route);
          }
        },
        items: menus.map((menu) => menu.bottomNavigationBarItem).toList(),
      ),
    );
  }
}
