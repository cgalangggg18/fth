import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/logistics_registration_provider.dart';
import 'company_details_screen.dart';
import 'driver_documents_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  final _yearModelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _vinController = TextEditingController();
  final _maxLoadCapacityController = TextEditingController();

  final Color _primaryColor = const Color(0xFF03A9F4);

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleModelController.dispose();
    _vehicleBrandController.dispose();
    _yearModelController.dispose();
    _plateNumberController.dispose();
    _vinController.dispose();
    _maxLoadCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LogisticsRegistrationProvider>(context, listen: false);
    final isCompany = provider.model.isCompany;
    final totalSteps = isCompany ? 5 : 4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${l10n.translate('step_x_of_y').replaceAll('{current}', '3').replaceAll('{total}', totalSteps.toString())} . ${l10n.translate('vehicle_details')}',
          style: TextStyle(color: _primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(totalSteps, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == (totalSteps - 1) ? 0 : 4),
                      child: Divider(
                        color: index <= 2 ? _primaryColor : const Color(0xFFE0E0E0),
                        thickness: 4,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(l10n.translate('vehicle_details'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.translate('vehicle_details_sub'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              _buildDropdownField(l10n.translate('vehicle_type'), _vehicleTypeController, Icons.local_shipping_outlined, hint: l10n.translate('select_vehicle_type_hint')),
              _buildTextField(l10n.translate('vehicle_brand'), _vehicleBrandController, Icons.branding_watermark_outlined, hint: l10n.translate('enter_vehicle_brand_hint')),
              _buildTextField(l10n.translate('vehicle_model'), _vehicleModelController, Icons.model_training_outlined, hint: l10n.translate('enter_vehicle_model_hint')),
              _buildTextField(l10n.translate('year_model'), _yearModelController, Icons.calendar_today_outlined, hint: l10n.translate('enter_year_model_hint'), keyboardType: TextInputType.number),
              _buildTextField(l10n.translate('plate_number'), _plateNumberController, Icons.credit_card_outlined, hint: l10n.translate('enter_plate_number_hint')),
              _buildTextField(l10n.translate('vin'), _vinController, Icons.fingerprint_outlined, hint: l10n.translate('enter_vin_hint')),
              _buildTextField(l10n.translate('max_load'), _maxLoadCapacityController, Icons.monitor_weight_outlined, hint: l10n.translate('enter_max_load_hint'), keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    provider.updateVehicleDetails(
                      vehicleType: _vehicleTypeController.text,
                      vehicleModel: _vehicleModelController.text,
                      vehicleBrand: _vehicleBrandController.text,
                      yearModel: _yearModelController.text,
                      plateNumber: _plateNumberController.text,
                      vin: _vinController.text,
                      maxLoadCapacity: _maxLoadCapacityController.text,
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DriverDocumentsScreen()));
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
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryColor),
              hintText: hint ?? 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            validator: (value) => value == null || value.isEmpty ? AppLocalizations.of(context)!.translate('required') : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, IconData icon, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () {
              // Simulate selection
              controller.text = "Sample $label";
              setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryColor),
              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            validator: (value) => value == null || value.isEmpty ? AppLocalizations.of(context)!.translate('required') : null,
          ),
        ],
      ),
    );
  }
}
