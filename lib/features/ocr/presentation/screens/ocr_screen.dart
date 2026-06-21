import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../providers/ocr_provider.dart';
import '../widgets/image_source_picker.dart';
import '../widgets/ocr_result_card.dart';

class OcrScreen extends ConsumerWidget {
  const OcrScreen({super.key});

  void _showImageSourcePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ImageSourcePicker(
          onSourceSelected: (source) {
            ref.read(ocrProvider.notifier).pickImage(source);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ocrProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Struk Belanja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(ocrProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: state.isScanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sedang membaca struk belanja...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (state.image == null) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: InkWell(
                        onTap: () => _showImageSourcePicker(context, ref),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ambil Foto / Pilih Struk Belanja',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Data toko, tanggal, dan nominal akan diisi otomatis',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: Image.file(
                          state.image!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _showImageSourcePicker(context, ref),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Ganti Foto'),
                    ),
                    const SizedBox(height: 16),
                    if (state.result != null)
                      OcrResultCard(
                        result: state.result!,
                        onConfirmed: (data) async {
                          final tx = Transaction(
                            title: data['title'],
                            amount: data['amount'],
                            date: data['date'],
                            type: 'expense',
                            category: data['category'],
                            note: 'Diisi otomatis melalui scan struk',
                            createdAt: DateTime.now(),
                          );
                          await ref.read(transactionControllerProvider).addTransaction(tx);
                          ref.read(ocrProvider.notifier).reset();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaksi berhasil ditambahkan dari struk')),
                            );
                            context.pop();
                          }
                        },
                      ),
                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
