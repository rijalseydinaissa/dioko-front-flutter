import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:payments_app/core/providers.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payments_providers.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingPayments = ref.watch(pendingPaymentsProvider);
    final completedPayments = ref.watch(completedPaymentsProvider);
    final stats = ref.watch(paymentStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau paiement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques
            _StatsCards(stats: stats),
            const SizedBox(height: 16),

            // Paiements en attente
            Text('Paiements en attente',
                 style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            pendingPayments.when(
              data: (payments) => payments.isEmpty
                  ? const Card(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucun paiement en attente'),
                    ))
                  : Column(
                      children: payments.map((p) => _PendingPaymentCard(
                        payment: p,
                        onApprove: () => _handleApprove(context, ref, p.id),
                        onCancel: () => _handleCancel(context, ref, p.id),
                      )).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur: $e', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Paiements terminés
            Text('Paiements récents',
                 style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            completedPayments.when(
              data: (payments) => Column(
                children: payments.take(6).map((p) => _CompletedPaymentCard(
                  payment: p,
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur: $e', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref, int paymentId) async {
    try {
      await ref.read(paymentRepositoryProvider).approvePayment(paymentId);
      ref.invalidate(allPaymentsProvider); // Rafraîchir les données
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement approuvé')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref, int paymentId) async {
    try {
      await ref.read(paymentRepositoryProvider).cancelPayment(paymentId);
      ref.invalidate(allPaymentsProvider); // Rafraîchir les données
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement annulé')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

class _StatsCards extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('${stats['pending'] ?? 0}',
                       style: Theme.of(context).textTheme.headlineMedium),
                  const Text('En attente'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('${stats['completed'] ?? 0}',
                       style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Terminés'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('${stats['total'] ?? 0}',
                       style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Total'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onApprove;
  final VoidCallback onCancel;

  const _PendingPaymentCard({
    required this.payment,
    required this.onApprove,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(h
        title: Text(payment.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant: ${payment.amount} FCFA'),
            Text('Type: ${payment.paymentType.name}'),
            Text('Référence: ${payment.paymentReference}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Approuver',
              onPressed: onApprove,
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'Annuler',
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedPaymentCard extends StatelessWidget {
  final Payment payment;
  const _CompletedPaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(payment.description),
        subtitle: Text('${payment.amount} FCFA • ${payment.paymentType.name}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              payment.isCompleted ? Icons.check_circle :
              payment.isCancelled ? Icons.cancel : Icons.pending,
              color: payment.isCompleted ? Colors.green :
                     payment.isCancelled ? Colors.red : Colors.orange,
            ),
            Text(
              payment.statusLabel,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}