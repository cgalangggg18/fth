import 'package:flutter/material.dart';
import '../models/logistics_registration_model.dart';

class LogisticsRegistrationProvider with ChangeNotifier {
  final LogisticsRegistrationModel _model = LogisticsRegistrationModel();

  LogisticsRegistrationModel get model => _model;

  void setRegistrationType({required bool isCompany}) {
    _model.isCompany = isCompany;
    notifyListeners();
  }

  void updateAccountDetails({
    String? phoneNumber,
    String? email,
    String? username,
    String? password,
  }) {
    if (phoneNumber != null) _model.accountPhoneNumber = phoneNumber;
    if (email != null) _model.accountEmail = email;
    if (username != null) _model.username = username;
    if (password != null) _model.password = password;
    notifyListeners();
  }

  void updateDriverDetails({
    String? firstName,
    String? middleName,
    String? lastName,
    String? dob,
    String? gender,
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
    if (dob != null) _model.dob = dob;
    if (gender != null) _model.gender = gender;
    if (country != null) _model.country = country;
    if (region != null) _model.region = region;
    if (regionCode != null) _model.regionCode = regionCode;
    if (province != null) _model.province = province;
    if (provinceCode != null) _model.provinceCode = provinceCode;
    if (municipality != null) _model.municipality = municipality;
    if (municipalityCode != null) _model.municipalityCode = municipalityCode;
    if (barangay != null) _model.barangay = barangay;
    if (barangayCode != null) _model.barangayCode = barangayCode;
    if (streetAddress != null) _model.streetAddress = streetAddress;
    if (houseNumber != null) _model.houseNumber = houseNumber;
    if (postalCode != null) _model.postalCode = postalCode;
    notifyListeners();
  }

  void updateVehicleDetails({
    String? vehicleType,
    String? vehicleModel,
    String? vehicleBrand,
    String? yearModel,
    String? plateNumber,
    String? vin,
    String? maxLoadCapacity,
  }) {
    if (vehicleType != null) _model.vehicleType = vehicleType;
    if (vehicleModel != null) _model.vehicleModel = vehicleModel;
    if (vehicleBrand != null) _model.vehicleBrand = vehicleBrand;
    if (yearModel != null) _model.yearModel = yearModel;
    if (plateNumber != null) _model.plateNumber = plateNumber;
    if (vin != null) _model.vin = vin;
    if (maxLoadCapacity != null) _model.maxLoadCapacity = maxLoadCapacity;
    notifyListeners();
  }

  void updateCompanyDetails({
    String? companyName,
    String? businessRegNumber,
    String? companyAddress,
    String? email,
    String? contactNumber,
  }) {
    if (companyName != null) _model.companyName = companyName;
    if (businessRegNumber != null) _model.businessRegNumber = businessRegNumber;
    if (companyAddress != null) _model.companyAddress = companyAddress;
    if (email != null) _model.email = email;
    if (contactNumber != null) _model.contactNumber = contactNumber;
    notifyListeners();
  }

  void updateDocumentStatus({
    String? driverLicense,
    String? governmentID,
    String? nbiClearance,
    String? driverPhoto,
    String? driverUtilityBill,
    String? vehicleOR,
    String? vehicleCR,
    String? vehiclePhoto,
    String? businessPermit,
    String? birCertificate,
    String? dtiSecCertificate,
    String? companyUtilityBill,
  }) {
    if (driverLicense != null) _model.driverLicensePath = driverLicense;
    if (governmentID != null) _model.governmentIDPath = governmentID;
    if (nbiClearance != null) _model.nbiClearancePath = nbiClearance;
    if (driverPhoto != null) _model.driverPhotoPath = driverPhoto;
    if (driverUtilityBill != null) _model.driverUtilityBillPath = driverUtilityBill;
    if (vehicleOR != null) _model.vehicleORPath = vehicleOR;
    if (vehicleCR != null) _model.vehicleCRPath = vehicleCR;
    if (vehiclePhoto != null) _model.vehiclePhotoPath = vehiclePhoto;
    if (businessPermit != null) _model.businessPermitPath = businessPermit;
    if (birCertificate != null) _model.birCertificatePath = birCertificate;
    if (dtiSecCertificate != null) _model.dtiSecCertificatePath = dtiSecCertificate;
    if (companyUtilityBill != null) _model.companyUtilityBillPath = companyUtilityBill;
    notifyListeners();
  }

  void setVerificationStatus(bool status) {
    _model.isVerified = status;
    notifyListeners();
  }
}
