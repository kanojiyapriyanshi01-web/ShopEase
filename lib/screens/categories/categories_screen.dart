// lib/screens/categories/categories_screen.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<Map<String, String>> _cats = [
    {
      'label': 'All Categories',
      'image': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=300',
    },
    {
      'label': 'Sarees',
      'image': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=300',
    },
    {
      'label': 'Women Fashion',
      'image': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=300',
    },
    {
      'label': 'Men Fashion',
      'image': 'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=300',
    },
    {
      'label': 'Kids',
      'image': 'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=300',
    },
    {
      'label': 'Beauty',
      'image': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=300',
    },
    {
      'label': 'Jewellery',
      'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=300',
    },
    {
      'label': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300',
    },
    {
      'label': 'Home & Kitchen',
      'image': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300',
    },
    {
      'label': 'Bags',
      'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300',
    },
    {
      'label': 'Accessories',
      'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=300',
    },
    {
      'label': 'Footwear',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
    },
    {
      'label': 'Skincare',
      'image': 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=300',
    },
    {
      'label': 'Makeup',
      'image': 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=300',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: _cats.length,
        itemBuilder: (ctx, i) {
          final cat = _cats[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.categoryProducts,
              arguments: {
                'category': cat['label']!,
                'products': SampleData.getByCategory(cat['label']!),
              },
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image section
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                      child: Image.network(
                        cat['image']!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.category_rounded,
                              color: Colors.grey, size: 32),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Label section
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(14)),
                      ),
                      child: Text(
                        cat['label']!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}