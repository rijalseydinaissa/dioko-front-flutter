import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';

final paymentsProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  return ref.read(paymentRepositoryProvider).list();
});

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  HistoryFilter _filter = HistoryFilter.month;
  DateTime _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(paymentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/payments/new'),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Filtrer par : '),
                const SizedBox(width: 8),
                DropdownButton<HistoryFilter>(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v!),
                  items: const [
                    DropdownMenuItem(value: HistoryFilter.day, child: Text('Jour')),
                    DropdownMenuItem(value: HistoryFilter.month, child: Text('Mois')),
                    DropdownMenuItem(value: HistoryFilter.year, child: Text('Année')),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _now = DateTime.now()),
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: async.when(
                data: (items) {
                  final filtered = _applyFilter(items, _filter);
                  if (filtered.isEmpty) {
                    return const Center(child: Text('Aucun paiement'));
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return ListTile(
                        title: Text(p.description),
                        subtitle: Text('${DateFormat.yMMMd().format(p.createdAt)}  •  ${p.type ?? '-'}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${p.amount.toStringAsFixed(2)}'),
                            Text(p.status, style: TextStyle(color: _statusColor(p.status))),
                          ],
                        ),
                        onTap: () => context.go('/payments/${p.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Payment> _applyFilter(List<Payment> items, HistoryFilter f) {
    bool test(Payment p) {
      final d = p.createdAt;
      if (f == HistoryFilter.day) {
        return d.year == _now.year && d.month == _now.month && d.day == _now.day;
      }
      if (f == HistoryFilter.month) {
        return d.year == _now.year && d.month == _now.month;
      }
      return d.year == _now.year;
    }

    final list = items.where(test).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'success':
        return Colors.green;
      case 'failed':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
