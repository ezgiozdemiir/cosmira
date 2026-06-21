import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../config/env.dart';

final geminiModelProvider = Provider<GenerativeModel>((ref) {
  return GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: Env.geminiApiKey,
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 1000,
    ),
  );
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(geminiModelProvider));
});

class AiService {
  final GenerativeModel _model;

  const AiService(this._model);

  Future<String> generateContent(String prompt,
      {String languageCode = 'en'}) async {
    final langInstruction = languageCode == 'tr'
        ? '\nRespond entirely in Turkish.'
        : '\nRespond entirely in English.';
    final response = await _model
        .generateContent([Content.text(prompt + langInstruction)]);
    return response.text ?? '';
  }

  Future<String> generateAuraReading({
    required String sign,
    required String mood,
    required int energyScore,
    String languageCode = 'en',
  }) async {
    final prompt = '''
You are a luxury astrology AI for Cosmira. Generate a brief, elegant aura reading.
Sign: $sign, Mood: $mood, Energy: $energyScore/100.
Return 2-3 sentences. Tone: premium, calming, empowering. No generic platitudes.''';
    return generateContent(prompt, languageCode: languageCode);
  }
}
