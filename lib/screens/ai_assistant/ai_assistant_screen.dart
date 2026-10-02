import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final questionController = TextEditingController();
  final AiService aiService = AiService();

  bool isLoading = false;
  String aiAnswer = '';

  Future<void> askAssistant() async {
    if (questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir soru yaz.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      aiAnswer = '';
    });

    final answer = await aiService.askAiAssistant(questionController.text);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      aiAnswer = answer;
    });
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  Widget answerCard() {
    if (aiAnswer.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.smart_toy,
            color: AppTheme.accentColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              aiAnswer,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.primaryColor,
                height: 1.45,
              ),
            ),
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
        title: const Text('AI Bakım Asistanı'),
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
                'Aracın Hakkında Soru Sor',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                      'AI destekli araç analiz sistemi',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
              const SizedBox(height: 28),

              CustomTextField(
                label: 'Soru',
                hint: 'Örn: Motor arıza lambası yandı ne yapmalıyım?',
                icon: Icons.question_answer_outlined,
                controller: questionController,
              ),

              const SizedBox(height: 22),

              CustomButton(
                text: 'AI Asistana Sor',
                isLoading: isLoading,
                onPressed: askAssistant,
              ),

              answerCard(),
            ],
          ),
        ),
      ),
    );
  }
}