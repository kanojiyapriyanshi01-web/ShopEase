import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'home/search_screen.dart';
import 'home/cart_screen.dart';
import 'home/profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final cart = context.watch<CartProvider>();

    final screens = [
      const HomeScreen(),
      CategoriesScreen(),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: nav.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.currentIndex,
        onDestinationSelected: nav.setIndex,
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded, color: AppTheme.primary),
            label: 'Categories',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded, color: AppTheme.primary),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Badge(
              label: cart.itemCount > 0 ? Text('${cart.itemCount}') : null,
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: cart.itemCount > 0 ? Text('${cart.itemCount}') : null,
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart_rounded, color: AppTheme.primary),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}