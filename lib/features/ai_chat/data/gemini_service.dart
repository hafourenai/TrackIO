import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<String> getResponse({
    required String systemPrompt,
    required String financialContext,
    required String userQuestion,
    List<Content>? chatHistory,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    final contents = [
      Content.text('Berikut adalah data keuangan saya saat ini:\n$financialContext\n\nSilakan jawab pertanyaan saya berdasarkan data di atas.'),
      if (chatHistory != null) ...chatHistory,
      Content.text(userQuestion),
    ];

    final response = await model.generateContent(contents);
    return response.text ?? 'Maaf, saya tidak dapat memberikan jawaban saat ini.';
  }
}
