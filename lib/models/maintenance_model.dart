class MaintenanceModel {
  final String name;
  final String kilometer;
  final String date;

  MaintenanceModel({
    required this.name,
    required this.kilometer,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'kilometer': kilometer,
      'date': date,
    };
  }

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      name: json['name'] ?? '',
      kilometer: json['kilometer'] ?? '',
      date: json['date'] ?? '',
    );
  }
}