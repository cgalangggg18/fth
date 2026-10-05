class Region {
  final String code;
  final String name;
  final String regionName;

  Region({required this.code, required this.name, required this.regionName});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      regionName: (json['regionName'] ?? json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'regionName': regionName,
  };
}

class Province {
  final String code;
  final String name;
  final String regionCode;

  Province({required this.code, required this.name, required this.regionCode});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      regionCode: (json['regionCode'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'regionCode': regionCode,
  };
}

class Municipality {
  final String code;
  final String name;
  final String provinceCode;

  Municipality({required this.code, required this.name, required this.provinceCode});

  factory Municipality.fromJson(Map<String, dynamic> json) {
    String? getFirstString(List<String> keys) {
      for (var key in keys) {
        if (json[key] is String) return json[key];
      }
      return null;
    }

    return Municipality(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      provinceCode: getFirstString(['provinceCode', 'districtCode', 'regionCode']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'provinceCode': provinceCode,
  };
}

class Barangay {
  final String code;
  final String name;
  final String municipalityCode;

  Barangay({required this.code, required this.name, required this.municipalityCode});

  factory Barangay.fromJson(Map<String, dynamic> json) {
    String? getFirstString(List<String> keys) {
      for (var key in keys) {
        if (json[key] is String) return json[key];
      }
      return null;
    }

    return Barangay(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      municipalityCode: getFirstString([
        'municipalityCode',
        'cityCode',
        'highlyUrbanizedCityCode',
        'independentComponentCityCode',
        'subMunicipalityCode'
      ]) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'municipalityCode': municipalityCode,
  };
}
