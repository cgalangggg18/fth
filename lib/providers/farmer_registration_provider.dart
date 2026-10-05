import 'package:flutter/material.dart';
import '../models/farmer_registration_model.dart';

class FarmerRegistrationProvider with ChangeNotifier {
  final FarmerRegistrationModel _model = FarmerRegistrationModel();

  FarmerRegistrationModel get model => _model;

  void updateAccountDetails({
    String? phoneNumber,
    String? email,
    String? username,
    String? password,
  }) {
    if (phoneNumber != null) _model.phoneNumber = phoneNumber;
    if (email != null) _model.email = email;
    if (username != null) _model.username = username;
    if (password != null) _model.password = password;
    notifyListeners();
  }

  void updateUserDetails({
    String? firstName,
    String? middleName,
    String? lastName,
    String? country,
    String? region,
    String? regionCode,
    String? province,
    String? provinceCode,
    String? municipality,
    String? municipalityCode,
    String? barangay,
    String? barangayCode,
    String? streetAddress,
    String? houseNumber,
    String? postalCode,
  }) {
    if (firstName != null) _model.firstName = firstName;
    if (middleName != null) _model.middleName = middleName;
    if (lastName != null) _model.lastName = lastName;
    if (country != null) _model.userCountry = country;
    if (region != null) _model.userRegion = region;
    if (regionCode != null) _model.userRegionCode = regionCode;
    if (province != null) _model.userProvince = province;
    if (provinceCode != null) _model.userProvinceCode = provinceCode;
    if (municipality != null) _model.userMunicipality = municipality;
    if (municipalityCode != null) _model.userMunicipalityCode = municipalityCode;
    if (barangay != null) _model.userBarangay = barangay;
    if (barangayCode != null) _model.userBarangayCode = barangayCode;
    if (streetAddress != null) _model.userStreetAddress = streetAddress;
    if (houseNumber != null) _model.userHouseNumber = houseNumber;
    if (postalCode != null) _model.userPostalCode = postalCode;
    notifyListeners();
  }

  void updateFarmDetails({
    String? farmSize,
    String? country,
    String? region,
    String? regionCode,
    String? province,
    String? provinceCode,
    String? municipality,
    String? municipalityCode,
    String? barangay,
    String? barangayCode,
    String? streetAddress,
    String? houseNumber,
    String? postalCode,
  }) {
    if (farmSize != null) _model.farmSize = farmSize;
    if (country != null) _model.farmCountry = country;
    if (region != null) _model.farmRegion = region;
    if (regionCode != null) _model.farmRegionCode = regionCode;
    if (province != null) _model.farmProvince = province;
    if (provinceCode != null) _model.farmProvinceCode = provinceCode;
    if (municipality != null) _model.farmMunicipality = municipality;
    if (municipalityCode != null) _model.farmMunicipalityCode = municipalityCode;
    if (barangay != null) _model.farmBarangay = barangay;
    if (barangayCode != null) _model.farmBarangayCode = barangayCode;
    if (streetAddress != null) _model.farmStreetAddress = streetAddress;
    if (houseNumber != null) _model.farmHouseNumber = houseNumber;
    if (postalCode != null) _model.farmPostalCode = postalCode;
    notifyListeners();
  }

  void updateDocumentStatus({
    String? utilityBill,
    String? validID,
    String? ownersAddressDoc,
    String? ownershipDocs,
  }) {
    if (utilityBill != null) _model.utilityBillPath = utilityBill;
    if (validID != null) _model.validIDPath = validID;
    if (ownersAddressDoc != null) _model.ownersAddressDocPath = ownersAddressDoc;
    if (ownershipDocs != null) _model.ownershipDocsPath = ownershipDocs;
    notifyListeners();
  }

  void setVerificationStatus(bool status) {
    _model.isVerified = status;
    notifyListeners();
  }
}
