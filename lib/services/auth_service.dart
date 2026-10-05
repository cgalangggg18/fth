import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static String? _lastGeneratedOTP;
  static String? get lastGeneratedOTP => _lastGeneratedOTP;

  /// Generates an 8-character alphanumeric code for the backend
  Future<bool> sendOTP(String identifier) async {
    try {
      debugPrint('--- [GENERATING VERIFICATION CODE] ---');
      
      // Generate 8-character alphanumeric OTP (e.g., 4B6UADGC)
      final otp = List.generate(8, (index) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        return chars[Random().nextInt(chars.length)];
      }).join();
      
      _lastGeneratedOTP = otp;
      debugPrint('Generated Code: $otp');
      
      // Since we are removing TextBee, we just return true here.
      // The code will be sent to the database during the registration submit step.
      return true;
    } catch (e) {
      debugPrint('❌ Error generating code: $e');
      return false;
    }
  }

  /// Locally verifies the OTP (Optional fallback)
  Future<bool> verifyOTP(String identifier, String code) async {
    if (code.isEmpty) return false;
    return (_lastGeneratedOTP != null && code.toUpperCase() == _lastGeneratedOTP);
  }

  static Map<String, String> authenticatedHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static bool isAuthenticated = false;

  Future<bool> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'username': identifier,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        isAuthenticated = true;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
