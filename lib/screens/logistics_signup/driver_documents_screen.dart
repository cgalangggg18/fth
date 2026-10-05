import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../localization/app_localizations.dart';
import '../../providers/logistics_registration_provider.dart';
import 'company_documents_screen.dart';
import 'review_submit_screen.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final Color _primaryColor = const Color(0xFF03A9F4);
  final ImagePicker _picker = ImagePicker();
  bool _isManualEditMode = false;

  void _viewFile(String path, bool isPdf) {
    String fileName = "Uploaded Document";
    try {
      // Handle both Windows and Unix paths
      fileName = path.split(RegExp(r'[/\\]')).last;
      // If the "filename" is too long, it's likely raw data or a very long path
      if (fileName.length > 60) {
        fileName = "Document Content";
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _primaryColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPdf ? 'PDF Document' : 'Image Preview',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPdf) ...[
                      const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(
                        fileName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'In-app PDF viewing is not supported. This document is ready for upload.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ] else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(
                                path,
                                errorBuilder: (context, error, stackTrace) => _buildErrorWidget(fileName),
                              )
                            : Image.file(
                                File(path),
                                errorBuilder: (context, error, stackTrace) => _buildErrorWidget(fileName),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Back to Documents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String fileName) {
    return Column(
      children: [
        const Icon(Icons.broken_image, size: 80, color: Colors.grey),
        const SizedBox(height: 8),
        const Text('Could not load image preview', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(fileName, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }

  Future<void> _pickFile(BuildContext context, bool isPdf, Function(String?) onFilePicked) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      onFilePicked(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LogisticsRegistrationProvider>(context);
    final isCompany = provider.model.isCompany;
    final totalSteps = isCompany ? 5 : 4;
    final currentStep = isCompany ? 4 : 4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          provider.model.isVerified 
              ? l10n.translate('verified_documents') 
              : '${l10n.translate('step_x_of_y').replaceAll('{current}', currentStep.toString()).replaceAll('{total}', totalSteps.toString())} . ${l10n.translate('driver_documents')}',
          style: TextStyle(color: _primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (provider.model.isVerified)
            IconButton(
              icon: Icon(_isManualEditMode ? Icons.close : Icons.edit, color: _primaryColor),
              onPressed: () {
                setState(() {
                  _isManualEditMode = !_isManualEditMode;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.model.isVerified)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: _primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('account_verified'),
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (!provider.model.isVerified)
              Row(
                children: List.generate(totalSteps, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == (totalSteps - 1) ? 0 : 4),
                      child: Divider(
                        color: index <= (currentStep - 1) ? _primaryColor : const Color(0xFFE0E0E0),
                        thickness: 4,
                      ),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 24),
            Text(l10n.translate('driver_documents'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              provider.model.isVerified && !_isManualEditMode
                  ? l10n.translate('view_verified_docs_sub')
                  : l10n.translate('upload_documents_sub'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildUploadBox(l10n, l10n.translate('driver_license'), provider.model.driverLicensePath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(driverLicense: path)), l10n.translate('upload_license'), isReadOnly: provider.model.isVerified && !_isManualEditMode),
                if (isCompany) ...[
                  _buildUploadBox(l10n, l10n.translate('official_receipt'), provider.model.vehicleORPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(vehicleOR: path)), l10n.translate('upload_or'), isReadOnly: provider.model.isVerified && !_isManualEditMode),
                  _buildUploadBox(l10n, l10n.translate('cert_reg'), provider.model.vehicleCRPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(vehicleCR: path)), l10n.translate('upload_cr'), isReadOnly: provider.model.isVerified && !_isManualEditMode),
                  _buildUploadBox(l10n, l10n.translate('vehicle_photo'), provider.model.vehiclePhotoPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(vehiclePhoto: path)), l10n.translate('upload_vehicle'), isReadOnly: provider.model.isVerified && !_isManualEditMode),
                ],
              ],
            ),
            const SizedBox(height: 32),
            if (!provider.model.isVerified || _isManualEditMode)
              ElevatedButton(
                onPressed: () {
                  bool canContinue = false;
                  if (isCompany) {
                    canContinue = provider.model.driverLicenseUploaded && provider.model.areVehicleDocumentsUploaded;
                  } else {
                    canContinue = provider.model.areDriverDocumentsUploaded;
                  }

                  if (canContinue) {
                    if (_isManualEditMode) {
                      setState(() {
                        _isManualEditMode = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translate('documents_updated'))),
                      );
                    } else if (isCompany) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CompanyDocumentsScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewSubmitScreen()));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isCompany ? l10n.translate('please_upload_all_docs') : 'Please upload driver\'s license'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isManualEditMode ? l10n.translate('save_changes') : l10n.translate('continue'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  provider.model.isVerified ? l10n.translate('back_to_profile') : l10n.translate('cancel'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(AppLocalizations l10n, String label, String? filePath, VoidCallback onPick, String hint, {bool isPdf = false, bool isReadOnly = false}) {
    bool isUploaded = filePath != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              GestureDetector(
                onTap: isUploaded ? () => _viewFile(filePath!, isPdf) : (isReadOnly ? null : onPick),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isUploaded ? _primaryColor : Colors.grey.shade300, width: isUploaded ? 2 : 1),
                  ),
                  child: Center(
                    child: isUploaded && !isPdf
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb ? Image.network(filePath!, fit: BoxFit.cover, width: double.infinity, height: double.infinity) : Image.file(File(filePath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPdf ? Icons.insert_drive_file : Icons.camera_alt,
                                color: isUploaded ? _primaryColor : Colors.grey.shade400,
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isUploaded ? 'TAP TO VIEW' : hint,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 9, color: isUploaded ? _primaryColor : Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (isUploaded && !isReadOnly)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onPick,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: _primaryColor.withValues(alpha: 0.9),
                      child: const Icon(Icons.sync, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              if (isReadOnly && isUploaded)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.verified, size: 18, color: _primaryColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

