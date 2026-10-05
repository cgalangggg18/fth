class FarmerRegistrationModel {
  String phoneNumber = '';
  String email = '';
  String username = '';
  String password = '';

  String firstName = '';
  String middleName = '';
  String lastName = '';
  String userCountry = '';
  String userRegion = '';
  String userRegionCode = '';
  String userProvince = '';
  String userProvinceCode = '';
  String userMunicipality = '';
  String userMunicipalityCode = '';
  String userBarangay = '';
  String userBarangayCode = '';
  String userStreetAddress = '';
  String userHouseNumber = '';
  String userPostalCode = '';

  String farmSize = '';
  String farmCountry = '';
  String farmRegion = '';
  String farmRegionCode = '';
  String farmProvince = '';
  String farmProvinceCode = '';
  String farmMunicipality = '';
  String farmMunicipalityCode = '';
  String farmBarangay = '';
  String farmBarangayCode = '';
  String farmStreetAddress = '';
  String farmHouseNumber = '';
  String farmPostalCode = '';

  // File paths
  String? utilityBillPath;
  String? validIDPath;
  String? ownersAddressDocPath;
  String? ownershipDocsPath;

  bool isVerified = false; // Added to track verification status

  bool get utilityBillUploaded => utilityBillPath != null;
  bool get validIDUploaded => validIDPath != null;
  bool get ownersAddressDocUploaded => ownersAddressDocPath != null;
  bool get ownershipDocsUploaded => ownershipDocsPath != null;

  bool get isComplete {
    return phoneNumber.isNotEmpty &&
        email.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        userBarangay.isNotEmpty &&
        userMunicipality.isNotEmpty &&
        farmSize.isNotEmpty &&
        farmBarangay.isNotEmpty &&
        farmMunicipality.isNotEmpty &&
        utilityBillUploaded &&
        validIDUploaded &&
        ownersAddressDocUploaded &&
        ownershipDocsUploaded;
  }


  String get fullName => '$firstName $middleName $lastName'.trim().replaceAll('  ', ' ');

  Map<String, dynamic> toJson() {
    final List<String> docs = [];
    final List<String> docTypes = [];

    if (utilityBillPath != null && utilityBillPath!.isNotEmpty) {
      docs.add(utilityBillPath!);
      docTypes.add('Utility Bills');
    }
    if (validIDPath != null && validIDPath!.isNotEmpty) {
      docs.add(validIDPath!);
      docTypes.add('Valid_ID');
    }
    if (ownersAddressDocPath != null && ownersAddressDocPath!.isNotEmpty) {
      docs.add(ownersAddressDocPath!);
      docTypes.add('Owner_Address');
    }
    if (ownershipDocsPath != null && ownershipDocsPath!.isNotEmpty) {
      docs.add(ownershipDocsPath!);
      docTypes.add('Farm_Ownership');
    }

    String formattedPhone = phoneNumber.trim();
    String digits = formattedPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '63${digits.substring(1)}';
    if (digits.length == 10 && !digits.startsWith('63')) digits = '63$digits';
    if (digits.isNotEmpty) formattedPhone = '+$digits';

    return {
      'phonenumber': formattedPhone,
      if (email.isNotEmpty) 'email': email,
      'username': username,
      'password': password,
      'firstname': firstName,
      if (middleName.isNotEmpty) 'middlename': middleName,
      'lastname': lastName,
      'role': 'Farmer',
      // Flattened Address fields
      'region': userRegion,
      'province': userProvince,
      'municipality': userMunicipality,
      'baranggay': userBarangay,
      'house_number': userHouseNumber,
      'street': userStreetAddress,
      'postal_code': userPostalCode,
      // Flattened Farm fields
      'farm_size': farmSize,
      'farm_region': farmRegion,
      'farm_province': farmProvince,
      'farm_municipality': farmMunicipality,
      'farm_barangay': farmBarangay,
      'farm_house_number': farmHouseNumber,
      'farm_street': farmStreetAddress,
      'farm_postal_code': farmPostalCode,
      // Documents and Document Types
      'documents': docs,
      'document_types': docTypes,
    };
  }
}
