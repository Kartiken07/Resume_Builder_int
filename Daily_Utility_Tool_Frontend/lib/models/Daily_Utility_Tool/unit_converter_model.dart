enum UnitCategory {
  length,
  weight,
  temperature,
  volume,
  area,
  speed,
  time,
  digitalStorage,
  pressure,
  energy,
  power,
  angle,
}

extension UnitCategoryX on UnitCategory {
  String get value {
    switch (this) {
      case UnitCategory.length:
        return 'length';
      case UnitCategory.weight:
        return 'weight';
      case UnitCategory.temperature:
        return 'temperature';
      case UnitCategory.volume:
        return 'volume';
      case UnitCategory.area:
        return 'area';
      case UnitCategory.speed:
        return 'speed';
      case UnitCategory.time:
        return 'time';
      case UnitCategory.digitalStorage:
        return 'digital_storage';
      case UnitCategory.pressure:
        return 'pressure';
      case UnitCategory.energy:
        return 'energy';
      case UnitCategory.power:
        return 'power';
      case UnitCategory.angle:
        return 'angle';
    }
  }

  String get label {
    switch (this) {
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.weight:
        return 'Weight';
      case UnitCategory.temperature:
        return 'Temperature';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.speed:
        return 'Speed';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.digitalStorage:
        return 'Digital Storage';
      case UnitCategory.pressure:
        return 'Pressure';
      case UnitCategory.energy:
        return 'Energy';
      case UnitCategory.power:
        return 'Power';
      case UnitCategory.angle:
        return 'Angle';
    }
  }
}

UnitCategory unitCategoryFromJson(String? value) {
  switch (value) {
    case 'length':
      return UnitCategory.length;
    case 'weight':
      return UnitCategory.weight;
    case 'temperature':
      return UnitCategory.temperature;
    case 'volume':
      return UnitCategory.volume;
    case 'area':
      return UnitCategory.area;
    case 'speed':
      return UnitCategory.speed;
    case 'time':
      return UnitCategory.time;
    case 'digital_storage':
      return UnitCategory.digitalStorage;
    case 'pressure':
      return UnitCategory.pressure;
    case 'energy':
      return UnitCategory.energy;
    case 'power':
      return UnitCategory.power;
    case 'angle':
      return UnitCategory.angle;
    default:
      return UnitCategory.length;
  }
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class UnitConversionRequest {
  const UnitConversionRequest({
    required this.category,
    required this.value,
    required this.fromUnit,
    required this.toUnit,
  });

  final UnitCategory category;
  final double value;
  final String fromUnit;
  final String toUnit;

  Map<String, dynamic> toJson() {
    return {
      'category': category.value,
      'value': value,
      'fromUnit': fromUnit,
      'toUnit': toUnit,
    };
  }
}

class UnitConversionResponse {
  const UnitConversionResponse({
    required this.result,
  });

  final double result;

  factory UnitConversionResponse.fromJson(Map<String, dynamic> json) {
    return UnitConversionResponse(
      result: _asDouble(json['result']),
    );
  }
}

class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class CategoryListResponse {
  const CategoryListResponse({
    required this.categories,
  });

  final List<CategoryInfo> categories;

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    final categoriesJson = (json['categories'] as List? ?? []).cast<dynamic>();
    return CategoryListResponse(
      categories: categoriesJson
          .map(
            (e) => CategoryInfo.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class UnitListResponse {
  const UnitListResponse({
    required this.category,
    required this.units,
  });

  final UnitCategory category;
  final List<String> units;

  factory UnitListResponse.fromJson(Map<String, dynamic> json) {
    final unitsJson = (json['units'] as List? ?? []).cast<dynamic>();
    return UnitListResponse(
      category: unitCategoryFromJson(json['category']?.toString()),
      units: unitsJson.map((e) => e.toString()).toList(),
    );
  }
}

class UnitConverterState {
  const UnitConverterState({
    required this.category,
    required this.value,
    required this.fromUnit,
    required this.toUnit,
    required this.isLoading,
    required this.result,
    required this.errorMessage,
    required this.availableUnits,
    required this.isLoadingUnits,
  });

  final UnitCategory category;
  final double value;
  final String fromUnit;
  final String toUnit;
  final bool isLoading;
  final double? result;
  final String? errorMessage;
  final List<String> availableUnits;
  final bool isLoadingUnits;

  UnitConverterState copyWith({
    UnitCategory? category,
    double? value,
    String? fromUnit,
    String? toUnit,
    bool? isLoading,
    double? result,
    String? errorMessage,
    List<String>? availableUnits,
    bool? isLoadingUnits,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return UnitConverterState(
      category: category ?? this.category,
      value: value ?? this.value,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      availableUnits: availableUnits ?? this.availableUnits,
      isLoadingUnits: isLoadingUnits ?? this.isLoadingUnits,
    );
  }
}
