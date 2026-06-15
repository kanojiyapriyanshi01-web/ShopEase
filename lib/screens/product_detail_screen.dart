import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product_model.dart';
import '../providers/app_providers.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import 'home/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  int _imgIndex = 0;
  final PageController _imgCtrl = PageController();

  @override
  void dispose() { _imgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isWishlisted = wishlist.isWishlisted(product.id);
    final inCart = cart.isInCart(product.id);
    final related = SampleData.products
        .where((p) => p.category == product.category && p.id != product.id)
        .take(6).toList();
    final images = [product.imageUrl, product.imageUrl, product.imageUrl];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey;
    final divColor = isDark ? AppTheme.darkDivider : Colors.grey.shade300;
    final iconColor = isDark ? AppTheme.darkTextPrimary : AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : iconColor),
            onPressed: () => wishlist.toggleWishlist(product)),
          Stack(children: [
            IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: iconColor),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart)),
            if (cart.itemCount > 0) Positioned(right: 6, top: 6,
              child: Container(width: 14, height: 14,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: Text('${cart.itemCount}', textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9)))),
          ]),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: iconColor),
            onSelected: (value) {
              if (value == 'share') {
                SharePlus.instance.share(ShareParams(
                  text: '🛍️ Check out ${product.name} on ShopEase!\n\n'
                      '💰 Only ₹${product.price.toInt()} (${product.discount.toInt()}% OFF)\n'
                      '⭐ ${product.rating} rating\n\n'
                      '${product.description}\n\n'
                      '#ShopEase #${product.category.replaceAll(' ', '')} #Shopping',
                  subject: '${product.name} - ShopEase',
                ));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'share',
                child: Row(children: [
                  const Icon(Icons.share_outlined, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  const Text('Share Product'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Image Carousel ──
          Stack(alignment: Alignment.bottomCenter, children: [
            SizedBox(height: 320,
              child: PageView.builder(controller: _imgCtrl, itemCount: images.length,
                onPageChanged: (i) => setState(() => _imgIndex = i),
                itemBuilder: (ctx, i) => ProductImage(
                    imageUrl: images[i], width: double.infinity, height: 320, fit: BoxFit.cover))),
            Positioned(bottom: 10,
              child: Row(children: List.generate(images.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _imgIndex ? 20 : 6, height: 6,
                decoration: BoxDecoration(
                    color: i == _imgIndex ? AppTheme.primary : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3)))))),
            Positioned(top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
                child: Text('${product.discount.toInt()}% OFF',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)))),
          ]),

          // ── Product Info ──
          Container(
            color: cardColor,
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 8),
              Row(children: [
                Text('₹${product.price.toInt()}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                const SizedBox(width: 10),
                Text('₹${product.originalPrice.toInt()}',
                    style: TextStyle(fontSize: 16, color: subColor, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('${product.discount.toInt()}% off',
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                    child: Row(children: [
                      Text('${product.rating}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      const SizedBox(width: 3),
                      const Icon(Icons.star, color: Colors.white, size: 12),
                    ])),
                const SizedBox(width: 8),
                Text('${product.reviewCount} reviews', style: TextStyle(color: subColor, fontSize: 13)),
              ]),
              Divider(height: 24, color: isDark ? AppTheme.darkDivider : null),
              Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 6),
              Text(product.description, style: TextStyle(color: subColor, fontSize: 14, height: 1.5)),
              Divider(height: 24, color: isDark ? AppTheme.darkDivider : null),
              Row(children: [
                Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: divColor),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    IconButton(icon: Icon(Icons.remove, size: 18, color: textColor),
                        onPressed: () { if (_qty > 1) setState(() => _qty--); }),
                    Text('$_qty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textColor)),
                    IconButton(icon: Icon(Icons.add, size: 18, color: textColor),
                        onPressed: () => setState(() => _qty++)),
                  ])),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {
                    cart.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1), backgroundColor: Colors.green));
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(inCart ? 'In Cart' : 'Add to Cart'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    cart.addToCart(product);
                    showModalBottomSheet(context: context, isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CheckoutSheet(cart: cart));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0),
                  child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                )),
              ]),
            ]),
          ),

          // ── You may also like ──
          if (related.isNotEmpty) ...[
            Container(width: double.infinity,
                color: isDark ? AppTheme.darkSurface : const Color(0xFFF5F5F5),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('You may also like',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor))),
            SizedBox(height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: related.length,
                itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 4),
                    child: SizedBox(width: 155, child: ProductCard(product: related[i]))))),
            const SizedBox(height: 16),
          ],
        ]),
      ),
    );
  }
}