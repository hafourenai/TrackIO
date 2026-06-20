import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/recommendation_card.dart';

class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Keuangan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: recommendationsAsync.when(
        data: (insights) {
          if (insights.isEmpty) {
            return const Center(
              child: Text('Tidak ada rekomendasi saat ini'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: RecommendationCard(insight: insight),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
