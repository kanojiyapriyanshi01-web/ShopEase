import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10 || !RegExp(r"^\d+$").hasMatch(phone)) {
      setState(() => _error = "Enter a valid 10-digit phone number");
      return;
    }
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final err = await auth.loginWithOtp(phone, otp: "");
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 48),
            Center(child: Column(children: [
              Container(width: 80, height: 80,
                decoration: BoxDecoration(color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 42)),
              const SizedBox(height: 14),
              const Text("ShopEase", style: TextStyle(fontSize: 26,
                  fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              const Text("Welcome back!", style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
            ])),
            const SizedBox(height: 40),
            const Text("Login", style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 24),
            const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600,
                fontSize: 13, color: AppTheme.textDark)),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                hintText: "10-digit mobile number",
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: "+91  ",
                counterText: "",
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200)),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13))),
                ])),
              const SizedBox(height: 16),
            ],
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(height: 16),
            Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don\'t have an account? ", style: TextStyle(color: AppTheme.textGrey)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text("Register", style: TextStyle(color: AppTheme.primary,
                    fontWeight: FontWeight.w700)),
              ),
            ])),
          ]),
        ),
      ),
    );
  }
}