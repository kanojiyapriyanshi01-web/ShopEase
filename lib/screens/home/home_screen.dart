// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/product_model.dart';
import '../../providers/app_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _dialogOpen = false;

  final List<List<Color>> _categoryRingGradients = const [
    [Color(0xFFE91E8C), Color(0xFFFF6B6B), Color(0xFFFFB347)],
    [Color(0xFFE91E8C), Color(0xFFFF80AB)],
    [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
    [Color(0xFF1565C0), Color(0xFF42A5F5)],
    [Color(0xFFE65100), Color(0xFFFF8A65)],
    [Color(0xFFAD1457), Color(0xFFF06292)],
    [Color(0xFF4527A0), Color(0xFF9575CD)],
    [Color(0xFF00838F), Color(0xFF4DD0E1)],
    [Color(0xFF2E7D32), Color(0xFF81C784)],
    [Color(0xFFC62828), Color(0xFFEF5350)],
    [Color(0xFF37474F), Color(0xFF90A4AE)],
    [Color(0xFF558B2F), Color(0xFFAED581)],
    [Color(0xFF6D4C41), Color(0xFFBCAAA4)],
    [Color(0xFF0277BD), Color(0xFF4FC3F7)],
  ];

  final List<_BannerData> _banners = [
    _BannerData(title: 'Fashion Sale', subtitle: 'Upto 70% Off on Sarees & Kurtis',
        color1: const Color(0xFFE91E8C), color2: const Color(0xFFFF6B6B),
        imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&q=80'),
    _BannerData(title: 'Electronics Mega Deal', subtitle: 'Smart Gadgets Starting Rs.199',
        color1: const Color(0xFF1565C0), color2: const Color(0xFF42A5F5),
        imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=600&q=80'),
    _BannerData(title: 'Beauty Essentials', subtitle: 'Top Brands at Best Prices',
        color1: const Color(0xFF6A1B9A), color2: const Color(0xFFCE93D8),
        imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&q=80'),
    _BannerData(title: 'Home & Kitchen Festival', subtitle: 'Refresh Your Home Starting Rs.299',
        color1: const Color(0xFF2E7D32), color2: const Color(0xFF81C784),
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80'),
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
      _bannerCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  String _categoryLabel(_CategoryData c) => c.label.replaceAll('\n', ' ').trim();

  void _onCategoryTap(_CategoryData cat) {
    Navigator.pushNamed(context, AppRoutes.categoryProducts, arguments: {
      'category': _categoryLabel(cat),
      'products': SampleData.getByCategory(_categoryLabel(cat)),
    });
  }

  Future<void> _fetchAndSetLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fetching your location...'),
          backgroundColor: AppTheme.primary, duration: Duration(seconds: 2)));
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        final city = place.locality ?? place.administrativeArea ?? 'Unknown';
        final pincode = place.postalCode ?? '';
        context.read<AddressProvider>().updateAddress(
          name: context.read<AuthProvider>().name,
          phone: context.read<AuthProvider>().phone,
          address: (place.street != null && place.street!.trim().isNotEmpty) ? place.street! : ', '.trim(),
          city: city,
          pincode: pincode,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Delivering to $city - $pincode'),
            backgroundColor: Colors.green, duration: const Duration(seconds: 3)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get location'), backgroundColor: Colors.red));
    }
  }

  Future<void> _startVoiceSearch() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _dialogOpen) {
          _dialogOpen = false;
          if (mounted) setState(() => _isListening = false);
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        }
      },
      onError: (error) {
        if (_dialogOpen) {
          _dialogOpen = false;
          if (mounted) setState(() => _isListening = false);
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        }
      },
    );
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Microphone not available'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isListening = true);
    _dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.mic_rounded, color: AppTheme.primary, size: 40)),
          const SizedBox(height: 12),
          const Text('Listening...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          const LinearProgressIndicator(color: AppTheme.primary),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              _speech.stop();
              _dialogOpen = false;
              setState(() => _isListening = false);
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          final query = result.recognizedWords;
          _speech.stop();
          _dialogOpen = false;
          if (mounted) setState(() => _isListening = false);
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => SearchScreen(initialQuery: query),
              ));
            }
          });
        }
      },
      localeId: 'en_IN',
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(children: [
            SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 12), Text('Analyzing image...'),
          ]),
          backgroundColor: AppTheme.primary, duration: Duration(seconds: 2)));
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) _showImageCategoryPicker();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showImageCategoryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      {'label': 'Sarees', 'icon': '👘', 'category': 'Sarees'},
      {'label': 'Women\nFashion', 'icon': '👗', 'category': 'Women Fashion'},
      {'label': 'Men\nFashion', 'icon': '👔', 'category': 'Men Fashion'},
      {'label': 'Kids', 'icon': '🧒', 'category': 'Kids'},
      {'label': 'Footwear', 'icon': '👟', 'category': 'Footwear'},
      {'label': 'Jewellery', 'icon': '💍', 'category': 'Jewellery'},
      {'label': 'Beauty', 'icon': '💄', 'category': 'Beauty'},
      {'label': 'Electronics', 'icon': '📱', 'category': 'Electronics'},
      {'label': 'Bags', 'icon': '👜', 'category': 'Bags'},
      {'label': 'Accessories', 'icon': '⌚', 'category': 'Accessories'},
      {'label': 'Home &\nKitchen', 'icon': '🏠', 'category': 'Home & Kitchen'},
      {'label': 'Skincare', 'icon': '🧴', 'category': 'Skincare'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkDivider : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(children: [
            Container(width: 40, height: 40,
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.image_search_rounded, color: AppTheme.primary, size: 22)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What did you capture?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)),
              Text('Select category to find similar products',
                  style: TextStyle(fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : Colors.grey)),
            ]),
          ]),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 8,
                mainAxisSpacing: 8, childAspectRatio: 0.85),
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.categoryProducts,
                      arguments: {
                        'category': cat['category'],
                        'products': SampleData.getByCategory(cat['category']!),
                      });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(cat['icon']!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(cat['label']!, textAlign: TextAlign.center,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _showImageSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.blue, size: 40)),
          const SizedBox(height: 12),
          const Text('Search by Image',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Take a photo or upload from gallery',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined, size: 16),
              label: const Text('Camera'),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary)),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 16),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary)),
            )),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  // ── Promotional Banner Widget ─────────────────────────────
  Widget _promoBanner({
    required String title,
    required String subtitle,
    required String tag,
    required Color bgColor,
    required Color textColor,
    required Color tagColor,
    required String imageUrl,
    required String category,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryProducts, arguments: {
        'category': category,
        'products': SampleData.getByCategory(category),
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 120,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(fit: StackFit.expand, children: [
            Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [bgColor.withOpacity(0.95), bgColor.withOpacity(0.3)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(tag,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor,
                          fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('SHOP NOW',
                        style: TextStyle(color: Colors.white,
                            fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Category Strip Banner ─────────────────────────────────
  Widget _categoryStripBanner({
    required String title,
    required String subtitle,
    required List<_StripItem> items,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18,
                fontWeight: FontWeight.w900, color: Colors.black87)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.categoryProducts,
                  arguments: {'category': items[i].category,
                      'products': SampleData.getByCategory(items[i].category)}),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                width: 90,
                child: Column(children: [
                  Container(
                    width: 75, height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                          blurRadius: 4)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(items[i].imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(items[i].icon, size: 32, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(items[i].label, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final address = context.watch<AddressProvider>();

    final allProducts = SampleData.products;
    final featured = allProducts.where((p) => p.isFeatured).toList();
    final popular = allProducts.where((p) => p.isPopular).toList();
    final newArrivals = allProducts.where((p) => p.isNewArrival).toList();
    final bestSellers = allProducts.where((p) => p.isBestSeller).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDark
                ? [AppTheme.darkBg, AppTheme.darkSurface, AppTheme.darkBg, AppTheme.darkSurface]
                : const [Color(0xFFFFF8F0), Color(0xFFFFEDD8), Color(0xFFFFF3E0), Color(0xFFFFEDD8)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true, snap: true,
                backgroundColor: isDark
                    ? AppTheme.darkSurface.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                elevation: 1, automaticallyImplyLeading: false, titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primary.withOpacity(0.15),
                        child: context.watch<AuthProvider>().avatar.isNotEmpty
                            ? Text(context.watch<AuthProvider>().avatar,
                                style: const TextStyle(fontSize: 18))
                            : Text(auth.name.isNotEmpty ? auth.name[0].toUpperCase() : 'S',
                                style: const TextStyle(color: AppTheme.primary,
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.favorite_border_rounded,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.wishlist),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    const SizedBox(width: 8),
                    Stack(children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                        padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      if (cart.itemCount > 0)
                        Positioned(right: 0, top: 0,
                          child: Container(width: 16, height: 16,
                            decoration: const BoxDecoration(
                                color: AppTheme.primary, shape: BoxShape.circle),
                            child: Text('${cart.itemCount}', textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 10)))),
                    ]),
                  ]),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Container(
                    color: isDark ? AppTheme.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkCard : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: isDark ? AppTheme.darkDivider : Colors.grey.shade300)),
                              child: Row(children: [
                                const SizedBox(width: 12),
                                Icon(Icons.search, color: isDark ? AppTheme.darkTextSecondary : Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Search by Keyword or Product ID',
                                    style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : Colors.grey))),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _startVoiceSearch,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _isListening ? AppTheme.primary
                                  : AppTheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle),
                            child: Icon(
                              _isListening ? Icons.mic_rounded : Icons.mic_outlined,
                              color: _isListening ? Colors.white : AppTheme.primary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showImageSearchDialog,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.blue, size: 22)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _fetchAndSetLocation,
                        child: Row(children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(address.deliveryText,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w500, color: AppTheme.textDark),
                              overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.my_location, size: 14, color: AppTheme.primary),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── Category Row with colorful rings ──
                  Container(
                    color: isDark ? AppTheme.darkSurface.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 95,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _categories.length,
                        itemBuilder: (ctx, i) {
                          final cat = _categories[i];
                          final ringGrad = _categoryRingGradients[i % _categoryRingGradients.length];
                          final labelColor = ringGrad[0];
                          return GestureDetector(
                            onTap: () => _onCategoryTap(cat),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 68,
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: ringGrad,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: isDark ? AppTheme.darkCard : Colors.white,
                                        shape: BoxShape.circle),
                                    padding: const EdgeInsets.all(2),
                                    child: ClipOval(child: Image.network(cat.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Icon(cat.icon, color: ringGrad[0], size: 24))),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(cat.label, textAlign: TextAlign.center,
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 9,
                                        color: labelColor, fontWeight: FontWeight.w700,
                                        height: 1.2)),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Main Banner Carousel ──
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
                            gradient: LinearGradient(colors: [b.color1, b.color2])),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(fit: StackFit.expand, children: [
                              Image.network(b.imageUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                              Container(decoration: BoxDecoration(gradient: LinearGradient(
                                  colors: [b.color1.withOpacity(0.82),
                                      b.color2.withOpacity(0.45)]))),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(4)),
                                      child: const Text('UPTO 70% OFF',
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 11, fontWeight: FontWeight.w700))),
                                    const SizedBox(height: 8),
                                    Text(b.title, style: const TextStyle(color: Colors.white,
                                        fontSize: 22, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text(b.subtitle, style: TextStyle(
                                        color: Colors.white.withOpacity(0.9), fontSize: 13)),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_banners.length, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _bannerIndex ? 20 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: i == _bannerIndex ? AppTheme.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3))))),
                  const SizedBox(height: 16),

                  // ── Featured Products ──
                  _sectionHeader('Featured Products', featured, context),
                  _horizontalProductList(featured),

                  // ── PROMO BANNER 1: Women Fashion ──
                  _promoBanner(
                    title: 'WOMEN\nFASHION',
                    subtitle: 'Kurtis, Sarees & More',
                    tag: 'UPTO 60% OFF',
                    bgColor: const Color(0xFFFCE4EC),
                    textColor: const Color(0xFF880E4F),
                    tagColor: const Color(0xFFE91E8C),
                    imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
                    category: 'Women Fashion',
                  ),

                  // ── Popular Products ──
                  _sectionHeader('Popular Products', popular, context),
                  _horizontalProductList(popular),

                  // ── CATEGORY STRIP BANNER: Footwear ──
                  _categoryStripBanner(
                    title: 'STEP IN STYLE',
                    subtitle: 'Footwear for every occasion',
                    bgColor: const Color(0xFFF3E5F5),
                    items: [
                      _StripItem('Heels', 'Footwear',
                          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=200',
                          Icons.roller_skating_rounded),
                      _StripItem('Sneakers', 'Footwear',
                          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
                          Icons.roller_skating_rounded),
                      _StripItem('Flats', 'Footwear',
                          'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=200',
                          Icons.roller_skating_rounded),
                      _StripItem('Formal', 'Footwear',
                          'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=200',
                          Icons.roller_skating_rounded),
                      _StripItem('Kids', 'Footwear',
                          'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=200',
                          Icons.roller_skating_rounded),
                    ],
                  ),

                  // ── New Arrivals ──
                  _sectionHeader('New Arrivals', newArrivals, context),
                  _horizontalProductList(newArrivals),

                  // ── PROMO BANNER 2: Electronics ──
                  _promoBanner(
                    title: 'TECH\nDEALS',
                    subtitle: 'Gadgets at lowest prices',
                    tag: 'UP TO 62% OFF',
                    bgColor: const Color(0xFFE3F2FD),
                    textColor: const Color(0xFF0D47A1),
                    tagColor: const Color(0xFF1565C0),
                    imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400',
                    category: 'Electronics',
                  ),

                  // ── Best Sellers ──
                  _sectionHeader('Best Sellers', bestSellers, context),
                  _horizontalProductList(bestSellers),

                  // ── CATEGORY STRIP BANNER: Beauty ──
                  _categoryStripBanner(
                    title: 'BEAUTY EDIT',
                    subtitle: 'Top picks for you',
                    bgColor: const Color(0xFFFFF8E1),
                    items: [
                      _StripItem('Skincare', 'Skincare',
                          'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200',
                          Icons.spa_rounded),
                      _StripItem('Makeup', 'Makeup',
                          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=200',
                          Icons.brush_rounded),
                      _StripItem('Beauty', 'Beauty',
                          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=200',
                          Icons.face_rounded),
                      _StripItem('Jewellery', 'Jewellery',
                          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=200',
                          Icons.diamond_rounded),
                    ],
                  ),

                  // ── PROMO BANNER 3: Men Fashion ──
                  _promoBanner(
                    title: 'MEN\'S\nEDIT',
                    subtitle: 'Shirts, Jeans & More',
                    tag: 'NEW ARRIVALS',
                    bgColor: const Color(0xFFE8F5E9),
                    textColor: const Color(0xFF1B5E20),
                    tagColor: const Color(0xFF2E7D32),
                    imageUrl: 'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=400',
                    category: 'Men Fashion',
                  ),

                  // ── All Products Grid ──
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('All Products', style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w700, color: AppTheme.textDark))),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10,
                        mainAxisSpacing: 10, childAspectRatio: 0.60),
                    itemCount: allProducts.length,
                    itemBuilder: (ctx, i) {
                      final product = allProducts[i];
                      // ── Insert promo banner every 6 products ──
                      return ProductCard(product: product);
                    },
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _sectionGradients = {
    'Featured Products': [Color(0xFFE91E8C), Color(0xFFFF6B6B)],
    'Popular Products': [Color(0xFF1565C0), Color(0xFF42A5F5)],
    'New Arrivals': [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
    'Best Sellers': [Color(0xFF2E7D32), Color(0xFF81C784)],
  };

  static const _sectionSubtitles = {
    'Featured Products': 'Hand-picked for you',
    'Popular Products': 'Trending this week',
    'New Arrivals': 'Just dropped',
    'Best Sellers': 'Most loved picks',
  };

  Widget _sectionHeader(String title, List<Product> products, BuildContext context) {
    final gradColors = _sectionGradients[title] ??
        [AppTheme.primary, AppTheme.primary];
    final subtitle = _sectionSubtitles[title] ?? '';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryProducts,
          arguments: {'category': title, 'products': products}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w800, color: Colors.white)),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: TextStyle(
                  fontSize: 11, color: Colors.white.withOpacity(0.85))),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('See all →',
                style: TextStyle(fontSize: 11, color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
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
          child: SizedBox(width: 155, child: ProductCard(product: products[i]))),
      ),
    );
  }
}

class _BannerData {
  final String title, subtitle, imageUrl;
  final Color color1, color2;
  _BannerData({required this.title, required this.subtitle,
      required this.color1, required this.color2, required this.imageUrl});
}

class _CategoryData {
  final String label, imageUrl;
  final IconData icon;
  final Color bgColor;
  _CategoryData(this.label, this.icon, this.bgColor, this.imageUrl);
}

class _StripItem {
  final String label, category, imageUrl;
  final IconData icon;
  _StripItem(this.label, this.category, this.imageUrl, this.icon);
}
