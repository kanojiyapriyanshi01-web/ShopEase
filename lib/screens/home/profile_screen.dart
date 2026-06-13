// lib/screens/home/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../routes/app_routes.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    final t = lang.isHindi ? _hi : _en;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(t['profile']!),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // ── Profile Header ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: Text(
                    auth.name.isNotEmpty ? auth.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.name.isNotEmpty ? auth.name : 'Shopper',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        auth.email.isNotEmpty ? '+91 ${auth.email}' : '',
                        style: const TextStyle(
                            color: AppTheme.textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                  onPressed: () => _editProfile(context, auth, t),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Quick Stats ────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                _statTile(
                  context.watch<OrderProvider>().orders.length.toString(),
                  t['orders']!,
                ),
                _divider(),
                _statTile(
                  context.watch<WishlistProvider>().count.toString(),
                  t['wishlist']!,
                ),
                _divider(),
                _statTile(
                  context.watch<CartProvider>().itemCount.toString(),
                  t['cart']!,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Menu Options ───────────────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // ✅ FIX 1: Orders → OrdersScreen (pehle WishlistScreen tha)
                _tile(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF2196F3),
                  label: t['orders']!,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen())),
                ),
                // ✅ FIX 2: Wishlist → WishlistScreen (sahi hai)
                _tile(
                  context,
                  icon: Icons.favorite_border_rounded,
                  color: const Color(0xFFF44336),
                  label: t['wishlist']!,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen())),
                ),
                _tile(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  color: const Color(0xFFFF9800),
                  label: t['cart']!,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                ),
                _tile(
                  context,
                  icon: Icons.payment_outlined,
                  color: const Color(0xFF4CAF50),
                  label: t['payment']!,
                  onTap: () => _showComingSoon(context, t['payment']!),
                ),
                _tile(
                  context,
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFF9C27B0),
                  label: t['address']!,
                  onTap: () => _showAddressDialog(context, t),
                ),
                _tile(
                  context,
                  icon: Icons.language_outlined,
                  color: const Color(0xFF009688),
                  label: t['language']!,
                  subtitle: lang.isHindi ? 'हिंदी' : 'English',
                  onTap: () => _showLanguageDialog(context, lang, t),
                ),
                // ✅ FIX 3: Settings dialog ab ThemeProvider use karega
                _tile(
                  context,
                  icon: Icons.settings_outlined,
                  color: const Color(0xFF9E9E9E),
                  label: t['settings']!,
                  onTap: () => _showSettingsDialog(context, t),
                ),
                _tile(
                  context,
                  icon: Icons.help_outline_rounded,
                  color: const Color(0xFF3F51B5),
                  label: t['help']!,
                  onTap: () => _showHelpDialog(context, t),
                ),
                _tile(
                  context,
                  icon: Icons.share_outlined,
                  color: const Color(0xFFFFC107),
                  label: t['refer']!,
                  onTap: () => _showReferDialog(context, t),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Logout ─────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.red, size: 20),
              ),
              title: Text(t['logout']!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right,
                  color: Colors.red, size: 20),
              onTap: () => _confirmLogout(context, auth, t),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _statTile(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 30, color: Colors.grey.shade200);

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
  }) =>
      ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppTheme.textDark)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textGrey))
            : null,
        trailing: const Icon(Icons.chevron_right,
            color: AppTheme.textGrey, size: 20),
        onTap: onTap,
      );

  void _editProfile(BuildContext context, AuthProvider auth,
      Map<String, String> t) {
    final ctrl = TextEditingController(text: auth.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t['editProfile']!),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: t['fullName']!),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t['cancel']!)),
          ElevatedButton(
            onPressed: () {
              auth.updateProfile(ctrl.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary),
            child: Text(t['save']!),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider lang, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t['selectLanguage']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              value: false,
              groupValue: lang.isHindi,
              onChanged: (_) {
                lang.setEnglish();
                Navigator.pop(context);
              },
              title: const Row(
                children: [
                  Text('🇬🇧 ', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('English'),
                ],
              ),
              activeColor: AppTheme.primary,
            ),
            RadioListTile<bool>(
              value: true,
              groupValue: lang.isHindi,
              onChanged: (_) {
                lang.setHindi();
                Navigator.pop(context);
              },
              title: const Row(
                children: [
                  Text('🇮🇳 ', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('हिंदी (Hindi)'),
                ],
              ),
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog(
      BuildContext context, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t['address']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _addressCard('Home', 'Mumbai, Maharashtra - 400042'),
            const SizedBox(height: 8),
            _addressCard('Work', 'Pune, Maharashtra - 411001'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: Text(t['addAddress']!),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t['close']!)),
        ],
      ),
    );
  }

  Widget _addressCard(String type, String address) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(address,
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ],
        ),
      );

  // ✅ FIX 3: Settings dialog — Notifications hata diya, Dark Mode properly kaam karta hai
  void _showSettingsDialog(BuildContext context, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (ctx) => _SettingsDialog(t: t),
    );
  }

  void _showHelpDialog(BuildContext context, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t['help']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _helpTile(Icons.chat_outlined, t['chatSupport']!),
            _helpTile(Icons.email_outlined, 'support@shopease.com'),
            _helpTile(Icons.phone_outlined, '+91 1800-XXX-XXXX'),
            _helpTile(Icons.help_outline, t['faq']!),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t['close']!)),
        ],
      ),
    );
  }

  Widget _helpTile(IconData icon, String text) => ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 20),
        title: Text(text, style: const TextStyle(fontSize: 13)),
        dense: true,
        onTap: () {},
      );

  void _showReferDialog(BuildContext context, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t['refer']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard_rounded,
                size: 60, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(t['referDesc']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Text('SHOPEASE50',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.primary,
                      letterSpacing: 2)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t['close']!)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary),
            child: Text(t['share']!),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth,
      Map<String, String> t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t['logout']!),
        content: Text(t['logoutConfirm']!),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t['cancel']!)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t['logout']!),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await auth.logout();
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  // ── Translations ─────────────────────────────────────────────
  static const _en = {
    'profile': 'My Profile',
    'orders': 'Orders',
    'wishlist': 'Wishlist',
    'cart': 'Cart',
    'payment': 'Payment Methods',
    'address': 'Saved Addresses',
    'language': 'Language',
    'settings': 'Settings',
    'help': 'Help Center',
    'refer': 'Refer & Earn',
    'logout': 'Logout',
    'logoutConfirm': 'Are you sure you want to logout?',
    'cancel': 'Cancel',
    'save': 'Save',
    'close': 'Close',
    'share': 'Share',
    'editProfile': 'Edit Profile',
    'fullName': 'Full Name',
    'selectLanguage': 'Select Language',
    'addAddress': 'Add New Address',
    'darkMode': 'Dark Mode',
    'lightMode': 'Light Mode',
    'chatSupport': 'Chat Support',
    'faq': 'FAQs',
    'referDesc': 'Refer friends and earn ₹50 on each successful referral!',
  };

  static const _hi = {
    'profile': 'मेरी प्रोफ़ाइल',
    'orders': 'ऑर्डर',
    'wishlist': 'पसंद सूची',
    'cart': 'कार्ट',
    'payment': 'भुगतान विधि',
    'address': 'पते',
    'language': 'भाषा',
    'settings': 'सेटिंग्स',
    'help': 'सहायता केंद्र',
    'refer': 'रेफर करें और कमाएं',
    'logout': 'लॉग आउट',
    'logoutConfirm': 'क्या आप लॉग आउट करना चाहते हैं?',
    'cancel': 'रद्द करें',
    'save': 'सहेजें',
    'close': 'बंद करें',
    'share': 'शेयर करें',
    'editProfile': 'प्रोफ़ाइल संपादित करें',
    'fullName': 'पूरा नाम',
    'selectLanguage': 'भाषा चुनें',
    'addAddress': 'नया पता जोड़ें',
    'darkMode': 'डार्क मोड',
    'lightMode': 'लाइट मोड',
    'chatSupport': 'चैट सहायता',
    'faq': 'अक्सर पूछे जाने वाले प्रश्न',
    'referDesc': 'दोस्तों को रेफर करें और हर सफल रेफरल पर ₹50 कमाएं!',
  };
}

// ✅ Alag StatefulWidget — Dark Mode toggle properly rebuild hoga
class _SettingsDialog extends StatefulWidget {
  final Map<String, String> t;
  const _SettingsDialog({required this.t});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return AlertDialog(
      title: Text(widget.t['settings']!),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark Mode / Light Mode toggle with icon
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppTheme.primary,
            ),
            title: Text(
              themeProvider.isDark
                  ? (widget.t['darkMode']!)
                  : (widget.t['lightMode']!),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            value: themeProvider.isDark,
            onChanged: (val) {
              themeProvider.toggleTheme();
            },
            activeColor: AppTheme.primary,
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.t['close']!)),
      ],
    );
  }
}