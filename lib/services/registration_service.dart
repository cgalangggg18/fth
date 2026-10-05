import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'auth_service.dart';

class RegistrationService {
  static String? lastError;

  /// Submits the registration to the database at:
  /// https://fth-backend-f4y4.onrender.com/api/register/
  static Future<bool> submitRegistration({required String role, required Map<String, dynamic> data}) async {
    try {
      lastError = null;
      
      // 1. URL Setup
      String endpoint = ApiConstants.registerFarmerEndpoint; // /api/register/
      if (role == 'Logistics') endpoint = ApiConstants.registerLogisticsEndpoint;
      if (role == 'BulkBuyer' || role == 'Bulk Buyer') endpoint = ApiConstants.registerBulkBuyerEndpoint;

      final String fullUrl = '${ApiConstants.baseUrl}$endpoint';
      final Uri uri = Uri.parse(fullUrl);
      
      debugPrint('--- [DATABASE SUBMISSION] ---');
      debugPrint('Target URL: $fullUrl');

      // Check if there are local files to upload via Multipart
      bool hasLocalFiles = false;
      if (data['documents'] is List) {
        for (var doc in data['documents']) {
          if (doc != null &&
              doc.toString().isNotEmpty &&
              !doc.toString().startsWith('http://') &&
              !doc.toString().startsWith('https://')) {
            if (!kIsWeb && File(doc.toString()).existsSync()) {
              hasLocalFiles = true;
              break;
            }
          }
        }
      }

      // If Farmer registration has no local files (e.g. URLs/JSON payload), send as JSON POST directly
      if (role == 'Farmer' && !hasLocalFiles) {
        final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
        payload['role'] = 'Farmer';
        final currentOtp = AuthService.lastGeneratedOTP;
        if (currentOtp != null) {
          payload['verification_code'] = currentOtp;
          payload['otp'] = currentOtp;
        }

        if (payload.containsKey('phonenumber') && payload['phonenumber'] != null) {
          String cleanPhone = _cleanIdentifier(payload['phonenumber'].toString());
          payload['phonenumber'] = cleanPhone;
          payload['phone_number'] = cleanPhone;
        }

        debugPrint('Sending Farmer registration as JSON POST...');
        debugPrint('Payload: ${jsonEncode(payload)}');
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 90));

        debugPrint('Server Status: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ SUCCESS: Farmer data saved to database.');
          final otp = AuthService.lastGeneratedOTP;
          final identifier = payload['phone_number'] ?? payload['phonenumber'] ?? payload['email'];
          if (otp != null && identifier != null) {
            await verifyMailboxCode(otp, identifier: identifier.toString());
          }
          return true;
        } else {
          lastError = 'Server rejected data: ${response.body}';
          debugPrint('❌ FAILED: ${response.body}');
          return false;
        }
      }

      // 2. Prepare Multipart Request (for local file uploads or other roles)
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Accept': 'application/json'});

      // 3. Handle Verification Code and Phone Number (Backend mandatory keys)
      final currentOtp = AuthService.lastGeneratedOTP;
      if (currentOtp != null) {
        request.fields['verification_code'] = currentOtp;
        request.fields['otp'] = currentOtp; // Fallback
        debugPrint('Adding verification_code to registration: $currentOtp');
      }

      request.fields['role'] = role;

      // 4. Add Text Fields & Normalize Keys
      data.forEach((key, value) {
        if (key == 'documents' || key == 'verification_code' || key == 'otp') return; 
        
        if (value is Map) {
          value.forEach((subKey, subValue) {
            if (subValue != null) request.fields['${key}_$subKey'] = subValue.toString();
          });
        } else if (value is List) {
          request.fields[key] = jsonEncode(value);
        } else if (value != null) {
          // Normalize Phone Keys
          if (key.toLowerCase().contains('phone') || key.toLowerCase().contains('mobile')) {
            String cleanedPhone = _cleanIdentifier(value.toString());
            request.fields['phone_number'] = cleanedPhone; // Mandatory key
            request.fields[key] = cleanedPhone;
          } 
          // Match Barangay Spelling Requirements
          else if (key == 'barangay') {
            request.fields['baranggay'] = value.toString();
          } else if (key == 'farm_baranggay' || key == 'farm_barangay') {
            request.fields['farm_barangay'] = value.toString();
          } else if (key == 'business_baranggay' || key == 'business_barangay') {
            request.fields['business_barangay'] = value.toString();
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // 5. Add Document Files
      if (data['documents'] is List) {
        List docs = data['documents'];
        for (int i = 0; i < docs.length; i++) {
          String? path = docs[i]?.toString();
          if (path == null || path.isEmpty) continue;

          if (kIsWeb || path.startsWith('http://') || path.startsWith('https://')) {
            try {
              var bytes = await http.readBytes(Uri.parse(path));
              request.files.add(http.MultipartFile.fromBytes('documents', bytes, filename: 'doc_$i.jpg'));
            } catch (e) {
              debugPrint('Error reading URL $path: $e');
            }
          } else {
            final file = File(path);
            if (await file.exists()) {
              request.files.add(await http.MultipartFile.fromPath('documents', path));
            }
          }
        }
      } else if (data['documents'] is Map) {
        Map docs = data['documents'];
        for (var entry in docs.entries) {
          String? path = entry.value?.toString();
          if (path == null || path.isEmpty) continue;

          if (kIsWeb || path.startsWith('http://') || path.startsWith('https://')) {
            var bytes = await http.readBytes(Uri.parse(path));
            request.files.add(http.MultipartFile.fromBytes(entry.key, bytes, filename: '${entry.key}.jpg'));
          } else {
            final file = File(path);
            if (await file.exists()) {
              request.files.add(await http.MultipartFile.fromPath(entry.key, path));
            }
          }
        }
      }

      // 6. Send to Server
      debugPrint('Waiting for server response...');
      var streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Server Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ SUCCESS: Data saved to database.');
        
        // Automatically verify the code if it exists
        final otp = AuthService.lastGeneratedOTP;
        final identifier = data['phone_number'] ?? data['phonenumber'] ?? data['phoneNumber'] ?? data['mobileNumber'] ?? data['email'];
        if (otp != null && identifier != null) {
          debugPrint('Automatically verifying for $identifier with code: $otp');
          await verifyMailboxCode(otp, identifier: identifier.toString());
        }

        return true;
      } else {
        lastError = 'Server rejected data: ${response.body}';
        debugPrint('❌ FAILED: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ ERROR: $e');
      lastError = "Connection failed: $e";
      return false;
    }
  }

  /// Cleans the identifier (phone or email) for backend consistency
  static String _cleanIdentifier(String identifier) {
    if (identifier.contains('@')) return identifier.trim();
    
    String phone = identifier.replaceAll(RegExp(r'\D'), '');
    if (phone.isNotEmpty) {
      if (phone.startsWith('0')) phone = '63${phone.substring(1)}';
      if (!phone.startsWith('63')) phone = '63$phone';
      return phone;
    }
    return identifier.trim();
  }

  /// Verifies the code against the backend
  static Future<bool> verifyMailboxCode(String code, {String? identifier}) async {
    try {
      debugPrint('--- [VERIFY MAILBOX CODE] ---');
      
      final cleanId = identifier != null ? _cleanIdentifier(identifier) : null;
      debugPrint('Identifier: $cleanId | Code: $code');
      
      // The backend strictly requires these keys:
      // "phone_number and verification_code are required."
      final Map<String, dynamic> body = {
        'phone_number': cleanId,
        'verification_code': code.toUpperCase(),
      };
      
      // Fallback keys for compatibility
      body['phonenumber'] = cleanId;
      body['identifier'] = cleanId;
      body['code'] = code.toUpperCase();
      body['otp'] = code.toUpperCase();
      
      if (cleanId != null && cleanId.contains('@')) {
        body['email'] = cleanId;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyMailboxEndpoint}'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Verification Error: $e');
      return false;
    }
  }
}
