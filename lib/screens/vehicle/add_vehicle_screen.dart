import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final kilometerController = TextEditingController();
  final fuelTypeController = TextEditingController();

  bool isLoading = false;

  void saveVehicle() {
    if (brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        kilometerController.text.isEmpty ||
        fuelTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm araç bilgilerini doldur.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final vehicle = VehicleModel(
        brand: brandController.text,
        model: modelController.text,
        year: yearController.text,
        kilometer: kilometerController.text,
        fuelType: fuelTypeController.text,
      );

      Provider.of<VehicleProvider>(context, listen: false).saveVehicle(vehicle);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Araç bilgileri başarıyla kaydedildi.'),
        ),
      );

      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    kilometerController.dispose();
    fuelTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedVehicle = Provider.of<VehicleProvider>(context).vehicle;

    if (savedVehicle != null &&
        brandController.text.isEmpty &&
        modelController.text.isEmpty) {
      brandController.text = savedVehicle.brand;
      modelController.text = savedVehicle.model;
      yearController.text = savedVehicle.year;
      kilometerController.text = savedVehicle.kilometer;
      fuelTypeController.text = savedVehicle.fuelType;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Araç Bilgileri'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aracını Tanımla',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bu bilgiler bakım önerileri ve risk analizi için kullanılacak.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),

              CustomTextField(
                label: 'Marka',
                hint: 'Örn: Opel',
                icon: Icons.directions_car,
                controller: brandController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Model',
                hint: 'Örn: Astra H',
                icon: Icons.car_repair,
                controller: modelController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Yıl',
                hint: 'Örn: 2011',
                icon: Icons.calendar_month,
                controller: yearController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Kilometre',
                hint: 'Örn: 187000',
                icon: Icons.speed,
                controller: kilometerController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Yakıt Tipi',
                hint: 'Örn: Dizel / Benzin / LPG',
                icon: Icons.local_gas_station,
                controller: fuelTypeController,
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Araç Bilgilerini Kaydet',
                isLoading: isLoading,
                onPressed: saveVehicle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}