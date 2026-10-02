import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/maintenance_model.dart';

class MaintenanceProvider extends ChangeNotifier {
  final List<MaintenanceModel> _maintenanceList = [];

  List<MaintenanceModel> get maintenanceList => _maintenanceList;

  Future<void> loadMaintenanceList() async {
    final prefs = await SharedPreferences.getInstance();
    final maintenanceJson = prefs.getString('maintenanceList');

    if (maintenanceJson != null) {
      final List<dynamic> data = jsonDecode(maintenanceJson);

      _maintenanceList.clear();
      _maintenanceList.addAll(
        data.map((item) => MaintenanceModel.fromJson(item)).toList(),
      );

      notifyListeners();
    }
  }

  Future<void> addMaintenance(MaintenanceModel maintenance) async {
    _maintenanceList.add(maintenance);
    await saveMaintenanceList();
    notifyListeners();
  }

  Future<void> saveMaintenanceList() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _maintenanceList
        .map((maintenance) => maintenance.toJson())
        .toList();

    await prefs.setString('maintenanceList', jsonEncode(data));
  }

  Future<void> clearMaintenanceList() async {
    _maintenanceList.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('maintenanceList');

    notifyListeners();
  }
}