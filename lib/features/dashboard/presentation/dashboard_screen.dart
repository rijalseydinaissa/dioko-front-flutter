import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:payments_app/core/providers.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payments_providers.dart';

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
          // Bouton pour voir tous les paiements
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Voir tous les paiements',
            onPressed: () => context.go('/payments'),
          ),
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
            // Statistiques avec navigation
            _StatsCards(
              stats: stats,
              onTapViewAll: () => context.go('/payments'),
            ),
            const SizedBox(height: 16),

            // Paiements en attente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paiements en attente',
                     style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => context.go('/payments'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            pendingPayments.when(
              data: (payments) => payments.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Aucun paiement en attente'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => context.push('/payments/new'),
                              child: const Text('Créer un paiement'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ...payments.take(3).map((p) => _PendingPaymentCard(
                          payment: p,
                          onApprove: () => _handleApprove(context, ref, p.id),
                          onCancel: () => _handleCancel(context, ref, p.id),
                        )).toList(),
                        if (payments.length > 3)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.more_horiz),
                              title: Text('${payments.length - 3} paiement(s) supplémentaire(s)'),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () => context.go('/payments'),
                            ),
                          ),
                      ],
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Paiements terminés
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paiements récents',
                     style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => context.go('/payments'),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('Historique'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            completedPayments.when(
              data: (payments) => Column(
                children: [
                  ...payments.take(4).map((p) => _CompletedPaymentCard(
                    payment: p,
                    onTap: () => context.go('/payments/${p.id}'), // Navigation vers le détail
                  )).toList(),
                  if (payments.length > 4)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Voir l\'historique complet'),
                        subtitle: Text('${payments.length} paiements au total'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => context.go('/payments'),
                      ),
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
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
      ref.invalidate(allPaymentsProvider);
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
      ref.invalidate(allPaymentsProvider);
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
  final VoidCallback onTapViewAll;

  const _StatsCards({
    required this.stats,
    required this.onTapViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onTapViewAll,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('${stats['pending'] ?? 0}',
                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                               color: Colors.orange,
                             )),
                        const Text('En attente'),
                        const SizedBox(height: 4),
                        const Icon(Icons.pending, color: Colors.orange, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onTapViewAll,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('${stats['completed'] ?? 0}',
                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                               color: Colors.green,
                             )),
                        const Text('Terminés'),
                        const SizedBox(height: 4),
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onTapViewAll,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('${stats['total'] ?? 0}',
                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                               color: Colors.blue,
                             )),
                        const Text('Total'),
                        const SizedBox(height: 4),
                        const Icon(Icons.analytics, color: Colors.blue, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Voir tous les paiements'),
            subtitle: const Text('Accéder à la liste complète avec filtres'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: onTapViewAll,
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
      child: ListTile(
        title: Text(payment.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant: ${payment.amount} FCFA'),
            Text('Type: ${payment.paymentType.name}'),
            if (payment.paymentReference.isNotEmpty)
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
        isThreeLine: true,
      ),
    );
  }
}

class _CompletedPaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;

  const _CompletedPaymentCard({
    required this.payment,
    this.onTap,
  });

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
        onTap: onTap,
      ),
    );
  }
}