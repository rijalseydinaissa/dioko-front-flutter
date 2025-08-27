import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/providers.dart'; // Pour httpClientProvider
import 'payment_models.dart';
import 'payment_repository.dart';

// NE PAS REDECLARER paymentRepositoryProvider ici !

// Provider pour tous les paiements
final allPaymentsProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  return ref.read(paymentRepositoryProvider).list();
});

// Provider pour les paiements pending (en attente)
final pendingPaymentsProvider = Provider.autoDispose<AsyncValue<List<Payment>>>((ref) {
  final allPaymentsAsync = ref.watch(allPaymentsProvider);
  return allPaymentsAsync.when(
    data: (payments) => AsyncValue.data(
      payments.where((p) => p.isPending).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider pour les paiements terminés (completed + cancelled)
final completedPaymentsProvider = Provider.autoDispose<AsyncValue<List<Payment>>>((ref) {
  final allPaymentsAsync = ref.watch(allPaymentsProvider);
  return allPaymentsAsync.when(
    data: (payments) => AsyncValue.data(
      payments.where((p) => p.isCompleted || p.isCancelled).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider pour les statistiques
final paymentStatsProvider = Provider.autoDispose<Map<String, int>>((ref) {
  final allPaymentsAsync = ref.watch(allPaymentsProvider);
  return allPaymentsAsync.when(
    data: (payments) {
      final pending = payments.where((p) => p.isPending).length;
      final completed = payments.where((p) => p.isCompleted).length;
      final cancelled = payments.where((p) => p.isCancelled).length;
      final failed = payments.where((p) => p.isFailed).length;
      return {
        'pending': pending,
        'completed': completed,
        'cancelled': cancelled,
        'failed': failed,
        'total': payments.length,
      };
    },
    loading: () => {'pending': 0, 'completed': 0, 'cancelled': 0, 'failed': 0, 'total': 0},
    error: (_, __) => {'pending': 0, 'completed': 0, 'cancelled': 0, 'failed': 0, 'total': 0},
  );
});

// Provider pour un paiement spécifique
final paymentProvider = FutureProvider.family.autoDispose<Payment, String>((ref, paymentId) async {
  return ref.read(paymentRepositoryProvider).show(paymentId);
});
