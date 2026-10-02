class VehicleModel {
  final String brand;
  final String model;
  final String year;
  final String kilometer;
  final String fuelType;

  VehicleModel({
    required this.brand,
    required this.model,
    required this.year,
    required this.kilometer,
    required this.fuelType,
  });

  String get fullName {
    return '$brand $model';
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'kilometer': kilometer,
      'fuelType': fuelType,
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      kilometer: json['kilometer'] ?? '',
      fuelType: json['fuelType'] ?? '',
    );
  }
}