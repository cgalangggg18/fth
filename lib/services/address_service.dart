import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/address/philippine_address_models.dart';

class AddressService {
  static const String baseUrl = 'https://psgc.gitlab.io/api';

  Future<List<Region>> getRegions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/regions.json')).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Region.fromJson(json)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching regions: $e');
      return [];
    }
  }

  Future<List<Province>> getProvinces(String regionCode) async {
    try {
      final endpoints = ['provinces', 'highly-urbanized-cities', 'independent-component-cities'];
      final results = <Province>[];

      final responses = await Future.wait(
        endpoints.map((e) => http.get(Uri.parse('$baseUrl/regions/$regionCode/$e.json'))
            .timeout(const Duration(seconds: 15))
            .catchError((_) => http.Response('[]', 404)))
      );

      for (var response in responses) {
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          results.addAll(data.map((json) => Province.fromJson(json)));
        }
      }
      return results..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error fetching provinces: $e');
      return [];
    }
  }

  Future<List<Municipality>> getMunicipalities(String provinceCode) async {
    try {
      // 1. Check if the code represents a city level itself
      final cityTypes = ['cities', 'highly-urbanized-cities', 'independent-component-cities', 'component-cities'];
      for (var type in cityTypes) {
        try {
          final response = await http.get(Uri.parse('$baseUrl/$type/$provinceCode.json')).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data != null && (data['code'] ?? '').toString() == provinceCode) {
              return [Municipality.fromJson(data)];
            }
          }
        } catch (_) {}
      }

      // 2. Normal province lookup
      final results = <Municipality>[];
      final endpoints = ['cities', 'municipalities'];
      
      final responses = await Future.wait(
        endpoints.map((e) => http.get(Uri.parse('$baseUrl/provinces/$provinceCode/$e.json'))
            .timeout(const Duration(seconds: 15))
            .catchError((_) => http.Response('[]', 404)))
      );

      for (var response in responses) {
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          results.addAll(data.map((json) => Municipality.fromJson(json)));
        }
      }
      
      return results..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error fetching municipalities: $e');
      return [];
    }
  }

  Future<List<Barangay>> getBarangays(String municipalityCode) async {
    if (municipalityCode.isEmpty) return [];
    
    try {
      final cleanCode = municipalityCode.trim();

      // Attempt 1: Try specific categorization endpoints with .json extension
      final types = [
        'cities',
        'municipalities',
        'highly-urbanized-cities',
        'independent-component-cities',
        'component-cities'
      ];

      for (var type in types) {
        try {
          final url = '$baseUrl/$type/$cleanCode/barangays.json';
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            final dynamic decoded = json.decode(response.body);
            if (decoded is List && decoded.isNotEmpty) {
              return decoded.map((json) => Barangay.fromJson(json)).toList()
                ..sort((a, b) => a.name.compareTo(b.name));
            }
          }
        } catch (_) {}
      }

      // Attempt 2: Fallback to Prefix-based filtering from the entire Region list
      // This is the most reliable "catch-all" because it doesn't depend on city classification.
      if (cleanCode.length >= 6) {
        final prefix = cleanCode.substring(0, 6);
        final regionCode = cleanCode.substring(0, 2) + '0000000';
        
        try {
          final url = '$baseUrl/regions/$regionCode/barangays.json';
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
          if (response.statusCode == 200) {
            final dynamic decoded = json.decode(response.body);
            if (decoded is List) {
              final filtered = decoded
                  .where((b) {
                    final bCode = (b['code'] ?? '').toString();
                    return bCode.startsWith(prefix);
                  })
                  .map((json) => Barangay.fromJson(json))
                  .toList();
              if (filtered.isNotEmpty) return filtered..sort((a, b) => a.name.compareTo(b.name));
            }
          }
        } catch (_) {}
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching barangays: $e');
      return [];
    }
  }

  String getPostalCode(String municipalityName) {
    final name = municipalityName.toLowerCase();
    
    // Pampanga
    if (name.contains('angeles')) return '2009';
    if (name.contains('san fernando')) return '2000';
    if (name.contains('mabalacat')) return '2010';
    if (name.contains('mexico')) return '2021';
    if (name.contains('guagua')) return '2003';
    if (name.contains('lubao')) return '2005';
    if (name.contains('porac')) return '2008';
    if (name.contains('bacolor')) return '2001';
    if (name.contains('floridablanca')) return '2006';
    if (name.contains('apalit')) return '2016';
    if (name.contains('candaba')) return '2013';
    if (name.contains('arayat')) return '2012';
    if (name.contains('sasmuan')) return '2004';
    if (name.contains('macabebe')) return '2017';
    if (name.contains('masantol')) return '2018';
    if (name.contains('minalin')) return '2002';
    if (name.contains('san simon')) return '2015';
    if (name.contains('san luis')) return '2014';
    if (name.contains('santa rita')) return '2007';
    if (name.contains('santa ana')) return '2022';
    if (name.contains('magalang')) return '2011';
    if (name.contains('sto. tomas') || name.contains('santo tomas')) return '2020';
    
    // Tarlac
    if (name.contains('tarlac city')) return '2300';
    if (name.contains('concepcion')) return '2316';
    if (name.contains('capas')) return '2315';
    if (name.contains('bamban')) return '2317';
    if (name.contains('camiling')) return '2306';
    if (name.contains('gerona')) return '2302';
    if (name.contains('paniqui')) return '2307';
    if (name.contains('victoria')) return '2313';
    if (name.contains('la paz')) return '2314';
    if (name.contains('moncada')) return '2308';
    if (name.contains('sta. ignacia') || name.contains('santa ignacia')) return '2301';
    if (name.contains('palanan')) return '3334'; // Isabela but just in case
    
    // Bulacan
    if (name.contains('malolos')) return '3000';
    if (name.contains('meycauayan')) return '3020';
    if (name.contains('marilao')) return '3019';
    if (name.contains('bocaue')) return '3018';
    if (name.contains('balagtas')) return '3012';
    if (name.contains('guiguinto')) return '3015';
    if (name.contains('plaridel')) return '3004';
    if (name.contains('pulilan')) return '3005';
    if (name.contains('baliwag')) return '3006';
    if (name.contains('hagonoy')) return '3002';
    if (name.contains('calumpit')) return '3003';
    if (name.contains('san jose del monte')) return '3023';
    if (name.contains('sta. maria') || name.contains('santa maria')) return '3022';
    if (name.contains('san miguel')) return '3011';
    if (name.contains('san rafael')) return '3008';
    if (name.contains('angat')) return '3012';
    if (name.contains('norzagaray')) return '3013';
    if (name.contains('bulakan')) return '3017';
    
    // Bataan
    if (name.contains('balanga')) return '2100';
    if (name.contains('dinalupihan')) return '2110';
    if (name.contains('mariveles')) return '2105';
    if (name.contains('limay')) return '2103';
    if (name.contains('orani')) return '2112';
    if (name.contains('hermosa')) return '2111';
    
    // Zambales
    if (name.contains('iba')) return '2201';
    if (name.contains('olongapo')) return '2200';
    if (name.contains('subic')) return '2209';
    if (name.contains('castillejos')) return '2208';
    if (name.contains('san marcelino')) return '2207';
    
    // Nueva Ecija
    if (name.contains('cabanatuan')) return '3100';
    if (name.contains('gapan')) return '3105';
    if (name.contains('science city of muñoz')) return '3119';
    if (name.contains('san jose city')) return '3121';
    if (name.contains('talavera')) return '3114';
    if (name.contains('guimba')) return '3115';
    if (name.contains('san isidro')) return '3106';

    // Pangasinan (Region I - often used with Region III)
    if (name.contains('dagupan')) return '2400';
    if (name.contains('lingayen')) return '2401';
    if (name.contains('binmaley')) return '2417';
    if (name.contains('calasiao')) return '2418';
    if (name.contains('mangasaldan')) return '2432';

    return '';
  }
}
