import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../localization/app_localizations.dart';
import '../../providers/bulk_buyer_registration_provider.dart';
import 'review_submit_screen.dart';

class BuyerDocumentsScreen extends StatefulWidget {
  const BuyerDocumentsScreen({super.key});

  @override
  State<BuyerDocumentsScreen> createState() => _BuyerDocumentsScreenState();
}

class _BuyerDocumentsScreenState extends State<BuyerDocumentsScreen> {
  final Color _primaryColor = const Color(0xFFF57C00);
  final ImagePicker _picker = ImagePicker();

  void _viewImage(String path) {
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
                  const Text(
                    'Image Preview',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(path)
                      : Image.file(File(path)),
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

  Future<void> _pickImage(Function(String?) onFilePicked) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      onFilePicked(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<BulkBuyerRegistrationProvider>(context);

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
          '${l10n.translate('step_x_of_y').replaceAll('{current}', '4').replaceAll('{total}', '5')} . ${l10n.translate('documents').toUpperCase()}',
          style: TextStyle(color: _primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(l10n.translate('help'), style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      color: index <= 3 ? _primaryColor : const Color(0xFFE0E0E0),
                      thickness: 4,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(l10n.translate('documents_verification'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.translate('upload_docs_sub'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildUploadBox(l10n.translate('national_id').toUpperCase(), provider.model.nationalIdPath, () => _pickImage((path) => provider.updateDocuments(nationalId: path)), l10n.translate('tap_to_take_photo').toUpperCase()),
                _buildUploadBox(l10n.translate('biz_permit').toUpperCase(), provider.model.businessPermitPath, () => _pickImage((path) => provider.updateDocuments(businessPermit: path)), l10n.translate('tap_to_take_photo').toUpperCase()),
                _buildUploadBox(l10n.translate('bir_certificate').toUpperCase(), provider.model.birCertificatePath, () => _pickImage((path) => provider.updateDocuments(birCertificate: path)), l10n.translate('tap_to_take_photo').toUpperCase()),
                _buildUploadBox(l10n.translate('utility_bill').toUpperCase().replaceAll(':', ''), provider.model.utilityBillPath, () => _pickImage((path) => provider.updateDocuments(utilityBill: path)), l10n.translate('tap_to_take_photo').toUpperCase()),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (provider.model.areDocumentsUploaded) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReviewSubmitScreen()),
                  );
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
                backgroundColor: _primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.translate('continue'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  Widget _buildUploadBox(String label, String? filePath, VoidCallback onPick, String hint) {
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
                onTap: isUploaded ? () => _viewImage(filePath) : onPick,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isUploaded ? _primaryColor : Colors.grey.shade300, width: isUploaded ? 2 : 1),
                  ),
                  child: Center(
                    child: isUploaded
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(filePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : Image.file(File(filePath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: _primaryColor,
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (isUploaded)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onPick,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: _primaryColor.withOpacity(0.9),
                      child: const Icon(Icons.sync, size: 14, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
