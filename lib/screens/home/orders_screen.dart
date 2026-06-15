import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:provider/provider.dart";
import "../../providers/app_providers.dart";
import "../../theme/app_theme.dart";

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const String _baseUrl = 'https://shopease-backend-be8v.onrender.com';

  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/orders/me"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        setState(() { _orders = jsonDecode(response.body); _loading = false; });
      } else {
        setState(() { _error = "Failed to load orders"; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = "Network error"; _loading = false; });
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/orders/$orderId/cancel"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order cancelled successfully"), backgroundColor: Colors.green));
        _fetchOrders();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Cannot cancel order"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error"), backgroundColor: Colors.red));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "pending": return Colors.orange;
      case "confirmed": return Colors.blue;
      case "shipped": return Colors.purple;
      case "delivered": return Colors.green;
      case "cancelled": return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "pending": return Icons.hourglass_empty;
      case "confirmed": return Icons.check_circle_outline;
      case "shipped": return Icons.local_shipping_outlined;
      case "delivered": return Icons.done_all;
      case "cancelled": return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _fetchOrders,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                      child: const Text("Retry")),
                ]))
              : _orders.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.shopping_bag_outlined, size: 70,
                          color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                      const SizedBox(height: 12),
                      Text("No orders yet", style: TextStyle(fontSize: 16,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _orders.length,
                        itemBuilder: (ctx, i) {
                          final order = _orders[i];
                          final status = order["status"] ?? "pending";
                          final items = order["items"] as List? ?? [];
                          final color = _statusColor(status);
                          final icon = _statusIcon(status);
                          final canCancel = status == "pending";
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 6)],
                            ),
                            child: Column(children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.08),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: Row(children: [
                                  Icon(icon, color: color, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text("Order #${order["id"].toString().substring(0, 8)}...",
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                                            color: theme.textTheme.bodyMedium?.color)),
                                    Text(order["created_at"].toString().substring(0, 10),
                                        style: TextStyle(fontSize: 12,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey)),
                                  ])),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text("\u20b9${order["total"]}",
                                        style: const TextStyle(fontWeight: FontWeight.w800,
                                            fontSize: 16, color: AppTheme.primary)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                                      child: Text(status.toUpperCase(),
                                          style: const TextStyle(color: Colors.white,
                                              fontSize: 11, fontWeight: FontWeight.w700)),
                                    ),
                                  ]),
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  _progressStep("Placed", status != "cancelled", color),
                                  _progressLine(["confirmed","shipped","delivered"].contains(status), color),
                                  _progressStep("Confirmed", ["confirmed","shipped","delivered"].contains(status), color),
                                  _progressLine(["shipped","delivered"].contains(status), color),
                                  _progressStep("Shipped", ["shipped","delivered"].contains(status), color),
                                  _progressLine(status == "delivered", color),
                                  _progressStep("Delivered", status == "delivered", color),
                                ]),
                              ),
                              if (items.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: Column(children: [
                                    Divider(height: 1, color: isDark ? AppTheme.darkDivider : null),
                                    const SizedBox(height: 8),
                                    ...items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Text("Product: ${item["product_id"]}",
                                            style: TextStyle(fontSize: 12,
                                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey)),
                                        Text("Qty: ${item["qty"]} x \u20b9${item["price"]}",
                                            style: TextStyle(fontSize: 12,
                                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey)),
                                      ]),
                                    )),
                                  ]),
                                ),
                              if (canCancel)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: SizedBox(width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _cancelOrder(order["id"]),
                                      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                                      label: const Text("Cancel Order", style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _progressStep(String label, bool active, Color color) => Column(children: [
    Container(width: 24, height: 24,
      decoration: BoxDecoration(color: active ? color : Colors.grey.shade300, shape: BoxShape.circle),
      child: Icon(active ? Icons.check : Icons.circle, color: Colors.white, size: 14)),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 9,
        color: active ? color : Colors.grey, fontWeight: FontWeight.w600)),
  ]);

  Widget _progressLine(bool active, Color color) => Expanded(child: Container(
    height: 2, color: active ? color : Colors.grey.shade300,
    margin: const EdgeInsets.only(bottom: 20)));
}