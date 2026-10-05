import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/farmer_registration_provider.dart';
import '../../services/address_service.dart';
import '../../models/address/philippine_address_models.dart';
import 'upload_documents_screen.dart';

class FarmDetailsScreen extends StatefulWidget {
  const FarmDetailsScreen({super.key});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmSizeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Philippines');
  final _regionController = TextEditingController();
  final _provinceController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();

  final AddressService _addressService = AddressService();
  List<Region> _regions = [];
  List<Province> _provinces = [];
  List<Municipality> _municipalities = [];
  List<Barangay> _barangays = [];

  String? _selectedRegionCode;
  String? _selectedProvinceCode;
  String? _selectedMunicipalityCode;

  final Color _primaryColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final regions = await _addressService.getRegions();
      setState(() {
        _regions = regions;
      });
      if (regions.isNotEmpty) {
        _onRegionChanged(regions.first);
      }
    } catch (e) {
      debugPrint('Error loading regions: $e');
    }
  }

  Future<void> _onRegionChanged(Region region) async {
    setState(() {
      _regionController.text = region.name;
      _selectedRegionCode = region.code;
      _provinceController.clear();
      _municipalityController.clear();
      _barangayController.clear();
      _postalCodeController.clear();
      _provinces = [];
      _municipalities = [];
      _barangays = [];
    });
    try {
      final provinces = await _addressService.getProvinces(region.code);
      setState(() {
        _provinces = provinces;
      });
      if (provinces.isNotEmpty) {
        _onProvinceChanged(provinces.first);
      }
    } catch (e) {
      debugPrint('Error loading provinces: $e');
    }
  }

  Future<void> _onProvinceChanged(Province province) async {
    setState(() {
      _provinceController.text = province.name;
      _selectedProvinceCode = province.code;
      _municipalityController.clear();
      _barangayController.clear();
      _postalCodeController.clear();
      _municipalities = [];
      _barangays = [];
    });
    try {
      final municipalities = await _addressService.getMunicipalities(province.code);
      setState(() {
        _municipalities = municipalities;
      });
      if (municipalities.isNotEmpty) {
        _onMunicipalityChanged(municipalities.first);
      }
    } catch (e) {
      debugPrint('Error loading municipalities: $e');
    }
  }

  Future<void> _onMunicipalityChanged(Municipality municipality) async {
    setState(() {
      _municipalityController.text = municipality.name;
      _selectedMunicipalityCode = municipality.code;
      _barangayController.clear();
      _postalCodeController.text = _addressService.getPostalCode(municipality.name);
      _barangays = [];
    });
    try {
      final barangays = await _addressService.getBarangays(municipality.code);
      setState(() {
        _barangays = barangays;
      });
    } catch (e) {
      debugPrint('Error loading barangays: $e');
    }
  }

  String? _selectedBarangayCode;

  @override
  void dispose() {
    _farmSizeController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _provinceController.dispose();
    _municipalityController.dispose();
    _barangayController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<FarmerRegistrationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${l10n.translate('step_x_of_y').replaceAll('{current}', '3').replaceAll('{total}', '5')} . ${l10n.translate('farm_details')}',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
                      child: Divider(
                        color: index <= 2 ? _primaryColor : const Color(0xFFE0E0E0),
                        thickness: 4,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(l10n.translate('farm_details'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.translate('farm_details_sub'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              _buildTextField(l10n.translate('farm_size'), _farmSizeController, Icons.agriculture, hint: 'e.g. 15.5'),
              _buildDropdownField<Region>(
                l10n.translate('region'),
                _regionController,
                Icons.layers_outlined,
                items: _regions,
                itemLabel: (r) => r.name,
                onChanged: _onRegionChanged,
                hint: l10n.translate('select_region_hint'),
              ),
              _buildDropdownField<Province>(
                l10n.translate('province'),
                _provinceController,
                Icons.map_outlined,
                items: _provinces,
                itemLabel: (p) => p.name,
                onChanged: _onProvinceChanged,
                hint: l10n.translate('select_province_hint'),
                enabled: _provinces.isNotEmpty,
              ),
              _buildDropdownField<Municipality>(
                l10n.translate('municipality_city'),
                _municipalityController,
                Icons.location_city_outlined,
                items: _municipalities,
                itemLabel: (m) => m.name,
                onChanged: _onMunicipalityChanged,
                hint: l10n.translate('select_municipality_hint'),
                enabled: _municipalities.isNotEmpty,
              ),
              _buildDropdownField<Barangay>(
                l10n.translate('barangay'),
                _barangayController,
                Icons.location_on_outlined,
                items: _barangays,
                itemLabel: (b) => b.name,
                onChanged: (b) {
                  setState(() {
                    _barangayController.text = b.name;
                    _selectedBarangayCode = b.code;
                  });
                },
                hint: l10n.translate('select_barangay_hint'),
                enabled: _barangays.isNotEmpty,
              ),
              _buildTextField(l10n.translate('street_address'), _streetController, Icons.add_road_outlined, hint: 'e.g. Purok 4'),
              _buildTextField(l10n.translate('house_number_detailed'), _houseNumberController, Icons.home_outlined, hint: l10n.translate('enter_house_number_hint')),
              _buildTextField(l10n.translate('postal_code'), _postalCodeController, Icons.markunread_mailbox_outlined, hint: l10n.translate('enter_postal_code_hint'), readOnly: true),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    provider.updateFarmDetails(
                      farmSize: _farmSizeController.text,
                      country: _countryController.text,
                      region: _regionController.text,
                      regionCode: _selectedRegionCode,
                      province: _provinceController.text,
                      provinceCode: _selectedProvinceCode,
                      municipality: _municipalityController.text,
                      municipalityCode: _selectedMunicipalityCode,
                      barangay: _barangayController.text,
                      barangayCode: _selectedBarangayCode,
                      streetAddress: _streetController.text,
                      houseNumber: _houseNumberController.text,
                      postalCode: _postalCodeController.text,
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadDocumentsScreen()));
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {String? hint, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryColor),
              hintText: hint ?? 'e.g. 15.5',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: readOnly,
              fillColor: readOnly ? Colors.grey.shade100 : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            validator: (value) => value == null || value.isEmpty ? AppLocalizations.of(context)!.translate('required') : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    TextEditingController controller,
    IconData icon, {
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T) onChanged,
    String? hint,
    bool enabled = true,
  }) {
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
            enabled: enabled,
            onTap: enabled
                ? () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return ListTile(
                                    title: Text(itemLabel(item)),
                                    onTap: () {
                                      onChanged(item);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: enabled ? _primaryColor : Colors.grey),
              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: !enabled,
              fillColor: enabled ? null : Colors.grey.shade100,
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
