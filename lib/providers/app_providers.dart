import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../models/product_model.dart";
import "../services/api_service.dart";

class AuthProvider extends ChangeNotifier {
  String _name = "";
  String _phone = "";
  String _token = "";
  bool _isLoggedIn = false;
  bool _isLoading = true;

  String get name => _name;
  String get email => _phone;
  String get phone => _phone;
  String get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isRegistered => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() { _loadFromPrefs(); }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    _name = prefs.getString("userName") ?? "";
    _phone = prefs.getString("userPhone") ?? "";
    _token = prefs.getString("token") ?? "";
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> sendOtp(String phone) async {
    try {
      final res = await ApiService.sendOtp(phone);
      if (res.containsKey("error")) return res["error"];
      return null;
    } catch (e) {
      return "Network error. Is the server running?";
    }
  }

  Future<String?> loginWithOtp(String phone, {String otp = ""}) async {
    try {
      final res = await ApiService.login(phone, "");
      if (res.containsKey("error")) return res["error"];
      final prefs = await SharedPreferences.getInstance();
      _token = res["token"] ?? "";
      _phone = phone;
      _isLoggedIn = true;
      await prefs.setString("token", _token);
      await prefs.setString("userPhone", phone);
      await prefs.setBool("isLoggedIn", true);
      notifyListeners();
      return null;
    } catch (e) {
      return "Network error. Is the server running?";
    }
  }

  Future<String?> registerWithPhone(String name, String phone, {String otp = ""}) async {
    try {
      final res = await ApiService.register(name, phone, otp);
      if (res.containsKey("error")) return res["error"];
      final prefs = await SharedPreferences.getInstance();
      _token = res["token"] ?? "";
      _name = name;
      _phone = phone;
      _isLoggedIn = true;
      await prefs.setString("token", _token);
      await prefs.setString("userName", name);
      await prefs.setString("userPhone", phone);
      await prefs.setBool("isLoggedIn", true);
      notifyListeners();
      return null;
    } catch (e) {
      return "Network error. Is the server running?";
    }
  }

  Future<String?> login(String phone, String password) async =>
      loginWithOtp(phone, otp: password);

  Future<String?> register(String name, String phone, String password, String confirm) async =>
      registerWithPhone(name, phone, otp: password);

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("token");
    _isLoggedIn = false;
    _name = "";
    _phone = "";
    _token = "";
    notifyListeners();
  }

  Future<void> updateProfile(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", name);
    _name = name;
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get total => _items.fold(0, (s, i) => s + i.product.price * i.quantity);

  CartProvider() { _loadCart(); }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString("cart_items");
    if (cartJson != null) {
      final List decoded = jsonDecode(cartJson);
      for (var item in decoded) {
        final product = SampleData.products.firstWhere(
          (p) => p.id == item["id"], orElse: () => SampleData.products.first);
        final qty = item["qty"] as int;
        _items.add(CartItem(product: product, quantity: qty));
      }
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((i) => {"id": i.product.id, "qty": i.quantity}).toList());
    await prefs.setString("cart_items", cartJson);
  }

  bool isInCart(String productId) => _items.any((i) => i.product.id == productId);

  void addToCart(Product product) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) { _items[idx].quantity++; }
    else { _items.add(CartItem(product: product)); }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  void updateQty(String productId, int qty) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (qty <= 0) { _items.removeAt(idx); }
      else { _items[idx].quantity = qty; }
      _saveCart();
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}

class WishlistProvider extends ChangeNotifier {
  final List<Product> _items = [];
  List<Product> get items => _items;
  int get count => _items.length;

  WishlistProvider() { _loadWishlist(); }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishJson = prefs.getString("wishlist_items");
    if (wishJson != null) {
      final List decoded = jsonDecode(wishJson);
      for (var id in decoded) {
        final product = SampleData.products.firstWhere(
          (p) => p.id == id, orElse: () => SampleData.products.first);
        _items.add(product);
      }
      notifyListeners();
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("wishlist_items", jsonEncode(_items.map((p) => p.id).toList()));
  }

  bool isWishlisted(String productId) => _items.any((p) => p.id == productId);

  void toggleWishlist(Product product) {
    final idx = _items.indexWhere((p) => p.id == product.id);
    if (idx >= 0) { _items.removeAt(idx); }
    else { _items.add(product); }
    _saveWishlist();
    notifyListeners();
  }
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  void setIndex(int index) { _currentIndex = index; notifyListeners(); }
}

class LanguageProvider extends ChangeNotifier {
  bool _isHindi = false;
  bool get isHindi => _isHindi;
  void setHindi() { _isHindi = true; notifyListeners(); }
  void setEnglish() { _isHindi = false; notifyListeners(); }
}

// ✅ NEW: ThemeProvider — Dark/Light mode ke liye
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final String date;
  OrderModel({required this.id, required this.items, required this.total, required this.date});
}

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  void placeOrder(List<CartItem> items, double total) {
    final now = DateTime.now();
    _orders.insert(0, OrderModel(
      id: now.millisecondsSinceEpoch.toString().substring(7),
      items: List.from(items),
      total: total,
      date: "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, "0")}",
    ));
    notifyListeners();
  }
}

class AddressProvider extends ChangeNotifier {
  String _city = "Mumbai";
  String _pincode = "400042";
  String _fullAddress = "";
  String _name = "";
  String _phone = "";

  String get city => _city;
  String get pincode => _pincode;
  String get fullAddress => _fullAddress;
  String get name => _name;
  String get phone => _phone;

  String get deliveryText =>
      _city.isNotEmpty && _pincode.isNotEmpty
          ? "Delivering to $_city - $_pincode"
          : "Delivering to Mumbai - 400042";

  void updateAddress({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String pincode,
  }) {
    _name = name;
    _phone = phone;
    _fullAddress = address;
    _city = city;
    _pincode = pincode;
    notifyListeners();
  }
}