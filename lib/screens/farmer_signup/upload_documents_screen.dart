import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../localization/app_localizations.dart';
import '../../providers/farmer_registration_provider.dart';
import 'review_submit_screen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isManualEditMode = false; // To track if user clicked 'Edit' when verified

  void _viewFile(String path, bool isPdf) {
    String fileName = "Uploaded Document";
    try {
      fileName = path.split(RegExp(r'[/\\]')).last;
      if (fileName.length > 60) fileName = "Document Content";
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
              color: const Color(0xFF4CAF50),
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
                  backgroundColor: const Color(0xFF4CAF50),
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
    final provider = Provider.of<FarmerRegistrationProvider>(context);

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
              : '${l10n.translate('step_x_of_y').replaceAll('{current}', '3').replaceAll('{total}', '5')} . ${l10n.translate('step_farmers')}',
          style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (provider.model.isVerified)
            IconButton(
              icon: Icon(_isManualEditMode ? Icons.close : Icons.edit, color: const Color(0xFF4CAF50)),
              onPressed: () {
                setState(() {
                  _isManualEditMode = !_isManualEditMode;
                });
              },
            ),
          TextButton(
            onPressed: () {},
            child: Text(l10n.translate('help'), style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('account_verified'),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (!provider.model.isVerified)
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFF4CAF50), thickness: 4)),
                  SizedBox(width: 4),
                  Expanded(child: Divider(color: Color(0xFF4CAF50), thickness: 4)),
                  SizedBox(width: 4),
                  Expanded(child: Divider(color: Color(0xFF4CAF50), thickness: 4)),
                  SizedBox(width: 4),
                  Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 4)),
                  SizedBox(width: 4),
                  Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 4)),
                ],
              ),
            const SizedBox(height: 24),
            Text(l10n.translate('upload_documents'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                _buildUploadBox(l10n, l10n.translate('utility_bill'), provider.model.utilityBillPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(utilityBill: path)), l10n.translate('upload_hint'), isPdf: false, isReadOnly: provider.model.isVerified && !_isManualEditMode),
                _buildUploadBox(l10n, l10n.translate('valid_id'), provider.model.validIDPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(validID: path)), l10n.translate('upload_hint'), isReadOnly: provider.model.isVerified && !_isManualEditMode),
                _buildUploadBox(l10n, l10n.translate('owners_address'), provider.model.ownersAddressDocPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(ownersAddressDoc: path)), l10n.translate('upload_hint'), isPdf: false, isReadOnly: provider.model.isVerified && !_isManualEditMode),
                _buildUploadBox(l10n, l10n.translate('farm_ownership_docs'), provider.model.ownershipDocsPath, () => _pickFile(context, false, (path) => provider.updateDocumentStatus(ownershipDocs: path)), l10n.translate('upload_hint'), isPdf: false, isReadOnly: provider.model.isVerified && !_isManualEditMode),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: provider.model.isVerified ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(provider.model.isVerified ? Icons.verified_user : Icons.info, color: provider.model.isVerified ? Colors.green : Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.model.isVerified 
                          ? l10n.translate('doc_verified_notice')
                          : l10n.translate('doc_verification_hint'),
                      style: TextStyle(fontSize: 12, color: provider.model.isVerified ? Colors.green.shade700 : Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (!provider.model.isVerified || _isManualEditMode)
              ElevatedButton(
                onPressed: () {
                  if (provider.model.utilityBillUploaded &&
                      provider.model.validIDUploaded &&
                      provider.model.ownersAddressDocUploaded &&
                      provider.model.ownershipDocsUploaded) {
                    if (_isManualEditMode) {
                      setState(() {
                        _isManualEditMode = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translate('documents_updated'))),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReviewSubmitScreen(),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.translate('please_upload_all_docs')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
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
                child: Text(l10n.translate('back_to_profile'), style: const TextStyle(color: Colors.grey)),
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
                    border: Border.all(color: isUploaded ? const Color(0xFF4CAF50) : Colors.grey.shade300, width: isUploaded ? 2 : 1),
                  ),
                  child: Center(
                    child: isUploaded && !isPdf
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(filePath!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : Image.file(File(filePath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPdf ? Icons.insert_drive_file : Icons.camera_alt,
                                color: isUploaded ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isUploaded ? 'TAP TO VIEW' : hint,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 9, color: isUploaded ? const Color(0xFF4CAF50) : Colors.grey, fontWeight: FontWeight.bold),
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
                      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
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
                    child: const Icon(Icons.verified, size: 18, color: Color(0xFF4CAF50)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

