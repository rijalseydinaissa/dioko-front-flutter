import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:payments_app/features/dashboard/data/dashboard_repository.dart';

final _dashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(dashboardRepositoryProvider).index();
});

final _monthlyProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ref.read(dashboardRepositoryProvider).monthlyStats();
});

final _typeStatsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ref.read(dashboardRepositoryProvider).paymentTypeStats();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(_dashboardProvider);
    final monthly = ref.watch(_monthlyProvider);
    final types = ref.watch(_typeStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            // Simple logout via provider lookup
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
          },
        )
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/payments/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau paiement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dash.when(
              data: (data) => _BalanceCard(balance: (data['balance'] ?? 0).toString()),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
            ),
            const SizedBox(height: 16),
            Text('Évolution mensuelle', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(height: 240, child: monthly.when(
                  data: (list) => LineChart(LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (final (i, e) in list.indexed)
                            FlSpot(i.toDouble(), (e['amount'] as num).toDouble()),
                        ],
                      ),
                    ],
                  )),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erreur: $e'),
                )),
              ),
            ),
            const SizedBox(height: 16),
            Text('Par type de paiement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 240,
                  child: types.when(
                    data: (list) => PieChart(PieChartData(
                      sections: [
                        for (final e in list)
                          PieChartSectionData(value: (e['amount'] as num).toDouble(), title: e['type'].toString()),
                      ],
                    )),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur: $e'),
                  ),
                ),
              ),
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
                Text(balance, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
