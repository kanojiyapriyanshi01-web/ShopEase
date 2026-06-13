// lib/main.dart
import 'screens/home/profile_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_providers.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/product_detail_screen.dart';
import 'screens/category_products_screen.dart';
import 'screens/home/search_screen.dart';
import 'screens/home/orders_screen.dart';
import 'screens/home/cart_screen.dart';
import 'screens/home/wishlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51Th4pcAs3vwmTxsxeGY6XXrZ3ceUcgqGwDoN5UX4cGQuLHbjVWXdDwAB8q92Fq87ZtWAvWxoMn4luEDVw2TQwWmG00UoMPzZre';
  await Stripe.instance.applySettings();
  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'ShopEase',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.register: (_) => const RegisterScreen(),
            AppRoutes.main: (_) => const MainShell(),
            AppRoutes.productDetail: (_) => const ProductDetailScreen(),
            AppRoutes.categoryProducts: (_) => const CategoryProductsScreen(),
            AppRoutes.search: (_) => const SearchScreen(),
            AppRoutes.orders: (_) => const OrdersScreen(),
            AppRoutes.cart: (_) => const CartScreen(),
            AppRoutes.wishlist: (_) => const WishlistScreen(),
            AppRoutes.profile: (_) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}


