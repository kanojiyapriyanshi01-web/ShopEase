import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../providers/app_providers.dart";
import "../../routes/app_routes.dart";
import "../../theme/app_theme.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = "Please enter your name");
      return;
    }
    if (_phoneCtrl.text.trim().length != 10) {
      setState(() => _error = "Enter valid 10-digit phone number");
      return;
    }
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final err = await auth.registerWithPhone(
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(child: Column(children: [
                Container(width: 80, height: 80,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 42)),
                const SizedBox(height: 14),
                const Text("ShopEase", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                const Text("Create your account", style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
              ])),
              const SizedBox(height: 36),
              const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              TextField(controller: _nameCtrl, textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: "Enter your full name", prefixIcon: Icon(Icons.person_outlined))),
              const SizedBox(height: 18),
              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10,
                  decoration: const InputDecoration(hintText: "10-digit mobile number", prefixIcon: Icon(Icons.phone_outlined), prefixText: "+91  ", counterText: "")),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ])),
                const SizedBox(height: 16),
              ],
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(height: 16),
              Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Already have an account? ", style: TextStyle(color: AppTheme.textGrey)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text("Login", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                ),
              ])),
            ],
          ),
        ),
      ),
    );
  }
}