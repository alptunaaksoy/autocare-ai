import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../widgets/custom_button.dart';

class EngineSoundScreen extends StatefulWidget {
  const EngineSoundScreen({super.key});

  @override
  State<EngineSoundScreen> createState() => _EngineSoundScreenState();
}

class _EngineSoundScreenState extends State<EngineSoundScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AiService aiService = AiService();

  bool isRecording = false;
  bool isLoading = false;
  bool hasResult = false;

  String? recordedFilePath;
  String analysisResult = '';

  Future<void> startRecording() async {
    try {
      final hasPermission = await audioRecorder.hasPermission();

      if (!hasPermission) {
        showMessage('Mikrofon izni verilmedi.');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      final filePath =
          '${directory.path}/engine_sound_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
        ),
        path: filePath,
      );

      setState(() {
        isRecording = true;
        hasResult = false;
        analysisResult = '';
        recordedFilePath = null;
      });
    } catch (e) {
      showMessage('Ses kaydı başlatılamadı.');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();

      setState(() {
        isRecording = false;
        recordedFilePath = path;
      });

      showMessage('Motor sesi kaydedildi.');
    } catch (e) {
      showMessage('Ses kaydı durdurulamadı.');
    }
  }

  Future<void> analyzeSound() async {
    if (recordedFilePath == null) {
      showMessage('Önce motor sesi kaydı almalısın.');
      return;
    }

    setState(() {
      isLoading = true;
      hasResult = false;
      analysisResult = '';
    });

    final result = await aiService.analyzeEngineSound(recordedFilePath!);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      hasResult = true;
      analysisResult = result;
    });
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.graphic_eq,
            color: AppTheme.accentColor,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              analysisResult,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBox() {
    String title = 'Motor sesini kaydet';
    String subtitle =
        'Aracını çalıştır, telefonu motora yakın tut ve birkaç saniye kayıt al.';
    IconData icon = Icons.multitrack_audio;
    Color iconColor = AppTheme.accentColor;

    if (isRecording) {
      title = 'Kayıt yapılıyor...';
      subtitle = 'Motor sesini net alabilmek için telefonu sabit tut.';
      icon = Icons.mic;
      iconColor = Colors.red;
    } else if (recordedFilePath != null) {
      title = 'Ses kaydı hazır';
      subtitle = 'Kaydı OpenAI ile analiz edebilirsin.';
      icon = Icons.check_circle;
      iconColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 80,
            color: iconColor,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Motor Sesi Analizi'),
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
                'Motor Sesini Kontrol Et',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Motor sesini kaydederek OpenAI destekli değerlendirme al.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              statusBox(),
              const SizedBox(height: 24),
              CustomButton(
                text: isRecording ? 'Kaydı Durdur' : 'Kaydı Başlat',
                isLoading: false,
                onPressed: isRecording ? stopRecording : startRecording,
              ),
              if (recordedFilePath != null) ...[
                const SizedBox(height: 16),
                CustomButton(
                  text: 'OpenAI ile Analiz Et',
                  isLoading: isLoading,
                  onPressed: analyzeSound,
                ),
              ],
              resultCard(),
            ],
          ),
        ),
      ),
    );
  }
}