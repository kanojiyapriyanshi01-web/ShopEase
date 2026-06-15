// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import 'product_image.dart';

// Gradient list for product cards
final List<List<Color>> _cardGradients = [
  [const Color(0xFFE91E8C), const Color(0xFFFF6B6B), const Color(0xFFFFB347)],
  [const Color(0xFF1565C0), const Color(0xFF42A5F5), const Color(0xFF00BCD4)],
  [const Color(0xFF6A1B9A), const Color(0xFFCE93D8), const Color(0xFFFF80AB)],
  [const Color(0xFF2E7D32), const Color(0xFF81C784), const Color(0xFFFFD54F)],
  [const Color(0xFFE65100), const Color(0xFFFF8A65), const Color(0xFFFFB347)],
  [const Color(0xFF00838F), const Color(0xFF4DD0E1), const Color(0xFF80CBC4)],
  [const Color(0xFF4527A0), const Color(0xFF9575CD), const Color(0xFFCE93D8)],
  [const Color(0xFFC62828), const Color(0xFFEF5350), const Color(0xFFFF8A80)],
];

List<Color> _getGradient(String productId) {
  int hash = productId.codeUnits.fold(0, (a, b) => a + b);
  return _cardGradients[hash % _cardGradients.length];
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.watch<CartProvider>();
    final isWishlisted = wishlist.isWishlisted(product.id);
    final inCart = cart.isInCart(product.id);
    final gradColors = _getGradient(product.id);

    return GestureDetector(
      onTap: onTap ??
          () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: ProductImage(
                    imageUrl: product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () => wishlist.toggleWishlist(product),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.grey, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  top: 6, left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [gradColors[0], gradColors[1]]),
                      borderRadius: BorderRadius.circular(4)),
                    child: Text('${product.discount.toInt()}% off',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),

              // Info
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('₹${product.price.toInt()}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppTheme.primary)),
                    const SizedBox(width: 6),
                    Text('₹${product.originalPrice.toInt()}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textGrey,
                            decoration: TextDecoration.lineThrough)),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('${product.rating} (${product.reviewCount})',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: inCart
                            ? const LinearGradient(colors: [Colors.green, Color(0xFF66BB6A)])
                            : LinearGradient(colors: [gradColors[0], gradColors[1]]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () => cart.addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(inCart ? '✓ Added' : 'Add to Cart',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCardHorizontal extends StatelessWidget {
  final Product product;
  const ProductCardHorizontal({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 150, child: ProductCard(product: product, width: 150));
  }
}