// lib/screens/home/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/app_providers.dart';
import '../../routes/app_routes.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import '../../theme/app_theme.dart';

const List<String> _avatars = [
  '😊', '😎', '🥳', '🤩', '😍', '🦁', '🐯', '🐻', '🦊', '🐼',
  '🐸', '🐙', '🦋', '🌸', '⭐', '🔥', '💎', '👑', '🎯', '🚀',
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final address = context.watch<AddressProvider>();
    final t = lang.isHindi ? _hi : _en;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey;
    final divColor = isDark ? AppTheme.darkDivider : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(t['profile']!, style: TextStyle(color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: ListView(children: [
        // ── Profile Header ──
        Container(
          color: cardColor,
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            GestureDetector(
              onTap: () => _showAvatarPicker(context, auth, isDark),
              child: Stack(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: auth.avatar.isNotEmpty
                      ? Text(auth.avatar, style: const TextStyle(fontSize: 32))
                      : Text(auth.name.isNotEmpty ? auth.name[0].toUpperCase() : 'S',
                          style: const TextStyle(color: AppTheme.primary,
                              fontSize: 28, fontWeight: FontWeight.w800)),
                ),
                Positioned(bottom: 0, right: 0,
                  child: Container(width: 22, height: 22,
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 13))),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(auth.name.isNotEmpty ? auth.name : 'Shopper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
              Text(auth.phone.isNotEmpty ? '+91 ${auth.phone}' : '',
                  style: TextStyle(color: subColor, fontSize: 13)),
            ])),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
              onPressed: () => _editProfile(context, auth, t)),
          ]),
        ),
        const SizedBox(height: 8),

        // ── Quick Stats ──
        Container(
          color: cardColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(children: [
            _statTile(context.watch<OrderProvider>().orders.length.toString(), t['orders']!, textColor, subColor),
            Container(width: 1, height: 30, color: divColor),
            _statTile(context.watch<WishlistProvider>().count.toString(), t['wishlist']!, textColor, subColor),
            Container(width: 1, height: 30, color: divColor),
            _statTile(context.watch<CartProvider>().itemCount.toString(), t['cart']!, textColor, subColor),
          ]),
        ),
        const SizedBox(height: 8),

        // ── Menu Options ──
        Container(
          color: cardColor,
          child: Column(children: [
            _tile(context, icon: Icons.shopping_bag_outlined, color: const Color(0xFF2196F3),
                label: t['orders']!, textColor: textColor,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
            _tile(context, icon: Icons.favorite_border_rounded, color: const Color(0xFFF44336),
                label: t['wishlist']!, textColor: textColor,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()))),
            _tile(context, icon: Icons.shopping_cart_outlined, color: const Color(0xFFFF9800),
                label: t['cart']!, textColor: textColor,
                onTap: () => Navigator.pushNamed(context, AppRoutes.cart)),
            _tile(context, icon: Icons.payment_outlined, color: const Color(0xFF4CAF50),
                label: t['payment']!, textColor: textColor,
                onTap: () => _showPaymentMethods(context, t, isDark)),
            _tile(context, icon: Icons.location_on_outlined, color: const Color(0xFF9C27B0),
                label: t['address']!, textColor: textColor,
                subtitle: address.city.isNotEmpty ? '${address.city} - ${address.pincode}' : null,
                subtitleColor: subColor,
                onTap: () => _showAddressDialog(context, address, t)),
            _tile(context, icon: Icons.language_outlined, color: const Color(0xFF009688),
                label: t['language']!, textColor: textColor,
                subtitle: lang.isHindi ? 'हिंदी' : 'English', subtitleColor: subColor,
                onTap: () => _showLanguageDialog(context, lang, t)),
            _tile(context, icon: Icons.settings_outlined, color: const Color(0xFF9E9E9E),
                label: t['settings']!, textColor: textColor,
                onTap: () => _showSettingsDialog(context, t)),
            _tile(context, icon: Icons.help_outline_rounded, color: const Color(0xFF3F51B5),
                label: t['help']!, textColor: textColor,
                onTap: () => _showHelpDialog(context, t)),
            _tile(context, icon: Icons.share_outlined, color: const Color(0xFFFFC107),
                label: t['refer']!, textColor: textColor,
                onTap: () => _showReferDialog(context, t)),
          ]),
        ),
        const SizedBox(height: 8),

        // ── Logout ──
        Container(
          color: cardColor,
          child: ListTile(
            leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20)),
            title: Text(t['logout']!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
            onTap: () => _confirmLogout(context, auth, t),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  void _showAvatarPicker(BuildContext context, AuthProvider auth, bool isDark) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Choose Avatar', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: _avatars.length,
          itemBuilder: (ctx, i) => GestureDetector(
            onTap: () { auth.setAvatar(_avatars[i]); Navigator.pop(context); },
            child: Container(
              decoration: BoxDecoration(
                color: auth.avatar == _avatars[i]
                    ? AppTheme.primary.withOpacity(0.15)
                    : (isDark ? AppTheme.darkCard : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: auth.avatar == _avatars[i] ? AppTheme.primary : Colors.transparent,
                    width: 2)),
              child: Center(child: Text(_avatars[i], style: const TextStyle(fontSize: 24))),
            ),
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
    ));
  }

  void _showPaymentMethods(BuildContext context, Map<String, String> t, bool isDark) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _paymentTile(Icons.account_balance_wallet_outlined, 'UPI / Net Banking',
            'Pay via UPI, NEFT, IMPS', Colors.blue, isDark),
        const SizedBox(height: 8),
        _paymentTile(Icons.credit_card_outlined, 'Debit / Credit Card (Stripe)',
            'Visa, Mastercard, RuPay', Colors.purple, isDark),
        const SizedBox(height: 8),
        _paymentTile(Icons.money_outlined, 'Cash on Delivery',
            'Pay when order arrives', Colors.green, isDark),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  Widget _paymentTile(IconData icon, String title, String subtitle, Color color, bool isDark) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppTheme.darkDivider : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(subtitle, style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : Colors.grey, fontSize: 11)),
          ])),
        ]),
      );

  void _showAddressDialog(BuildContext context, AddressProvider address, Map<String, String> t) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(t['address']!, style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (address.fullAddress.isNotEmpty) ...[
          const Text('Last Used Address',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(address.name.isNotEmpty ? address.name : 'Home',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${address.fullAddress}, ${address.city} - ${address.pincode}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (address.phone.isNotEmpty)
                  Text('+91 ${address.phone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
            ]),
          ),
        ] else ...[
          const Center(child: Column(children: [
            Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No saved address yet', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text('Place an order to save address', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
        ],
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t['close']!))],
    ));
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider lang, Map<String, String> t) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(t['selectLanguage']!),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        RadioListTile<bool>(value: false, groupValue: lang.isHindi,
            onChanged: (_) { lang.setEnglish(); Navigator.pop(context); },
            title: const Row(children: [Text('🇬🇧 ', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('English')]),
            activeColor: AppTheme.primary),
        RadioListTile<bool>(value: true, groupValue: lang.isHindi,
            onChanged: (_) { lang.setHindi(); Navigator.pop(context); },
            title: const Row(children: [Text('🇮🇳 ', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('हिंदी (Hindi)')]),
            activeColor: AppTheme.primary),
      ]),
    ));
  }

  void _showSettingsDialog(BuildContext context, Map<String, String> t) {
    showDialog(context: context, builder: (ctx) => _SettingsDialog(t: t));
  }

  void _showHelpDialog(BuildContext context, Map<String, String> t) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(t['help']!),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _helpTile(Icons.chat_outlined, t['chatSupport']!),
        _helpTile(Icons.email_outlined, 'support@shopease.com'),
        _helpTile(Icons.phone_outlined, '+91 1800-XXX-XXXX'),
        _helpTile(Icons.help_outline, t['faq']!),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t['close']!))],
    ));
  }

  Widget _helpTile(IconData icon, String text) => ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 20),
      title: Text(text, style: const TextStyle(fontSize: 13)), dense: true, onTap: () {});

  void _showReferDialog(BuildContext context, Map<String, String> t) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(t['refer']!),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.card_giftcard_rounded, size: 60, color: AppTheme.primary),
        const SizedBox(height: 12),
        Text(t['referDesc']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
          child: const Text('SHOPEASE50', style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 18, color: AppTheme.primary, letterSpacing: 2))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t['close']!)),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            SharePlus.instance.share(ShareParams(
              text: '🛍️ ShopEase pe shopping karo!\n\nMera referral code use karo: SHOPEASE50\nAur pao Rs.50 discount apni pehli order pe!\n\n#ShopEase #Shopping #Discount',
              subject: 'ShopEase - Rs.50 Off with my referral!',
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: Text(t['share']!)),
      ],
    ));
  }

  Widget _statTile(String value, String label, Color? textColor, Color subColor) => Expanded(
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: subColor, fontSize: 12)),
      ]));

  Widget _tile(BuildContext context, {required IconData icon, required Color color,
      required String label, required VoidCallback onTap, Color? textColor,
      String? subtitle, Color? subtitleColor}) =>
      ListTile(
        leading: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20)),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor)),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)) : null,
        trailing: Icon(Icons.chevron_right, color: subtitleColor, size: 20),
        onTap: onTap,
      );

  void _editProfile(BuildContext context, AuthProvider auth, Map<String, String> t) {
    final ctrl = TextEditingController(text: auth.name);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(t['editProfile']!),
      content: TextField(controller: ctrl, decoration: InputDecoration(labelText: t['fullName']!)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t['cancel']!)),
        ElevatedButton(
          onPressed: () { auth.updateProfile(ctrl.text.trim()); Navigator.pop(context); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: Text(t['save']!)),
      ],
    ));
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth, Map<String, String> t) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(t['logout']!), content: Text(t['logoutConfirm']!),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t['cancel']!)),
        ElevatedButton(onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(t['logout']!)),
      ],
    ));
    if (confirm == true && context.mounted) {
      await auth.logout();
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  static const _en = {
    'profile': 'My Profile', 'orders': 'Orders', 'wishlist': 'Wishlist',
    'cart': 'Cart', 'payment': 'Payment Methods', 'address': 'Saved Addresses',
    'language': 'Language', 'settings': 'Settings', 'help': 'Help Center',
    'refer': 'Refer & Earn', 'logout': 'Logout',
    'logoutConfirm': 'Are you sure you want to logout?',
    'cancel': 'Cancel', 'save': 'Save', 'close': 'Close', 'share': 'Share',
    'editProfile': 'Edit Profile', 'fullName': 'Full Name',
    'selectLanguage': 'Select Language', 'addAddress': 'Add New Address',
    'darkMode': 'Dark Mode', 'lightMode': 'Light Mode',
    'chatSupport': 'Chat Support', 'faq': 'FAQs',
    'referDesc': 'Refer friends and earn Rs.50 on each successful referral!',
  };

  static const _hi = {
    'profile': 'मेरी प्रोफ़ाइल', 'orders': 'ऑर्डर', 'wishlist': 'पसंद सूची',
    'cart': 'कार्ट', 'payment': 'भुगतान विधि', 'address': 'पते',
    'language': 'भाषा', 'settings': 'सेटिंग्स', 'help': 'सहायता केंद्र',
    'refer': 'रेफर करें और कमाएं', 'logout': 'लॉग आउट',
    'logoutConfirm': 'क्या आप लॉग आउट करना चाहते हैं?',
    'cancel': 'रद्द करें', 'save': 'सहेजें', 'close': 'बंद करें',
    'share': 'शेयर करें', 'editProfile': 'प्रोफ़ाइल संपादित करें',
    'fullName': 'पूरा नाम', 'selectLanguage': 'भाषा चुनें',
    'addAddress': 'नया पता जोड़ें', 'darkMode': 'डार्क मोड',
    'lightMode': 'लाइट मोड', 'chatSupport': 'चैट सहायता',
    'faq': 'अक्सर पूछे जाने वाले प्रश्न',
    'referDesc': 'दोस्तों को रेफर करें और हर सफल रेफरल पर Rs.50 कमाएं!',
  };
}

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
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile(
          secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppTheme.primary),
          title: Text(
              themeProvider.isDark ? widget.t['darkMode']! : widget.t['lightMode']!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          value: themeProvider.isDark,
          onChanged: (val) async { await themeProvider.toggleTheme(); },
          activeColor: AppTheme.primary,
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.t['close']!)),
      ],
    );
  }
}