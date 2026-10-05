import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/bulk_buyer_registration_provider.dart';
import '../../services/registration_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_constants.dart';
import '../farmer_signup/mailbox_verification_screen.dart';

class ReviewSubmitScreen extends StatefulWidget {
  const ReviewSubmitScreen({super.key});

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  bool _isSubmitting = false;
  final Color _primaryColor = const Color(0xFFF57C00);

  Future<void> _handleSubmit(BulkBuyerRegistrationProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final model = provider.model;
    
    setState(() => _isSubmitting = true);

    final authService = AuthService();
    final otpSent = await authService.sendOTP(model.mobileNumber ?? '');

    if (!otpSent && mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('otp_failed')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success = await RegistrationService.submitRegistration(
      role: 'Bulk Buyer',
      data: model.toJson(),
    );
    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MailboxVerificationScreen(
              phoneNumber: model.mobileNumber ?? '',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        if (ApiConstants.baseUrl.contains('example.com')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MailboxVerificationScreen(
                phoneNumber: model.mobileNumber ?? '',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.translate('registration_failed'))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<BulkBuyerRegistrationProvider>(context);
    final model = provider.model;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${l10n.translate('step_x_of_y').replaceAll('{current}', '5').replaceAll('{total}', '5')} . ${l10n.translate('step_review').toUpperCase()}',
          style: TextStyle(color: _primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(l10n.translate('help').toUpperCase(), style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
                        child: Divider(
                          color: _primaryColor,
                          thickness: 4,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(l10n.translate('review_details'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l10n.translate('review_details_sub'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                
                _buildReviewSection(
                  l10n.translate('account_details').toUpperCase(),
                  [
                    _buildReviewRow(l10n.translate('email_address'), model.email ?? ''),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewSection(
                  l10n.translate('user_details').toUpperCase(),
                  [
                    _buildReviewRow(l10n.translate('full_name'), '${model.firstName} ${model.middleName ?? ''} ${model.lastName}'),
                    _buildReviewRow(l10n.translate('phone_caps'), model.mobileNumber ?? ''),
                    _buildReviewRow(l10n.translate('address'), '${model.personalStreetAddress ?? ''}, ${model.personalBarangay?.name ?? ''}, ${model.personalMunicipality?.name ?? ''}, ${model.personalProvince?.name ?? ''}'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewSection(
                  l10n.translate('business_details').toUpperCase(),
                  [
                    _buildReviewRow(l10n.translate('business_name'), model.businessName ?? ''),
                    _buildReviewRow(l10n.translate('address'), '${model.businessStreetAddress ?? ''}, ${model.businessBarangay?.name ?? ''}, ${model.businessMunicipality?.name ?? ''}, ${model.businessProvince?.name ?? ''}'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewSection(
                  l10n.translate('documents_verification').toUpperCase(),
                  [
                    _buildDocumentStatus(l10n.translate('national_id'), model.nationalIdPath != null),
                    _buildDocumentStatus(l10n.translate('biz_permit'), model.businessPermitPath != null),
                    _buildDocumentStatus(l10n.translate('bir_certificate'), model.birCertificatePath != null),
                    _buildDocumentStatus(l10n.translate('utility_bill').replaceAll(' :', ''), model.utilityBillPath != null),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _handleSubmit(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(l10n.translate('submit_caps'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.translate('cancel'), style: const TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Widget> children) {
    String capitalizedTitle = title.isEmpty ? title : title[0].toUpperCase() + title.substring(1).toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(capitalizedTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    String capitalizedLabel = label.isEmpty ? label : label[0].toUpperCase() + label.substring(1).toLowerCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(capitalizedLabel, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(String label, bool isUploaded) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Icon(
            isUploaded ? Icons.check_circle : Icons.error,
            size: 16,
            color: isUploaded ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isUploaded ? l10n.translate('uploaded') : l10n.translate('missing'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUploaded ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
