import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
              Text('Montant: ${double.tryParse(p.amount)?.toStringAsFixed(2) ?? '0.00'} FCFA'),
              Text('Type: ${p.paymentType.name}'),
              Text('Date: ${DateFormat.yMMMd().format(DateTime.tryParse(p.createdAt) ?? DateTime.now())}'),
              const SizedBox(height: 16),
              Row(children: [
                if (p.status != 'cancelled' && p.status != 'success')
                  FilledButton(
                    onPressed: () async {
                      final updated = await repo.cancel(p.id.toString());
                      if (context.mounted) context.go('/payments/${updated.id}');
                    },
                    child: const Text('Annuler'),
                  ),
                const SizedBox(width: 12),
                if (p.status == 'failed' || p.status == 'cancelled')
                  OutlinedButton(
                    onPressed: () async {
                      final updated = await repo.retry(p.id.toString());
                      if (context.mounted) context.go('/payments/${updated.id}');
                    },
                    child: const Text('Réessayer'),
                  ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                OutlinedButton.icon(
                  onPressed: () => _openUrl(context, repo.viewUrl(p.id.toString())),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Voir justificatif'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _openUrl(context, repo.downloadUrl(p.id.toString())),
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

  void _openUrl(BuildContext context, String relativeUrl) async {
    const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
    final fullUrl = '$baseUrl$relativeUrl';

    final Uri uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
        );
      }
    }
  }
}