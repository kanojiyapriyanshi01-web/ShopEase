import '../../widgets/product_image.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Cart (${cart.itemCount})',
            style: TextStyle(color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
      ),
      body: cart.items.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_outlined, size: 70,
                  color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
              const SizedBox(height: 12),
              Text('Your cart is empty',
                  style: TextStyle(fontSize: 16,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey)),
            ]))
          : Column(children: [
              Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
                ...cart.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 6)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8),
                          child: ProductImage(imageUrl: item.product.imageUrl,
                              width: 80, height: 80, fit: BoxFit.cover)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text('₹${item.product.price.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.w700,
                                  fontSize: 15, color: AppTheme.primary)),
                          const SizedBox(width: 6),
                          Text('₹${item.product.originalPrice.toInt()}',
                              style: TextStyle(fontSize: 11,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey,
                                  decoration: TextDecoration.lineThrough)),
                          const SizedBox(width: 6),
                          Text('${item.product.discount.toInt()}% off',
                              style: const TextStyle(fontSize: 11,
                                  color: Colors.green, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          GestureDetector(
                            onTap: () => cart.updateQty(item.product.id, item.quantity - 1),
                            child: Container(width: 28, height: 28,
                                decoration: BoxDecoration(
                                    border: Border.all(color: isDark
                                        ? AppTheme.darkDivider : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(Icons.remove, size: 16,
                                    color: theme.textTheme.bodyMedium?.color))),
                          const SizedBox(width: 12),
                          Text('${item.quantity}',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                                  color: theme.textTheme.bodyMedium?.color)),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => cart.updateQty(item.product.id, item.quantity + 1),
                            child: Container(width: 28, height: 28,
                                decoration: BoxDecoration(
                                    border: Border.all(color: isDark
                                        ? AppTheme.darkDivider : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(Icons.add, size: 16,
                                    color: theme.textTheme.bodyMedium?.color))),
                          const Spacer(),
                          IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => cart.removeFromCart(item.product.id),
                              padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        ]),
                      ])),
                    ]),
                  ),
                )),
                Container(
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                          blurRadius: 6)]),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _priceRow('Total MRP',
                        '₹${cart.items.fold(0, (s, i) => s + (i.product.originalPrice * i.quantity).toInt())}',
                        theme.textTheme.bodyMedium?.color ?? Colors.black, theme),
                    const SizedBox(height: 4),
                    _priceRow('Discount',
                        '-₹${cart.items.fold(0, (s, i) => s + ((i.product.originalPrice - i.product.price) * i.quantity).toInt())}',
                        Colors.green, theme),
                    const SizedBox(height: 4),
                    _priceRow('Delivery', 'FREE', Colors.green, theme),
                    Divider(height: 16, color: isDark ? AppTheme.darkDivider : null),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total Amount',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                              color: theme.textTheme.bodyMedium?.color)),
                      Text('₹${cart.total.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 18, color: AppTheme.primary)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 80),
              ])),
              Container(
                color: theme.appBarTheme.backgroundColor,
                padding: const EdgeInsets.all(16),
                child: SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CheckoutSheet(cart: cart),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Place Order',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                )),
              ),
            ]),
    );
  }

  Widget _priceRow(String label, String value, Color valueColor, ThemeData theme) =>
      Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: TextStyle(fontSize: 13,
                color: theme.textTheme.bodySmall?.color)),
            Text(value, style: TextStyle(fontSize: 13, color: valueColor)),
          ]));
}

class CheckoutSheet extends StatefulWidget {
  final CartProvider cart;
  const CheckoutSheet({super.key, required this.cart});

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  static const String _baseUrl = 'https://shopease-backend-be8v.onrender.com';

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  String _paymentMethod = 'cod';
  int _step = 0;
  String? _error;
  bool _processing = false;
  bool _loadingLocation = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose(); _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _error = 'Location permission denied'); return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Enable location from phone settings'); return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _addressCtrl.text = '${place.street ?? ''}, ${place.subLocality ?? ''}'.trim();
          _cityCtrl.text = place.locality ?? place.administrativeArea ?? '';
          _pincodeCtrl.text = place.postalCode ?? '';
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Could not get location. Try again.');
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  void _validateAndNext() {
    if (_nameCtrl.text.trim().isEmpty) { setState(() => _error = 'Enter your name'); return; }
    if (_phoneCtrl.text.trim().length != 10) { setState(() => _error = 'Enter valid 10-digit phone'); return; }
    if (_addressCtrl.text.trim().isEmpty) { setState(() => _error = 'Enter your address'); return; }
    if (_cityCtrl.text.trim().isEmpty) { setState(() => _error = 'Enter your city'); return; }
    if (_pincodeCtrl.text.trim().length != 6) { setState(() => _error = 'Enter valid 6-digit pincode'); return; }
    setState(() { _error = null; _step = 1; });
  }

  void _showUpiDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('UPI Payment'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=upi://pay?pa=9819117133@ybl&pn=ShopEase&am=${widget.cart.total.toInt()}&cu=INR',
              width: 150, height: 150,
              errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 100)),
            const SizedBox(height: 8),
            const Text('Scan to Pay', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _submitOrder(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Payment Done')),
      ],
    ));
  }

  Future<void> _payWithStripe() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card payment coming soon!')));
  }

  Future<void> _placeOrder() async {
    if (_paymentMethod == 'upi') { _showUpiDialog(); return; }
    if (_paymentMethod == 'card') { await _payWithStripe(); return; }
    await _submitOrder();
  }

  Future<void> _submitOrder() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    setState(() => _processing = true);
    try {
      final response = await http.post(Uri.parse('$_baseUrl/orders'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({'items': widget.cart.items.map((i) => {
            'product_id': i.product.id, 'qty': i.quantity, 'price': i.product.price}).toList()}));
      if (response.statusCode != 201) {
        if (mounted) setState(() { _error = response.body; _processing = false; }); return;
      }
      final orderId = jsonDecode(response.body)['id'].toString();
      if (!mounted) return;
      _onOrderSuccess(orderId);
    } catch (e) {
      if (mounted) setState(() { _error = 'Network error.'; _processing = false; });
    }
  }

  void _onOrderSuccess(String orderId) {
    context.read<AddressProvider>().updateAddress(
      name: _nameCtrl.text, phone: _phoneCtrl.text,
      address: _addressCtrl.text, city: _cityCtrl.text, pincode: _pincodeCtrl.text);
    context.read<OrderProvider>().placeOrder(widget.cart.items, widget.cart.total);
    widget.cart.clear();
    final deliveryAddress = '${_addressCtrl.text}, ${_cityCtrl.text} - ${_pincodeCtrl.text}';
    Navigator.of(context).pop();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
              const SizedBox(height: 16),
              const Text('Order Placed Successfully!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Delivering to: $deliveryAddress', textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            ]),
            actions: [
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('OK'))),
            ],
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.92, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkDivider : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            if (_step == 1) ...[
              GestureDetector(onTap: () => setState(() => _step = 0),
                  child: Icon(Icons.arrow_back, color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(width: 8),
            ],
            Text(_step == 0 ? 'Delivery Address' : 'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyMedium?.color)),
            if (_step == 0) ...[
              const Spacer(),
              TextButton.icon(
                onPressed: _loadingLocation ? null : _fetchCurrentLocation,
                icon: _loadingLocation
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                    : const Icon(Icons.my_location, color: AppTheme.primary, size: 18),
                label: Text(_loadingLocation ? 'Fetching...' : 'Use Location',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 13))),
            ],
          ])),
          Divider(height: 0, color: isDark ? AppTheme.darkDivider : null),
          Expanded(child: SingleChildScrollView(controller: sc, padding: const EdgeInsets.all(16),
              child: _step == 0 ? _buildAddressForm() : _buildOrderSummary(theme, isDark))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _processing ? null : (_step == 0 ? _validateAndNext : _placeOrder),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: _processing
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_step == 0 ? 'Continue' : 'Confirm Order',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ))),
        ]),
      ),
    );
  }

  Widget _buildAddressForm() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _tf('Full Name', _nameCtrl, TextInputType.text),
    _tf('Phone', _phoneCtrl, TextInputType.phone, max: 10),
    _tf('Address', _addressCtrl, TextInputType.text),
    _tf('City', _cityCtrl, TextInputType.text),
    _tf('Pincode', _pincodeCtrl, TextInputType.number, max: 6),
    if (_error != null) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(_error!, style: const TextStyle(color: Colors.red))),
  ]);

  Widget _buildOrderSummary(ThemeData theme, bool isDark) {
    final cart = widget.cart;
    final savings = cart.items.fold(0.0, (s, i) => s + ((i.product.originalPrice - i.product.price) * i.quantity));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.green.withOpacity(isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.3))),
          child: Text('Delivering to: ${_nameCtrl.text}, ${_addressCtrl.text}, ${_cityCtrl.text} - ${_pincodeCtrl.text}',
              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color))),
      const SizedBox(height: 16),
      ...cart.items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: theme.cardColor, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? AppTheme.darkDivider : Colors.grey.shade200)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(6),
              child: ProductImage(imageUrl: item.product.imageUrl,
                  width: 60, height: 60, fit: BoxFit.cover)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color)),
            Text('₹${item.product.price.toInt()}',
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
            Text('Qty: ${item.quantity} | Subtotal: ₹${(item.product.price * item.quantity).toInt()}',
                style: TextStyle(fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey)),
          ])),
        ]),
      )),
      Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            _summaryRow('Total MRP', '₹${cart.items.fold(0, (s, i) => s + (i.product.originalPrice * i.quantity).toInt())}',
                theme.textTheme.bodyMedium?.color ?? Colors.black, theme),
            _summaryRow('Discount', '-₹${savings.toInt()}', Colors.green, theme),
            _summaryRow('Delivery', 'FREE', Colors.green, theme),
            Divider(height: 16, color: isDark ? AppTheme.darkDivider : null),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total Payable', style: TextStyle(fontWeight: FontWeight.w800,
                  fontSize: 15, color: theme.textTheme.bodyMedium?.color)),
              Text('₹${cart.total.toInt()}', style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primary)),
            ]),
          ])),
      const SizedBox(height: 16),
      Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700,
          fontSize: 15, color: theme.textTheme.bodyMedium?.color)),
      const SizedBox(height: 8),
      _payOpt('upi', Icons.account_balance_wallet_outlined, 'UPI / Net Banking', theme, isDark),
      _payOpt('card', Icons.credit_card_outlined, 'Debit / Credit Card (Stripe)', theme, isDark),
      _payOpt('cod', Icons.money_outlined, 'Cash on Delivery', theme, isDark),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 8),
          child: Text(_error!, style: const TextStyle(color: Colors.red))),
    ]);
  }

  Widget _payOpt(String val, IconData icon, String label, ThemeData theme, bool isDark) {
    final sel = _paymentMethod == val;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = val),
      child: Container(margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: sel ? AppTheme.primary.withOpacity(0.06)
                  : (isDark ? AppTheme.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: sel ? AppTheme.primary
                      : (isDark ? AppTheme.darkDivider : Colors.grey.shade200),
                  width: sel ? 1.5 : 1)),
          child: Row(children: [
            Icon(icon, color: sel ? AppTheme.primary
                : (isDark ? AppTheme.darkTextSecondary : Colors.grey), size: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13,
                color: sel ? AppTheme.primary : theme.textTheme.bodyMedium?.color)),
            const Spacer(),
            if (sel) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
          ])),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor, ThemeData theme) =>
      Padding(padding: const EdgeInsets.only(bottom: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor)),
          ]));

  Widget _tf(String label, TextEditingController ctrl, TextInputType type, {int? max}) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextField(controller: ctrl, keyboardType: type, maxLength: max,
              decoration: InputDecoration(labelText: label, counterText: '',
                  border: const OutlineInputBorder())));
}
