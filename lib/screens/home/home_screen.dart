// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/app_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  final List<_BannerData> _banners = [
    _BannerData(
      title: 'Fashion Sale',
      subtitle: 'Upto 70% Off on Sarees & Kurtis',
      color1: const Color(0xFFE91E8C),
      color2: const Color(0xFFFF6B6B),
      imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&q=80',
    ),
    _BannerData(
      title: 'Electronics Mega Deal',
      subtitle: 'Smart Gadgets Starting ₹199',
      color1: const Color(0xFF1565C0),
      color2: const Color(0xFF42A5F5),
      imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=600&q=80',
    ),
    _BannerData(
      title: 'Beauty Essentials',
      subtitle: 'Top Brands at Best Prices',
      color1: const Color(0xFF6A1B9A),
      color2: const Color(0xFFCE93D8),
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&q=80',
    ),
    _BannerData(
      title: 'Home & Kitchen Festival',
      subtitle: 'Refresh Your Home Starting ₹299',
      color1: const Color(0xFF2E7D32),
      color2: const Color(0xFF81C784),
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80',
    ),
  ];

  final List<_CategoryData> _categories = [
    _CategoryData('All\nCategories', Icons.grid_view_rounded, const Color(0xFFE3F2FD),
        'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=200'),
    _CategoryData('Sarees', Icons.woman_rounded, const Color(0xFFFCE4EC),
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200'),
    _CategoryData('Women\nFashion', Icons.woman_2_rounded, const Color(0xFFF3E5F5),
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=200'),
    _CategoryData('Men\nFashion', Icons.man_rounded, const Color(0xFFE8F5E9),
        'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=200'),
    _CategoryData('Kids', Icons.child_care_rounded, const Color(0xFFFFF8E1),
        'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=200'),
    _CategoryData('Beauty', Icons.face_rounded, const Color(0xFFFCE4EC),
        'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=200'),
    _CategoryData('Jewellery', Icons.diamond_rounded, const Color(0xFFFFF3E0),
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=200'),
    _CategoryData('Electronics', Icons.devices_rounded, const Color(0xFFE3F2FD),
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=200'),
    _CategoryData('Home &\nKitchen', Icons.kitchen_rounded, const Color(0xFFE8F5E9),
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200'),
    _CategoryData('Bags', Icons.shopping_bag_rounded, const Color(0xFFFBE9E7),
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200'),
    _CategoryData('Accessories', Icons.watch_rounded, const Color(0xFFF3E5F5),
        'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200'),
    _CategoryData('Footwear', Icons.roller_skating_rounded, const Color(0xFFE0F2F1),
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200'),
    _CategoryData('Skincare', Icons.spa_rounded, const Color(0xFFFCE4EC),
        'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200'),
    _CategoryData('Makeup', Icons.brush_rounded, const Color(0xFFFFF9C4),
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=200'),
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  String _categoryLabel(_CategoryData c) =>
      c.label.replaceAll('\n', ' ').trim();

  void _onCategoryTap(_CategoryData cat) {
    Navigator.pushNamed(
      context,
      AppRoutes.categoryProducts,
      arguments: {
        'category': _categoryLabel(cat),
        'products': SampleData.getByCategory(_categoryLabel(cat)),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    final allProducts = SampleData.products;
    final featured = allProducts.where((p) => p.isFeatured).toList();
    final popular = allProducts.where((p) => p.isPopular).toList();
    final newArrivals = allProducts.where((p) => p.isNewArrival).toList();
    final bestSellers = allProducts.where((p) => p.isBestSeller).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 1,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primary.withOpacity(0.15),
                        child: Text(
                          auth.name.isNotEmpty ? auth.name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded, color: AppTheme.textDark),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.wishlist),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.textDark),
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(Icons.search, color: Colors.grey, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Search by Keyword or Product ID',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 80, height: 80,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.mic_rounded, color: AppTheme.primary, size: 40),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Listening...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      const Text('Speak your product name', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mic_rounded, color: AppTheme.primary, size: 22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 80, height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: Colors.blue, size: 40),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Search by Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      const Text('Take a photo or upload from gallery',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(child: OutlinedButton.icon(
                                            onPressed: () => Navigator.pop(context),
                                            icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                            label: const Text('Camera'),
                                          )),
                                          const SizedBox(width: 8),
                                          Expanded(child: OutlinedButton.icon(
                                            onPressed: () => Navigator.pop(context),
                                            icon: const Icon(Icons.photo_library_outlined, size: 16),
                                            label: const Text('Gallery'),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.blue, size: 22),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            context.watch<AddressProvider>().deliveryText,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textDark),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: AppTheme.textGrey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category Row ──────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 95,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _categories.length,
                        itemBuilder: (ctx, i) {
                          final cat = _categories[i];
                          return GestureDetector(
                            onTap: () => _onCategoryTap(cat),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 68,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cat.bgColor,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        cat.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(cat.icon, color: Colors.grey.shade700, size: 26),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cat.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 9, color: AppTheme.textDark, height: 1.2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Banner Carousel ───────────────────────────────
                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      controller: _bannerCtrl,
                      itemCount: _banners.length,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      itemBuilder: (ctx, i) {
                        final b = _banners[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: [b.color1, b.color2]),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background image
                                Image.network(
                                  b.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                ),
                                // Dark gradient overlay so text is readable
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        b.color1.withOpacity(0.82),
                                        b.color2.withOpacity(0.45),
                                      ],
                                    ),
                                  ),
                                ),
                                // Text content
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'UPTO 70% OFF',
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        b.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        b.subtitle,
                                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Banner dots
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _bannerIndex ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _bannerIndex ? AppTheme.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Featured Products ─────────────────────────────
                  _sectionHeader('Featured Products', featured, context),
                  _horizontalProductList(featured),

                  // ── Popular Products ──────────────────────────────
                  _sectionHeader('Popular Products', popular, context),
                  _horizontalProductList(popular),

                  // ── New Arrivals ──────────────────────────────────
                  _sectionHeader('New Arrivals', newArrivals, context),
                  _horizontalProductList(newArrivals),

                  // ── Best Sellers ──────────────────────────────────
                  _sectionHeader('Best Sellers', bestSellers, context),
                  _horizontalProductList(bestSellers),

                  // ── All Products Grid ─────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'All Products',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: allProducts.length,
                    itemBuilder: (ctx, i) => ProductCard(product: allProducts[i]),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, List<Product> products, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.categoryProducts,
                arguments: {'category': title, 'products': products}),
            child: const Text('See all',
                style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _horizontalProductList(List<Product> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(width: 155, child: ProductCard(product: products[i])),
        ),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────
class _BannerData {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final String imageUrl;
  _BannerData({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.imageUrl,
  });
}

class _CategoryData {
  final String label;
  final IconData icon;
  final Color bgColor;
  final String imageUrl;
  _CategoryData(this.label, this.icon, this.bgColor, this.imageUrl);
}
