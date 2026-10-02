import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_keys.dart';

class AiService {
  Future<String> askAiAssistant(String question) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/responses');

      final prompt = '''
Sen AutoCare AI isimli bir araç bakım asistanısın.

Kullanıcının araçla ilgili sorusunu analiz et.
Cevabını Türkçe ver.

Cevap formatı:
1. Olası Nedenler
2. Risk Seviyesi
3. Kullanıcı Ne Yapmalı?
4. Tahmini Masraf Aralığı

Kurallar:
- Kesin teşhis koyma.
- Servis kontrolü öner.
- Kısa, net ve anlaşılır cevap ver.
- Güvenlik riski varsa özellikle belirt.

Kullanıcı sorusu:
$question
''';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4.1-mini',
          'input': prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['output']?[0]?['content']?[0]?['text'];

        if (text == null || text.toString().isEmpty) {
          return 'AI cevabı alınamadı.';
        }

        return text.toString();
      }

      return 'OpenAI API hatası: ${response.statusCode}\n${response.body}';
    } catch (e) {
      return 'AI bağlantısında hata oluştu: $e';
    }
  }

  Future<String> analyzeEngineSound(String audioFilePath) async {
    try {
      final audioFile = File(audioFilePath);

      if (!await audioFile.exists()) {
        return 'Ses dosyası bulunamadı.';
      }

      final transcriptionUrl = Uri.parse(
        'https://api.openai.com/v1/audio/transcriptions',
      );

      final request = http.MultipartRequest(
        'POST',
        transcriptionUrl,
      );

      request.headers['Authorization'] = 'Bearer ${ApiKeys.openAiApiKey}';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'tr';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return 'Ses OpenAI tarafından işlenemedi: ${response.statusCode}\n${response.body}';
      }

      final transcriptionData = jsonDecode(response.body);
      final transcript = transcriptionData['text'] ?? '';

      final analysisPrompt = '''
Sen AutoCare AI isimli bir araç bakım asistanısın.

Kullanıcı motor sesi kaydı aldı. Ses kaydından çıkan metin/açıklama aşağıdadır:
"$transcript"

Bu kayıt gerçek motor sesi olabilir, ortam sesi olabilir veya anlaşılır bir konuşma olabilir.
Eğer metin motor sesi hakkında net bilgi vermiyorsa bunu belirt.

Türkçe cevap ver.

Cevap formatı:
1. Ses Kaydı Değerlendirmesi
2. Olası Risk
3. Kontrol Edilmesi Gereken Parçalar
4. Kullanıcı Ne Yapmalı?

Kesin teşhis koyma. Servis kontrolü öner.
''';

      return await askAiAssistant(analysisPrompt);
    } catch (e) {
      return 'Motor sesi analizi sırasında hata oluştu: $e';
    }
  }
}