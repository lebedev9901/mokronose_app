import 'package:flutter/material.dart';
import 'package:mokronose_app/profile_screen.dart';
import 'main.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';

class MainShell extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainShell({
    super.key,
    this.onLogout,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onLogout: widget.onLogout),
      const CatalogScreen(),
      const CartScreen(),
      ProfileScreen(onLogout: widget.onLogout ?? () {}),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.shop_2_outlined),
            selectedIcon: Icon(Icons.shop_2_rounded),
            label: 'Каталог',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}