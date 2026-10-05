import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/user_provider.dart';

class ApprovalSuccessScreen extends StatelessWidget {
  const ApprovalSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context);
    
    // Determine the role name for the greeting
    String roleName = "User";
    if (userProvider.selectedRole == UserRole.farmer) {
      roleName = l10n.translate('farmer');
    } else if (userProvider.selectedRole == UserRole.logistics) {
      roleName = l10n.translate('logistics');
    } else if (userProvider.selectedRole == UserRole.bulkBuyer) {
      roleName = l10n.translate('bulk_buyer');
    }

    final isLogistics = userProvider.selectedRole == UserRole.logistics;
    final primaryColor = isLogistics ? const Color(0xFF03A9F4) : const Color(0xFF4CAF50);
    final secondaryColor = isLogistics ? const Color(0xFFE1F5FE) : const Color(0xFFE8F5E9);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.translate('complete_welcome'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.translate('welcome_title'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: primaryColor,
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      l10n.translate('account_approved'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('welcome_farmer').replaceAll('{name}', roleName),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to dashboard or home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.translate('done'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
