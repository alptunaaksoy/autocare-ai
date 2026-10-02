import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleModel? _vehicle;

  VehicleModel? get vehicle => _vehicle;

  bool get hasVehicle => _vehicle != null;

  Future<void> loadVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    final vehicleJson = prefs.getString('vehicle');

    if (vehicleJson != null) {
      final data = jsonDecode(vehicleJson);
      _vehicle = VehicleModel.fromJson(data);
      notifyListeners();
    }
  }

  Future<void> saveVehicle(VehicleModel vehicle) async {
    _vehicle = vehicle;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicle', jsonEncode(vehicle.toJson()));

    notifyListeners();
  }

  Future<void> clearVehicle() async {
    _vehicle = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vehicle');

    notifyListeners();
  }
}