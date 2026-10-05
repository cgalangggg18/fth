class LogisticsRegistrationModel {
  bool isCompany = true;
  bool isVerified = false; // Added to track verification status

  // Step 0: Account Details
  String accountPhoneNumber = '';
  String accountEmail = '';
  String username = '';
  String password = '';

  // Step 1: Driver's Details
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String dob = '';
  String gender = '';
  String country = '';
  String region = '';
  String regionCode = '';
  String province = '';
  String provinceCode = '';
  String municipality = '';
  String municipalityCode = '';
  String barangay = '';
  String barangayCode = '';
  String streetAddress = '';
  String houseNumber = '';
  String postalCode = '';

  // Step 2: Vehicle Details
  String vehicleType = '';
  String vehicleModel = '';
  String vehicleBrand = '';
  String yearModel = '';
  String plateNumber = '';
  String vin = '';
  String maxLoadCapacity = '';

  // Step 3: Company Details
  String companyName = '';
  String businessRegNumber = '';
  String companyAddress = '';
  String email = '';
  String contactNumber = '';

  // Step 4: Driver Documents (File Paths)
  String? driverLicensePath;
  String? governmentIDPath;
  String? nbiClearancePath;
  String? driverPhotoPath;
  String? driverUtilityBillPath;

  bool get driverLicenseUploaded => driverLicensePath != null;
  bool get governmentIDUploaded => governmentIDPath != null;
  bool get nbiClearanceUploaded => nbiClearancePath != null;
  bool get driverPhotoUploaded => driverPhotoPath != null;
  bool get driverUtilityBillUploaded => driverUtilityBillPath != null;

  // Step 5: Vehicle Documents (File Paths)
  String? vehicleORPath;
  String? vehicleCRPath;
  String? vehiclePhotoPath;

  bool get vehicleORUploaded => vehicleORPath != null;
  bool get vehicleCRUploaded => vehicleCRPath != null;
  bool get vehiclePhotoUploaded => vehiclePhotoPath != null;

  // Step 6: Company Documents (File Paths)
  String? businessPermitPath;
  String? birCertificatePath;
  String? dtiSecCertificatePath;
  String? companyUtilityBillPath;

  bool get businessPermitUploaded => businessPermitPath != null;
  bool get birCertificateUploaded => birCertificatePath != null;
  bool get dtiSecCertificateUploaded => dtiSecCertificatePath != null;
  bool get companyUtilityBillUploaded => companyUtilityBillPath != null;

  bool get areDriverDocumentsUploaded =>
      isCompany 
          ? (driverLicenseUploaded && areVehicleDocumentsUploaded)
          : driverLicenseUploaded;

  bool get arePersonalDocumentsUploaded =>
      governmentIDUploaded &&
      nbiClearanceUploaded &&
      driverPhotoUploaded &&
      driverUtilityBillUploaded;

  bool get areVehicleDocumentsUploaded =>
      vehicleORUploaded && vehicleCRUploaded && vehiclePhotoUploaded;

  bool get areCompanyDocumentsUploaded =>
      businessPermitUploaded &&
      birCertificateUploaded &&
      dtiSecCertificateUploaded &&
      companyUtilityBillUploaded;

  String get fullName => '$firstName $middleName $lastName'.trim().replaceAll('  ', ' ');

  Map<String, dynamic> toJson() {
    return {
      // Flattened Account
      'phonenumber': accountPhoneNumber,
      'email': accountEmail,
      'username': username,
      'password': password,

      // Flattened Driver
      'firstname': firstName,
      'middlename': middleName,
      'lastname': lastName,
      'dob': dob,
      'gender': gender,
      'country': country,
      'region': region,
      'province': province,
      'municipality': municipality,
      'baranggay': barangay,
      'street': streetAddress,
      'house_number': houseNumber,
      'postal_code': postalCode,

      // Flattened Vehicle
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'vehicle_brand': vehicleBrand,
      'vehicle_year': yearModel,
      'vehicle_plate': plateNumber,
      'vehicle_vin': vin,
      'vehicle_capacity': maxLoadCapacity,

      // Flattened Company
      'company_name': companyName,
      'company_reg_number': businessRegNumber,
      'company_address': companyAddress,
      'company_email': email,
      'company_contact': contactNumber,

      // Documents kept in a flat map for the Service to handle
      'documents': {
        'driver_license': driverLicensePath,
        'gov_id': governmentIDPath,
        'nbi_clearance': nbiClearancePath,
        'driver_photo': driverPhotoPath,
        'driver_utility': driverUtilityBillPath,
        'vehicle_or': vehicleORPath,
        'vehicle_cr': vehicleCRPath,
        'vehicle_photo': vehiclePhotoPath,
        'business_permit': businessPermitPath,
        'bir_certificate': birCertificatePath,
        'dti_sec': dtiSecCertificatePath,
        'company_utility': companyUtilityBillPath,
      }
    };
  }
}
