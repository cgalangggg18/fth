import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmm/localization/app_localizations.dart';
import 'package:farmm/providers/user_provider.dart';
import 'package:farmm/screens/farmer_signup/account_details_screen.dart';
import 'package:farmm/screens/logistics_signup/logistics_account_details_screen.dart';
import 'package:farmm/screens/bulk_buyer_signup/buyer_account_details_screen.dart';
import 'package:farmm/services/auth_service.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_credentials_error'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _authService.login(
      _identifierController.text,
      _passwordController.text,
    );
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.translate('login_success'))),
      );
      // Navigate to home/dashboard
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context);
    final isFarmer = userProvider.selectedRole == UserRole.farmer;
    final isBulkBuyer = userProvider.selectedRole == UserRole.bulkBuyer;
    
    Color primaryColor;
    if (isFarmer) {
      primaryColor = const Color(0xFF4CAF50);
    } else if (isBulkBuyer) {
      primaryColor = const Color(0xFFF57C00);
    } else {
      primaryColor = const Color(0xFF03A9F4);
    }

    Color gradientStart;
    if (isFarmer) {
      gradientStart = const Color(0xFFE8F5E9);
    } else if (isBulkBuyer) {
      gradientStart = const Color(0xFFFFF3E0);
    } else {
      gradientStart = const Color(0xFFE1F5FE);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Character image
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person, size: 80, color: primaryColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.translate('welcome_caps'),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          label: l10n.translate('mobile_or_email'),
                          hint: l10n.translate('enter_mobile_email'),
                          controller: _identifierController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: l10n.translate('password_caps'),
                          hint: l10n.translate('enter_password_hint'),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              l10n.translate('forgot_password'),
                              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  l10n.translate('login_caps'),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.translate('new_to')),
                            GestureDetector(
                              onTap: () {
                                if (userProvider.selectedRole == UserRole.farmer) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AccountDetailsScreen()),
                                  );
                                } else if (userProvider.selectedRole == UserRole.logistics) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LogisticsAccountDetailsScreen()),
                                  );
                                } else if (userProvider.selectedRole == UserRole.bulkBuyer) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const BuyerAccountDetailsScreen()),
                                  );
                                }
                              },
                              child: Text(
                                l10n.translate('sign_up'),
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
