import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/logistics_registration_provider.dart';
import '../../services/address_service.dart';
import '../../models/address/philippine_address_models.dart';
import 'vehicle_details_screen.dart';

class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({super.key});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _bizRegNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();

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
  String? _selectedBarangayCode;

  final Color _primaryColor = const Color(0xFF03A9F4);

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

  @override
  void dispose() {
    _companyNameController.dispose();
    _bizRegNoController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
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
          '${l10n.translate('step_x_of_y').replaceAll('{current}', '2').replaceAll('{total}', totalSteps.toString())} . ${l10n.translate('company_details')}',
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
                        color: index <= 1 ? _primaryColor : const Color(0xFFE0E0E0),
                        thickness: 4,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(l10n.translate('company_details'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.translate('company_details_sub'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n, l10n.translate('company_info')),
              _buildTextField(l10n.translate('company_name'), _companyNameController, Icons.business_outlined, hint: l10n.translate('enter_company_name_hint')),
              _buildTextField(l10n.translate('biz_reg_no'), _bizRegNoController, Icons.badge_outlined, hint: l10n.translate('enter_biz_reg_no_hint')),
              _buildTextField(l10n.translate('email_address'), _emailController, Icons.email_outlined, hint: l10n.translate('enter_email_hint'), keyboardType: TextInputType.emailAddress),
              _buildTextField(l10n.translate('contact_number'), _contactNumberController, Icons.phone_outlined, hint: l10n.translate('enter_company_contact_hint'), keyboardType: TextInputType.phone, maxLength: 11, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              
              const SizedBox(height: 24),
              _buildSectionHeader(l10n, l10n.translate('drivers_details')),
              _buildTextField(l10n.translate('first_name'), _firstNameController, Icons.person_outline, hint: l10n.translate('enter_first_name_hint')),
              _buildTextField(l10n.translate('middle_name'), _middleNameController, Icons.person_outline, hint: l10n.translate('enter_middle_name_hint')),
              _buildTextField(l10n.translate('last_name'), _lastNameController, Icons.person_outline, hint: l10n.translate('enter_last_name_hint')),
              _buildInteractiveDropdownField(l10n.translate('dob'), _dobController, Icons.calendar_today_outlined, hint: l10n.translate('select_dob_hint')),
              _buildInteractiveDropdownField(l10n.translate('gender'), _genderController, Icons.wc_outlined, hint: l10n.translate('select_gender_hint')),

              const SizedBox(height: 24),
              _buildSectionHeader(l10n, l10n.translate('address')),
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
              _buildTextField(l10n.translate('house_number_detailed'), _houseNumberController, Icons.home_outlined, hint: l10n.translate('enter_house_number_hint')),
              _buildTextField(l10n.translate('postal_code'), _postalCodeController, Icons.markunread_mailbox_outlined, hint: l10n.translate('enter_postal_code_hint'), readOnly: true),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    provider.updateCompanyDetails(
                      companyName: _companyNameController.text,
                      businessRegNumber: _bizRegNoController.text,
                      companyAddress: '${_houseNumberController.text}, ${_barangayController.text}, ${_municipalityController.text}, ${_provinceController.text}, ${_postalCodeController.text}',
                      email: _emailController.text,
                      contactNumber: _contactNumberController.text,
                    );
                    provider.updateDriverDetails(
                      firstName: _firstNameController.text,
                      middleName: _middleNameController.text,
                      lastName: _lastNameController.text,
                      dob: _dobController.text,
                      gender: _genderController.text,
                      country: _countryController.text,
                      region: _regionController.text,
                      regionCode: _selectedRegionCode,
                      province: _provinceController.text,
                      provinceCode: _selectedProvinceCode,
                      municipality: _municipalityController.text,
                      municipalityCode: _selectedMunicipalityCode,
                      barangay: _barangayController.text,
                      barangayCode: _selectedBarangayCode,
                      houseNumber: _houseNumberController.text,
                      postalCode: _postalCodeController.text,
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleDetailsScreen()));
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

  Widget _buildSectionHeader(AppLocalizations l10n, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildInteractiveDropdownField(String label, TextEditingController controller, IconData icon, {String? hint}) {
    final l10n = AppLocalizations.of(context)!;
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
            onTap: () async {
              if (label == l10n.translate('gender')) {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(title: const Text('Male'), onTap: () => Navigator.pop(context, 'Male')),
                      ListTile(title: const Text('Female'), onTap: () => Navigator.pop(context, 'Female')),
                    ],
                  ),
                );
                if (selected != null) {
                  setState(() => controller.text = selected);
                }
              } else if (label == l10n.translate('dob')) {
                final now = DateTime.now();
                final legalAgeDate = DateTime(now.year - 18, now.month, now.day);
                final date = await showDatePicker(
                  context: context,
                  initialDate: legalAgeDate,
                  firstDate: DateTime(1900),
                  lastDate: legalAgeDate,
                );
                if (date != null) {
                  setState(() => controller.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
                }
              }
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {String? hint, TextInputType? keyboardType, int? maxLength, List<TextInputFormatter>? inputFormatters, bool readOnly = false}) {
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
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryColor),
              hintText: hint ?? 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              counterText: "",
              filled: readOnly,
              fillColor: readOnly ? Colors.grey.shade100 : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.translate('required');
              }
              if (label == AppLocalizations.of(context)!.translate('email_address')) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) return AppLocalizations.of(context)!.translate('valid_email_error');
              }
              if (label == AppLocalizations.of(context)!.translate('contact_number')) {
                if (value.length != 11) {
                  return AppLocalizations.of(context)!.translate('invalid_phone');
                }
              }
              return null;
            },
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
