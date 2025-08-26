import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:payments_app/core/providers.dart';
import 'package:payments_app/features/dashboard/data/dashboard_models.dart';


final statsProvider = FutureProvider.autoDispose<Stats>((ref) async {
  return ref.read(dashboardRepositoryProvider).fetchStats();
});

final recentPaymentsProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  return ref.read(dashboardRepositoryProvider).fetchRecentPayments();
});

final paymentTypesProvider = FutureProvider.autoDispose<List<PaymentType>>((ref) async {
  return ref.read(dashboardRepositoryProvider).fetchPaymentTypes();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final recentPayments = ref.watch(recentPaymentsProvider);
    final types = ref.watch(paymentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/new'), // <-- avec GoRouter
        icon: const Icon(Icons.add),
        label: const Text('Nouveau paiement'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stats.when(
              data: (s) => _BalanceCard(balance: s.balance),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
            ),
            const SizedBox(height: 16),
            Text('Paiements récents', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            recentPayments.when(
              data: (list) => Column(
                children: list.map((p) => ListTile(
                  title: Text(p.description),
                  subtitle: Text('${p.amount} - ${p.statusLabel}'),
                  trailing: Text(p.paymentType.name),
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e'),
            ),
            const SizedBox(height: 16),
            Text('Types de paiement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            types.when(
              data: (list) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.map((t) => Chip(label: Text(t.name))).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solde disponible'),
                Text(balance,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
