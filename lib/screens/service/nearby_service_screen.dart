import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_theme.dart';
import '../../services/google_places_service.dart';
import '../../widgets/custom_button.dart';

class NearbyServiceScreen extends StatefulWidget {
  const NearbyServiceScreen({super.key});

  @override
  State<NearbyServiceScreen> createState() => _NearbyServiceScreenState();
}

class _NearbyServiceScreenState extends State<NearbyServiceScreen> {
  bool isLoading = false;
  List<dynamic> services = [];

  Future<void> loadNearbyServices() async {
    setState(() {
      isLoading = true;
      services = [];
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showMessage('Konum servisi kapalı. Lütfen konumu aç.');
        setState(() => isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showMessage('Konum izni verilmedi.');
        setState(() => isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 12));

      final result = await GooglePlacesService()
          .getNearbyServices(
            latitude: position.latitude,
            longitude: position.longitude,
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      setState(() {
        services = result;
        isLoading = false;
      });

      if (result.isEmpty) {
        showMessage('Yakında servis bulunamadı veya API cevap vermedi.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      showMessage('Servisler alınırken hata oluştu.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget serviceCard(dynamic service) {
   final name = service['displayName']?['text'] ?? 'Servis';
   final address = service['formattedAddress'] ?? 'Adres bilgisi yok';
   final rating = service['rating']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(address),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange),
              const SizedBox(width: 4),
              Text(rating),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Yakındaki Servisler'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomButton(
              text: 'Konumumu Al ve Servisleri Bul',
              isLoading: isLoading,
              onPressed: loadNearbyServices,
            ),
            const SizedBox(height: 20),
            if (!isLoading && services.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Servis aramak için butona bas.'),
                ),
              )
            else if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return serviceCard(services[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}