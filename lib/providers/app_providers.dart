import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../models/product_model.dart";
import "../services/api_service.dart";

class AuthProvider extends ChangeNotifier {
  String _name = "";
  String _phone = "";
  String _token = "";
  String _avatar = "";
  bool _isLoggedIn = false;
  bool _isLoading = true;

  String get name => _name;
  String get phone => _phone;
  String get token => _token;
  String get avatar => _avatar;
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
    _avatar = prefs.getString("avatar") ?? "";
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
      final res = await ApiService.login(phone, otp);
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
    await prefs.remove("avatar");
    _isLoggedIn = false;
    _name = "";
    _phone = "";
    _token = "";
    _avatar = "";
    notifyListeners();
  }

  Future<void> updateProfile(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", name);
    _name = name;
    notifyListeners();
  }

  Future<void> setAvatar(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    _avatar = emoji;
    await prefs.setString("avatar", emoji);
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
        final idx = SampleData.products.indexWhere((p) => p.id == item["id"]);
        if (idx < 0) continue;
        final qty = item["qty"] as int;
        _items.add(CartItem(product: SampleData.products[idx], quantity: qty));
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

  int getQty(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }

  void addToCart(Product product) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) { _items[idx].quantity++; }
    else { _items.add(CartItem(product: product)); }
    _saveCart();
    notifyListeners();
  }

  void addToCartWithQty(Product product, int qty) {
    if (qty <= 0) return;
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity = qty;
    } else {
      _items.add(CartItem(product: product, quantity: qty));
    }
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
        final idx = SampleData.products.indexWhere((p) => p.id == id);
        if (idx < 0) continue;
        _items.add(SampleData.products[idx]);
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

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() { _loadTheme(); }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool("isDarkMode") ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", _isDark);
    notifyListeners();
  }
}

// ✅ F-05 + F-06: OrderProvider ab backend se sync karta hai
// Local in-memory list + fake timestamp ID hata diya
// Server UUID use hota hai, OrdersScreen backend se fetch karti hai
class OrderModel {
  final String id;      // ✅ Server UUID
  final double total;
  final String date;
  final String status;
  OrderModel({
    required this.id,
    required this.total,
    required this.date,
    this.status = "pending",
  });
}

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  // ✅ Server response se real ID lo -- timestamp substring nahi
  void addOrderFromServer({
    required String id,
    required double total,
    required String date,
  }) {
    _orders.insert(0, OrderModel(id: id, total: total, date: date));
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
      _fullAddress.isNotEmpty
          ? "Delivering to $_city - $_pincode"
          : "Delivering to Mumbai - 400042";

  AddressProvider() { _loadFromPrefs(); }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString("addr_name") ?? "";
    _phone = prefs.getString("addr_phone") ?? "";
    _fullAddress = prefs.getString("addr_address") ?? "";
    _city = prefs.getString("addr_city") ?? "Mumbai";
    _pincode = prefs.getString("addr_pincode") ?? "400042";
    notifyListeners();
  }

  Future<void> updateAddress({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String pincode,
  }) async {
    _name = name;
    _phone = phone;
    _fullAddress = address;
    _city = city;
    _pincode = pincode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("addr_name", name);
    await prefs.setString("addr_phone", phone);
    await prefs.setString("addr_address", address);
    await prefs.setString("addr_city", city);
    await prefs.setString("addr_pincode", pincode);
    notifyListeners();
  }
}
