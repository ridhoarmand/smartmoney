import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartmoney/features/profile/view/profile_screen.dart';
import 'package:smartmoney/features/transaction/view/transaction_screen.dart';

import '../../product/view/product_screen.dart';
import '../provider/bottom_navbar_provider.dart';

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

    // Daftar menu yang berisi appBar, body, dan BottomNavigationBarItem setiap halaman
    final List<MenuItem> menus = [
      MenuItem(
        appBar: null,
        body: ProductScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Product',
        ),
      ),
      MenuItem(
        appBar: null,
        body: const TransactionScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Transaction',
        ),
      ),
      MenuItem(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const BodyProfileScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ),
    ];

    return Scaffold(
      appBar: menus[currentIndex].appBar, // Menampilkan appBar sesuai index
      body: menus[currentIndex].body, // Menampilkan body sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        items: menus.map((menu) => menu.bottomNavigationBarItem).toList(),
      ),
    );
  }
}
