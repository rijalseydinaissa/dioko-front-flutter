import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';

enum HistoryFilter { day, month, year }

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  late final PaymentRepository repo;
  HistoryFilter _filter = HistoryFilter.day;
  List<Payment> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    repo = ref.read(paymentRepositoryProvider);
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => isLoading = true);
    try {
      payments = await repo.list();
    } catch (e) {
      print("Erreur de chargement: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Payment> _applyFilter() {
    DateTime now = DateTime.now();
    return payments.where((p) {
      DateTime createdAt = DateTime.tryParse(p.createdAt) ?? now;
      switch (_filter) {
        case HistoryFilter.day:
          return createdAt.year == now.year &&
              createdAt.month == now.month &&
              createdAt.day == now.day;
        case HistoryFilter.month:
          return createdAt.year == now.year && createdAt.month == now.month;
        case HistoryFilter.year:
          return createdAt.year == now.year;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _applyFilter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des paiements'),
        actions: [
          PopupMenuButton<HistoryFilter>(
            onSelected: (val) {
              setState(() => _filter = val);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: HistoryFilter.day,
                child: Text('Aujourd\'hui'),
              ),
              const PopupMenuItem(
                value: HistoryFilter.month,
                child: Text('Ce mois'),
              ),
              const PopupMenuItem(
                value: HistoryFilter.year,
                child: Text('Cette année'),
              ),
            ],
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredPayments.isEmpty
              ? const Center(child: Text('Aucun paiement trouvé'))
              : ListView.builder(
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, index) {
                    final p = filteredPayments[index];
                    return ListTile(
                      title: Text(p.description),
                      subtitle: Text(
                        '${DateFormat.yMMMd().format(DateTime.tryParse(p.createdAt) ?? DateTime.now())} • ${p.paymentType.name}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${double.tryParse(p.amount)?.toStringAsFixed(2) ?? '0.00'} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p.status,
                            style: TextStyle(color: _statusColor(p.status)),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Action sur clic (ex: afficher détails)
                      },
                    );
                  },
                ),
    );
  }
}