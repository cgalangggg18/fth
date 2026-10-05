import 'package:flutter/material.dart';

enum UserRole { farmer, logistics, bulkBuyer }

class UserProvider with ChangeNotifier {
  UserRole? _selectedRole;

  UserRole? get selectedRole => _selectedRole;

  void setRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }
}
