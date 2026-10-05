import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/logistics_registration_provider.dart';
import 'drivers_details_screen.dart';
import 'company_details_screen.dart';
import '../../services/auth_service.dart';
import '../farmer_signup/mailbox_verification_screen.dart';

class LogisticsAccountDetailsScreen extends StatefulWidget {
  const LogisticsAccountDetailsScreen({super.key});

  @override
  State<LogisticsAccountDetailsScreen> createState() => _LogisticsAccountDetailsScreenState();
}

class _LogisticsAccountDetailsScreenState extends State<LogisticsAccountDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCompany = true;
  final Color _primaryColor = const Color(0xFF03A9F4);

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LogisticsRegistrationProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1F5FE), Colors.white],
            stops: [0.0, 0.3],
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, size: 80, color: Color(0xFF03A9F4)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.translate('welcome_caps'),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                        Text(
                          l10n.translate('register_manage_farm').replaceAll('farm', 'logistics'),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCompany = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isCompany ? _primaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _isCompany ? _primaryColor : Colors.grey.shade300),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Company',
                                      style: TextStyle(
                                        color: _isCompany ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCompany = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isCompany ? _primaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: !_isCompany ? _primaryColor : Colors.grey.shade300),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Individual Driver',
                                      style: TextStyle(
                                        color: !_isCompany ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: l10n.translate('phone_caps'),
                          hint: l10n.translate('enter_phone_hint'),
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        _buildTextField(
                          label: l10n.translate('email_address'),
                          hint: l10n.translate('enter_email_hint'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          label: l10n.translate('username_caps'),
                          hint: l10n.translate('enter_username_hint'),
                          controller: _usernameController,
                        ),
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
                        _buildTextField(
                          label: l10n.translate('re_enter_password_caps'),
                          hint: l10n.translate('re_enter_password_caps'),
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              provider.setRegistrationType(isCompany: _isCompany);
                              provider.updateAccountDetails(
                                phoneNumber: _phoneController.text,
                                email: _emailController.text,
                                username: _usernameController.text,
                                password: _passwordController.text,
                              );
                              
                              if (_isCompany) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CompanyDetailsScreen()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DriversDetailsScreen()),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                l10n.translate('continue_caps'),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
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
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon,
              counterText: "",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.translate('required');
              if (controller == _phoneController) {
                if (value.length != 11) {
                  return l10n.translate('invalid_phone');
                }
              }
              if (controller == _emailController) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) return l10n.translate('valid_email_error');
              }
              if (controller == _passwordController) {
                if (value.length < 6) return 'Password must be at least 6 characters';
              }
              if (controller == _confirmPasswordController && value != _passwordController.text) {
                return l10n.translate('passwords_not_match');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
