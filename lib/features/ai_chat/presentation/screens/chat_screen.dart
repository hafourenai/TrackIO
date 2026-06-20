import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _apiKeyController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatProvider.notifier).checkConnection();
      final key = ref.read(chatProvider).apiKey;
      if (key.isNotEmpty) {
        _apiKeyController.text = key;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final theme = Theme.of(context);
    final isKeyConfigured = state.apiKey.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Financial Advisor', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isKeyConfigured)
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                _apiKeyController.text = state.apiKey;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pengaturan API Key'),
                    content: TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Google Gemini API Key',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(chatProvider.notifier).setApiKey(_apiKeyController.text.trim());
                          Navigator.pop(context);
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (isKeyConfigured && state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () {
                ref.read(chatProvider.notifier).clearChat();
              },
              tooltip: 'Hapus Percakapan',
            ),
        ],
      ),
      body: !isKeyConfigured
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.vpn_key_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Konfigurasi API Key',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Untuk memulai konsultasi dengan AI Financial Advisor, silakan masukkan API Key Gemini Anda dari Google AI Studio.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Google Gemini API Key',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key_rounded),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      final key = _apiKeyController.text.trim();
                      if (key.isNotEmpty) {
                        ref.read(chatProvider.notifier).setApiKey(key);
                      }
                    },
                    child: const Text('Simpan & Mulai'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (!state.isConnected)
                  Container(
                    width: double.infinity,
                    color: Colors.red.shade100,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Fitur AI memerlukan koneksi internet.',
                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 64,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Mulai Konsultasi Keuangan',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tanyakan kepada AI Advisor tentang anggaran belanja, rencana tabungan, atau analisis skor kesehatan keuangan Anda.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final msg = state.messages[index];
                            return ChatBubble(message: msg);
                          },
                        ),
                ),
                ChatInput(
                  isLoading: state.isLoading,
                  onSend: (text) async {
                    await ref.read(chatProvider.notifier).sendMessage(text);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  },
                ),
              ],
            ),
    );
  }
}
