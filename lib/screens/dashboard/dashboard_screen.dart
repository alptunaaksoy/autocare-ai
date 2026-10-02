// lib/screens/dashboard/dashboard_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/notification_service.dart';

import '../ai_assistant/ai_assistant_screen.dart';
import '../engine_sound/engine_sound_screen.dart';
import '../fault_scan/fault_scan_screen.dart';
import '../maintenance/maintenance_screen.dart';
import '../service/nearby_service_screen.dart';
import '../vehicle/add_vehicle_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String getMaintenanceStatus({
    required String currentKmText,
    required List maintenanceList,
  }) {
    final currentKm = int.tryParse(currentKmText) ?? 0;

    if (currentKm == 0 || maintenanceList.isEmpty) {
      return 'Veri Eksik';
    }

    int lastMaintenanceKm = 0;

    for (final item in maintenanceList) {
      final km = int.tryParse(item.kilometer) ?? 0;

      if (km > lastMaintenanceKm) {
        lastMaintenanceKm = km;
      }
    }

    final difference = currentKm - lastMaintenanceKm;

    if (difference >= 10000) {
      return 'Bakım Gerekli';
    } else if (difference >= 8000) {
      return 'Yaklaşıyor';
    } else {
      return 'İyi';
    }
  }

  Color getStatusColor(String status) {
    if (status == 'Bakım Gerekli') {
      return Colors.red;
    } else if (status == 'Yaklaşıyor') {
      return Colors.orange;
    } else if (status == 'İyi') {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 14),
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
              child: Icon(
                icon,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget maintenanceWarningCard(String status) {
    if (status == 'İyi') {
      return const SizedBox();
    }

    String message =
        'Bakım verileri eksik. Daha doğru analiz için araç ve bakım bilgilerini gir.';

    IconData icon = Icons.info_outline;
    Color color = Colors.grey;

    if (status == 'Yaklaşıyor') {
      message =
          'Bakım zamanı yaklaşıyor. Yağ, filtre ve fren kontrollerini planlaman önerilir.';

      icon = Icons.access_time;
      color = Colors.orange;
    } else if (status == 'Bakım Gerekli') {
      message =
          'Bakım zamanı gelmiş olabilir. Aracı zorlamadan servis kontrolü yaptırman önerilir.';

      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (status == 'Yaklaşıyor' ||
              status == 'Bakım Gerekli') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  NotificationService.showMaintenanceNotification(
                    title: 'AutoCare AI Bakım Uyarısı',
                    body: message,
                  );
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Bildirim Test Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context);

    final maintenanceProvider =
        Provider.of<MaintenanceProvider>(context);

    final vehicle = vehicleProvider.vehicle;

    final maintenanceList =
        maintenanceProvider.maintenanceList;

    final vehicleName =
        vehicle == null ? 'Araç eklenmedi' : vehicle.fullName;

    final kilometer =
        vehicle == null ? '-' : vehicle.kilometer;

    final fuelType =
        vehicle == null ? '-' : vehicle.fuelType;

    final maintenanceStatus = getMaintenanceStatus(
      currentKmText: vehicle?.kilometer ?? '',
      maintenanceList: maintenanceList,
    );

    final statusColor =
        getStatusColor(maintenanceStatus);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,

        title: Row(
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 34,
            ),
            const SizedBox(width: 10),
            const Text('AutoCare AI'),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Araç Durumu',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vehicleName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          statusColor.withOpacity(0.18),
                      borderRadius:
                          BorderRadius.circular(14),
                      border:
                          Border.all(color: statusColor),
                    ),
                    child: Text(
                      'Bakım Durumu: $maintenanceStatus',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bakım bilgilerini düzenli girerek daha doğru risk analizi alabilirsin.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: infoCard(
                    icon: Icons.speed,
                    title: 'KM',
                    value: kilometer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: infoCard(
                    icon: Icons.local_gas_station,
                    title: 'Yakıt',
                    value: fuelType,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            infoCard(
              icon: Icons.build,
              title: 'Bakım Kontrolü',
              value: maintenanceStatus,
              valueColor: statusColor,
            ),

            maintenanceWarningCard(
              maintenanceStatus,
            ),

            const SizedBox(height: 24),

            menuCard(
              icon: Icons.smart_toy,
              title: 'AI Bakım Asistanı',
              subtitle: 'Aracınla ilgili soru sor',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AiAssistantScreen(),
                  ),
                );
              },
            ),

            menuCard(
              icon: Icons.directions_car,
              title: 'Araç Bilgileri',
              subtitle:
                  'Marka, model ve kilometre ekle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AddVehicleScreen(),
                  ),
                );
              },
            ),

            menuCard(
              icon: Icons.car_repair,
              title: 'Arıza Lambası Analizi',
              subtitle:
                  'Kamera ile gösterge panelini analiz et',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FaultScanScreen(),
                  ),
                );
              },
            ),

            menuCard(
              icon: Icons.mic,
              title: 'Motor Sesi Analizi',
              subtitle:
                  'Motor sesini kaydet ve yorumlat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const EngineSoundScreen(),
                  ),
                );
              },
            ),

            menuCard(
              icon: Icons.history,
              title: 'Bakım Geçmişi',
              subtitle:
                  'Geçmiş bakım kayıtlarını görüntüle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MaintenanceScreen(),
                  ),
                );
              },
            ),

            menuCard(
              icon: Icons.location_on,
              title: 'Yakındaki Servisler',
              subtitle:
                  'Konumuna göre servis önerisi al',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NearbyServiceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}