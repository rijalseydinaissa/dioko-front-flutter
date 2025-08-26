import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';
import 'package:intl/intl.dart';
import 'package:payments_app/core/url_utils.dart';
import 'package:go_router/go_router.dart';

final paymentDetailProvider = FutureProvider.family<Payment, String>((ref, id) async {
  return ref.read(paymentRepositoryProvider).show(id);
});

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;
  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(paymentDetailProvider(paymentId));
    final repo = ref.read(paymentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du paiement')),
      body: async.when(
        data: (p) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.description, style: Theme.of(context).textTheme.headlineSmall),
                  Chip(label: Text(p.status)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Montant: ${p.amount.toStringAsFixed(2)}'),
              Text('Type: ${p.type ?? '-'}'),
              Text('Date: ${DateFormat.yMMMd().format(p.createdAt)}'),
              const SizedBox(height: 16),
              Row(children: [
                if (p.status != 'canceled' && p.status != 'success')
                  FilledButton(
                    onPressed: () async {
                      final updated = await repo.cancel(p.id);
                      if (context.mounted) context.go('/payments/${updated.id}');
                    },
                    child: const Text('Annuler'),
                  ),
                const SizedBox(width: 12),
                if (p.status == 'failed' || p.status == 'canceled')
                  OutlinedButton(
                    onPressed: () async {
                      final updated = await repo.retry(p.id);
                      if (context.mounted) context.go('/payments/${updated.id}');
                    },
                    child: const Text('Réessayer'),
                  ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                OutlinedButton.icon(
                  onPressed: () => _openUrl(context, repo.viewUrl(p.id)),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Voir justificatif'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _openUrl(context, repo.downloadUrl(p.id)),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger'),
                ),
              ])
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  void _openUrl(BuildContext context, String relativeUrl) {
    final base = Uri.parse(const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000/api'))
        .replace(path: '');
    final origin = base.origin;
    final full = '$origin$relativeUrl';
    openUrl(full);
  }
}