import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('id_ID', null);
  } catch (_) {
    // ignore: locale fallback not critical
  }

  try {
    await AppDatabase.init();
  } catch (error) {
    runApp(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: _ErrorScreen(message: error.toString()),
        ),
      ),
    );
    return;
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'Gagal Memulai Aplikasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Database tidak dapat dimuat. Coba instal ulang aplikasi atau hubungi developer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Tutup Aplikasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
