import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/maintenance_model.dart';
import '../../providers/maintenance_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final maintenanceNameController = TextEditingController();
  final kilometerController = TextEditingController();
  final dateController = TextEditingController();

  bool isLoading = false;

  void addMaintenance() {
    if (maintenanceNameController.text.isEmpty ||
        kilometerController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldur.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final maintenance = MaintenanceModel(
        name: maintenanceNameController.text,
        kilometer: kilometerController.text,
        date: dateController.text,
      );

      Provider.of<MaintenanceProvider>(context, listen: false)
          .addMaintenance(maintenance);

      maintenanceNameController.clear();
      kilometerController.clear();
      dateController.clear();

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bakım kaydı eklendi.'),
        ),
      );
    });
  }

  @override
  void dispose() {
    maintenanceNameController.dispose();
    kilometerController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Widget maintenanceCard(MaintenanceModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.build,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.kilometer} km • ${item.date}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceList =
        Provider.of<MaintenanceProvider>(context).maintenanceList;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bakım Geçmişi'),
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
                'Bakım Kaydı Ekle',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yağ değişimi, filtre, balata gibi bakım işlemlerini kaydet.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Bakım Adı',
                hint: 'Örn: Yağ Değişimi',
                icon: Icons.build_outlined,
                controller: maintenanceNameController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Kilometre',
                hint: 'Örn: 187000',
                icon: Icons.speed,
                controller: kilometerController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Tarih',
                hint: 'Örn: 11.05.2026',
                icon: Icons.calendar_month,
                controller: dateController,
              ),
              const SizedBox(height: 22),
              CustomButton(
                text: 'Bakım Kaydı Ekle',
                isLoading: isLoading,
                onPressed: addMaintenance,
              ),
              const SizedBox(height: 30),
              const Text(
                'Geçmiş Bakımlar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              if (maintenanceList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Henüz bakım kaydı eklenmedi.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              else
                for (final item in maintenanceList) maintenanceCard(item),
            ],
          ),
        ),
      ),
    );
  }
}