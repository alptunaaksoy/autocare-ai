import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class FaultScanScreen extends StatefulWidget {
  const FaultScanScreen({super.key});

  @override
  State<FaultScanScreen> createState() => _FaultScanScreenState();
}

class _FaultScanScreenState extends State<FaultScanScreen> {
  final ImagePicker imagePicker = ImagePicker();

  File? selectedImage;
  bool isLoading = false;
  bool hasResult = false;

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        hasResult = false;
      });
    } catch (e) {
      showError('Fotoğraf seçilirken hata oluştu.');
    }
  }

  Future<void> takePhotoWithCamera() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        hasResult = false;
      });
    } catch (e) {
      showError('Kamera açılırken hata oluştu.');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void analyzeFaultLight() {
    if (selectedImage == null) {
      showError('Lütfen önce gösterge paneli fotoğrafı seç.');
      return;
    }

    setState(() {
      isLoading = true;
      hasResult = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasResult = true;
      });
    });
  }

  Widget imageArea() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: selectedImage == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppTheme.accentColor,
                ),
                SizedBox(height: 14),
                Text(
                  'Gösterge paneli fotoğrafı seç',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Kamera veya galeriden fotoğraf ekle',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget resultCard() {
    if (!hasResult) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.4),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 34,
              ),
              SizedBox(width: 12),
              Text(
                'Motor Arıza Lambası',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Risk Seviyesi: Orta',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Olası nedenler:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text('• Oksijen sensörü arızası'),
          Text('• EGR sistemi problemi'),
          Text('• Ateşleme veya yakıt sistemi sorunu'),
          SizedBox(height: 14),
          Text(
            'Öneri:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aracı yüksek devirde kullanmadan en yakın serviste kontrol ettirmen önerilir.',
          ),
        ],
      ),
    );
  }

  Widget smallActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(
              color: AppTheme.accentColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Arıza Lambası Analizi'),
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
                'Gösterge Panelini Analiz Et',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gösterge panelinin fotoğrafını çek veya galeriden seç. Sistem arıza lambasını analiz eder.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),

              imageArea(),

              const SizedBox(height: 18),

              Row(
                children: [
                  smallActionButton(
                    text: 'Galeri',
                    icon: Icons.photo_library,
                    onTap: pickImageFromGallery,
                  ),
                  const SizedBox(width: 12),
                  smallActionButton(
                    text: 'Kamera',
                    icon: Icons.camera_alt,
                    onTap: takePhotoWithCamera,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Analiz Başlat',
                isLoading: isLoading,
                onPressed: analyzeFaultLight,
              ),

              resultCard(),
            ],
          ),
        ),
      ),
    );
  }
}