import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../services/registration_service.dart';
import '../../services/api_constants.dart';
import '../../services/auth_service.dart';
import 'approval_success_screen.dart';
import 'user_details_screen.dart';
import '../logistics_signup/drivers_details_screen.dart';

class MailboxVerificationScreen extends StatefulWidget {
  final bool isLogistics;
  final String? phoneNumber;
  const MailboxVerificationScreen({super.key, this.isLogistics = false, this.phoneNumber});

  @override
  State<MailboxVerificationScreen> createState() => _MailboxVerificationScreenState();
}

class _MailboxVerificationScreenState extends State<MailboxVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(8, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(8, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final l10n = AppLocalizations.of(context)!;
    String code = _otpControllers.map((c) => c.text).join();
    
    if (code.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_8_digit_error'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Always use the backend verification service
    // Pass phoneNumber as identifier if it exists, otherwise it will try email-based flow
    bool success = await RegistrationService.verifyMailboxCode(
      code, 
      identifier: widget.phoneNumber
    );
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ApprovalSuccessScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('invalid_code'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context);
    final isLogistics = widget.isLogistics || userProvider.selectedRole == UserRole.logistics;
    final themeColor = isLogistics ? const Color(0xFF03A9F4) : const Color(0xFF4CAF50);
    final bannerColor = isLogistics ? const Color(0xFF0288D1) : const Color(0xFF388E3C);
    
    // This screen is now only used for the final verification step
    int currentStep = isLogistics ? 7 : 4;
    int totalSteps = isLogistics ? 7 : 4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('step_x_of_y').replaceAll('{current}', '$currentStep').replaceAll('{total}', '$totalSteps'),
          style: TextStyle(color: themeColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(l10n.translate('help'), style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: List.generate(isLogistics ? 7 : 4, (index) => 
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == (isLogistics ? 6 : 3) ? 0 : 4),
                    child: Divider(color: themeColor, thickness: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.translate('check_mailbox'),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('mailbox_sub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.translate('enter_verification_code'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                GestureDetector(
                  onTap: () async {
                    if (widget.phoneNumber != null) {
                      await AuthService().sendOTP(widget.phoneNumber!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP Resent via SMS')),
                        );
                      }
                    }
                  },
                  child: Text(
                    l10n.translate('resend_otp'),
                    style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(8, (index) => _buildOTPBox(index, themeColor)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
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
                      l10n.translate('verify_login'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index, Color themeColor) {
    bool hasValue = _otpControllers[index].text.isNotEmpty;
    return Container(
      width: 40,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasValue ? themeColor : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters, // Force uppercase keyboard
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          hintText: "-",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Automatically convert to uppercase if typed manually
            if (value != value.toUpperCase()) {
              _otpControllers[index].text = value.toUpperCase();
              _otpControllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _otpControllers[index].text.length),
              );
            }
            if (index < 7) {
              _focusNodes[index + 1].requestFocus();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }
}
