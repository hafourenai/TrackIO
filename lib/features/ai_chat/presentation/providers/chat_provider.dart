import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../recommendation/presentation/providers/recommendation_provider.dart';
import '../../../score/presentation/providers/score_provider.dart';
import '../../data/gemini_service.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isConnected;
  final String apiKey;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = true,
    this.apiKey = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isConnected,
    String? apiKey,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  static const _apiKeyPrefKey = 'gemini_api_key';

  ChatNotifier(this._ref) : super(ChatState()) {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_apiKeyPrefKey) ?? '';
    if (savedKey.isNotEmpty) {
      state = state.copyWith(apiKey: savedKey);
    }
  }

  Future<void> setApiKey(String key) async {
    state = state.copyWith(apiKey: key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, key);
  }

  Future<void> checkConnection() async {
    final connected = await ConnectivityService.isConnected();
    state = state.copyWith(isConnected: connected);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    await checkConnection();
    if (!state.isConnected) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(sender: 'user', text: text, time: DateTime.now()),
          ChatMessage(
            sender: 'ai',
            text: 'Fitur AI memerlukan koneksi internet. Pastikan Anda terhubung ke WiFi atau data seluler.',
            time: DateTime.now(),
          ),
        ],
      );
      return;
    }

    final userMessage = ChatMessage(sender: 'user', text: text, time: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final dashboard = await _ref.read(dashboardDataProvider.future);
      final scoreReport = await _ref.read(financialScoreFutureProvider.future);
      final recommendations = await _ref.read(recommendationsFutureProvider.future);

      var largestCategory = 'Tidak ada';
      double maxVal = 0.0;
      dashboard.categoryExpenses.forEach((cat, val) {
        if (val > maxVal) {
          maxVal = val;
          largestCategory = cat;
        }
      });

      var targetSavingsStr = 'Rp0';
      for (final rec in recommendations) {
        if (rec.title.contains('Tabungan') || rec.title.contains('Keuangan')) {
          final reg = RegExp(r'Rp[0-9.]+');
          final match = reg.firstMatch(rec.recommendation);
          if (match != null) {
            targetSavingsStr = match.group(0) ?? 'Rp0';
          }
        }
      }

      final financialContext = '''
- Saldo saat ini: Rp${dashboard.totalBalance.toStringAsFixed(0)}
- Total pemasukan bulan ini: Rp${dashboard.monthlyIncome.toStringAsFixed(0)}
- Total pengeluaran bulan ini: Rp${dashboard.monthlyExpense.toStringAsFixed(0)}
- Kategori pengeluaran terbesar: $largestCategory
- Target tabungan bulan depan: $targetSavingsStr
- Skor kesehatan keuangan: ${scoreReport.totalScore.toStringAsFixed(0)} (${scoreReport.status})
''';

      const systemPrompt = '''
Kamu adalah Financial Advisor AI bernama TrackIO Assistant.
Tugasmu membantu pengguna mengelola keuangan pribadi.
Selalu berikan saran berdasarkan data keuangan yang diberikan.
Jangan memberikan saran investasi berisiko.
Jangan mengarang data.
Jika data tidak cukup, minta informasi tambahan.
Fokus pada pengeluaran, tabungan, budgeting, dan kesehatan keuangan pengguna.
Gunakan bahasa Indonesia yang sederhana dan mudah dipahami.
''';

      final geminiService = GeminiService(apiKey: state.apiKey);

      final List<Content> apiHistory = state.messages
          .take(state.messages.length - 1)
          .map((m) => m.sender == 'user'
              ? Content.text(m.text)
              : Content.model([TextPart(m.text)]))
          .toList();

      final aiResponse = await geminiService.getResponse(
        systemPrompt: systemPrompt,
        financialContext: financialContext,
        userQuestion: text,
        chatHistory: apiHistory,
      );

      final responseMessage = ChatMessage(sender: 'ai', text: aiResponse, time: DateTime.now());
      state = state.copyWith(
        messages: [...state.messages, responseMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            sender: 'ai',
            text: 'Gagal menghubungi AI. Pastikan API Key Anda sudah benar dan koneksi internet stabil.\n\nDetail: ${e.toString()}',
            time: DateTime.now(),
          ),
        ],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = state.copyWith(messages: []);
  }
}
