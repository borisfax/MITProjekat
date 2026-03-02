import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class ShopShell extends StatefulWidget {
  const ShopShell({Key? key}) : super(key: key);

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ShopScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
