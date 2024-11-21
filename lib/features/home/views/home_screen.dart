import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartmoney/features/category/views/category_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../transaction/views/transaction_screen.dart';
import '../../product/view/product_screen.dart';
import '../providers/bottom_navbar_provider.dart';

class MenuItem {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final BottomNavigationBarItem bottomNavigationBarItem;

  MenuItem({
    required this.appBar,
    required this.body,
    required this.bottomNavigationBarItem,
  });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<MenuItem> menus = [
      MenuItem(
        appBar: null,
        body: ProductScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
      ),
      MenuItem(
        appBar: null,
        body: const TransactionScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactions',
        ),
      ),
      MenuItem(
        appBar: null,
        body: const Scaffold(),
        bottomNavigationBarItem: BottomNavigationBarItem(
          icon: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          label: '',
        ),
      ),
      MenuItem(
        appBar: null,
        body: const CategoryScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: 'Categories',
        ),
      ),
      MenuItem(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const BodyProfileScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ),
    ];

    return Scaffold(
      appBar: menus[currentIndex].appBar,
      body: menus[currentIndex].body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            print('Add new item');
          } else {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          }
        },
        items: menus.map((menu) => menu.bottomNavigationBarItem).toList(),
      ),
    );
  }
}
