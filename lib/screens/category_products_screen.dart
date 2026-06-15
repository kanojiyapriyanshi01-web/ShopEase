// lib/screens/category_products_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final category = args['category'] as String;
    final products = args['products'] as List<Product>;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(category, style: TextStyle(color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: products.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox_outlined, size: 60,
                  color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
              const SizedBox(height: 12),
              Text('No products found',
                  style: TextStyle(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey,
                      fontSize: 16)),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10,
                mainAxisSpacing: 10, childAspectRatio: 0.62),
              itemCount: products.length,
              itemBuilder: (ctx, i) => ProductCard(product: products[i]),
            ),
    );
  }
}