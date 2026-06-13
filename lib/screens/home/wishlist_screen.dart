import '../../widgets/product_image.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../providers/app_providers.dart";
import "../../routes/app_routes.dart";
import "../../theme/app_theme.dart";

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: wishlist.items.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.favorite_border, size: 70, color: Colors.grey),
              SizedBox(height: 12),
              Text("No items in wishlist", style: TextStyle(fontSize: 16, color: AppTheme.textGrey)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: wishlist.items.length,
              itemBuilder: (ctx, i) {
                final product = wishlist.items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                  child: Row(children: [
                    ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: ProductImage(imageUrl: product.imageUrl, width: 100, height: 100, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text("₹${product.price.toInt()}",
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primary)),
                            const SizedBox(width: 6),
                            Text("₹${product.originalPrice.toInt()}",
                                style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, decoration: TextDecoration.lineThrough)),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(child: ElevatedButton(
                              onPressed: () {
                                cart.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("${product.name} added to cart"),
                                    backgroundColor: Colors.green, duration: const Duration(seconds: 1)));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Text("Add to Cart", style: TextStyle(fontSize: 12)),
                            )),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => wishlist.toggleWishlist(product),
                                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                          ]),
                        ]))),
                  ]),
                );
              },
            ),
    );
  }
}