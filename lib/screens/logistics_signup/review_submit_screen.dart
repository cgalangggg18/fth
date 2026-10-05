import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/logistics_registration_provider.dart';
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
  final Color _primaryColor = const Color(0xFF03A9F4);
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LogisticsRegistrationProvider>(context);
    final model = provider.model;
    final isCompany = model.isCompany;
    final totalSteps = isCompany ? 5 : 4;
    final currentStep = totalSteps;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${l10n.translate('step_x_of_y').replaceAll('{current}', currentStep.toString()).replaceAll('{total}', totalSteps.toString())} . ${l10n.translate('review_submit')}',
          style: TextStyle(color: _primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(totalSteps, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == (totalSteps - 1) ? 0 : 4),
                        child: Divider(
                          color: index <= (totalSteps - 1) ? _primaryColor : const Color(0xFFE0E0E0),
                          thickness: 4,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(l10n.translate('review_submit'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l10n.translate('review_submit_sub'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                
                _buildSectionHeader(l10n.translate('account_details')),
                _buildDetailRow(l10n.translate('phone_number'), model.accountPhoneNumber),
                _buildDetailRow(l10n.translate('email_address'), model.accountEmail),
                _buildDetailRow(l10n.translate('username'), model.username),
                const SizedBox(height: 24),

                if (isCompany) ...[
                  _buildSectionHeader(l10n.translate('company_info')),
                  _buildDetailRow(l10n.translate('company_name'), model.companyName),
                  _buildDetailRow(l10n.translate('biz_reg_no'), model.businessRegNumber),
                  _buildDetailRow(l10n.translate('email_address'), model.email),
                  _buildDetailRow(l10n.translate('contact_number'), model.contactNumber),
                  _buildDetailRow(l10n.translate('address'), model.companyAddress),
                  const SizedBox(height: 24),

                  _buildSectionHeader(l10n.translate('drivers_details')),
                  _buildDetailRow(l10n.translate('name'), model.fullName),
                  _buildDetailRow(l10n.translate('dob'), model.dob),
                  _buildDetailRow(l10n.translate('gender'), model.gender),
                  const SizedBox(height: 24),

                  _buildSectionHeader(l10n.translate('vehicle_details')),
                  _buildDetailRow(l10n.translate('vehicle_type'), model.vehicleType),
                  _buildDetailRow(l10n.translate('vehicle_brand'), model.vehicleBrand),
                  _buildDetailRow(l10n.translate('vehicle_model'), model.vehicleModel),
                  _buildDetailRow(l10n.translate('year_model'), model.yearModel),
                  _buildDetailRow(l10n.translate('plate_number'), model.plateNumber),
                  _buildDetailRow(l10n.translate('vin'), model.vin),
                  _buildDetailRow(l10n.translate('max_load'), model.maxLoadCapacity),
                  const SizedBox(height: 24),
                ] else ...[
                  _buildSectionHeader(l10n.translate('personal_info')),
                  _buildDetailRow(l10n.translate('name'), model.fullName),
                  _buildDetailRow(l10n.translate('dob'), model.dob),
                  _buildDetailRow(l10n.translate('gender'), model.gender),
                  _buildDetailRow(l10n.translate('street_address'), '${model.houseNumber}, ${model.barangay}, ${model.municipality}, ${model.province}, ${model.region}, ${model.country} ${model.postalCode}'),
                  const SizedBox(height: 24),

                  _buildSectionHeader(l10n.translate('vehicle_details')),
                  _buildDetailRow(l10n.translate('vehicle_type'), model.vehicleType),
                  _buildDetailRow(l10n.translate('vehicle_brand'), model.vehicleBrand),
                  _buildDetailRow(l10n.translate('vehicle_model'), model.vehicleModel),
                  _buildDetailRow(l10n.translate('year_model'), model.yearModel),
                  _buildDetailRow(l10n.translate('plate_number'), model.plateNumber),
                  _buildDetailRow(l10n.translate('vin'), model.vin),
                  _buildDetailRow(l10n.translate('max_load'), model.maxLoadCapacity),
                  const SizedBox(height: 24),
                ],

                _buildSectionHeader(l10n.translate('documents')),
                _buildDocStatus(l10n, l10n.translate('driver_license'), model.driverLicenseUploaded),
                if (model.isCompany) ...[
                  _buildDocStatus(l10n, l10n.translate('vehicle_documents'), model.areVehicleDocumentsUploaded),
                  _buildDocStatus(l10n, l10n.translate('company_documents'), model.areCompanyDocumentsUploaded),
                ],

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    setState(() => _isSubmitting = true);
                    
                    final authService = AuthService();
                    print('ReviewSubmitScreen: Triggering OTP for ${model.accountPhoneNumber}');
                    
                    // 1. Send SMS OTP via SMS2Connect
                    final otpSent = await authService.sendOTP(model.accountPhoneNumber);

                    if (!otpSent && context.mounted) {
                      setState(() => _isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.translate('sms_failed')),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // STOP HERE if OTP failed
                    }

                    // 2. Submit Registration Data
                    final success = await RegistrationService.submitRegistration(
                      role: 'Logistics',
                      data: model.toJson(),
                    );

                    if (success && context.mounted) {
                      setState(() => _isSubmitting = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MailboxVerificationScreen(
                            isLogistics: true,
                            phoneNumber: model.accountPhoneNumber,
                          ),
                        ),
                      );
                    } else if (context.mounted) {
                      setState(() => _isSubmitting = false);
                      // In development mode with placeholder URL, we still proceed
                      if (ApiConstants.baseUrl.contains('example.com')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MailboxVerificationScreen(
                              isLogistics: true,
                              phoneNumber: model.accountPhoneNumber,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.translate('registration_failed'))),
                        );
                      }
                    }
                  },
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
                      : Text(l10n.translate('submit_application'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    String capitalizedTitle = title.isEmpty ? title : title[0].toUpperCase() + title.substring(1).toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(capitalizedTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor)),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    String capitalizedLabel = label.isEmpty ? label : label[0].toUpperCase() + label.substring(1).toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(capitalizedLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocStatus(AppLocalizations l10n, String label, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(isComplete ? Icons.check_circle : Icons.error, color: isComplete ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(isComplete ? l10n.translate('uploaded') : l10n.translate('incomplete'), style: TextStyle(fontSize: 12, color: isComplete ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  bool _isDriverDocsComplete(dynamic model) {
    return model.driverLicenseUploaded && model.driverORUploaded && model.driverCRUploaded &&
           model.governmentIDUploaded && model.nbiClearanceUploaded && model.driverPhotoUploaded &&
           model.driverUtilityBillUploaded;
  }

  bool _isVehicleDocsComplete(dynamic model) {
    return model.vehicleORUploaded && model.vehicleCRUploaded && model.vehiclePhotoUploaded;
  }

  bool _isCompanyDocsComplete(dynamic model) {
    return model.businessPermitUploaded && model.birCertificateUploaded &&
           model.dtiSecCertificateUploaded && model.companyUtilityBillUploaded;
  }
}
