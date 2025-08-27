import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';
import 'package:payments_app/features/payments/data/payments_providers.dart';
import 'package:payments_app/core/providers.dart';
import 'package:go_router/go_router.dart';

enum HistoryFilter { day, month, year }

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  HistoryFilter _filter = HistoryFilter.day;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFilterLabel(HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.day:
        return 'Aujourd\'hui';
      case HistoryFilter.month:
        return 'Ce mois';
      case HistoryFilter.year:
        return 'Cette année';
    }
  }

  List<Payment> _applyFilter(List<Payment> payments) {
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
    final paymentsAsync = ref.watch(allPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour au tableau de bord',
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Historique des paiements'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(allPaymentsProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<HistoryFilter>(
            onSelected: (val) {
              setState(() => _filter = val);
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par période',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: HistoryFilter.day,
                child: _menuItem('Aujourd\'hui', Icons.today, _filter == HistoryFilter.day),
              ),
              PopupMenuItem(
                value: HistoryFilter.month,
                child: _menuItem('Ce mois', Icons.calendar_month, _filter == HistoryFilter.month),
              ),
              PopupMenuItem(
                value: HistoryFilter.year,
                child: _menuItem('Cette année', Icons.calendar_today, _filter == HistoryFilter.year),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Filtré par: ${_getFilterLabel(_filter)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.4,
                          minChildSize: 0.3,
                          maxChildSize: 0.8,
                          builder: (context, scrollController) {
                            return SingleChildScrollView(
                              controller: scrollController,
                              child: _FilterBottomSheet(
                                currentFilter: _filter,
                                onFilterChanged: (filter) {
                                  setState(() => _filter = filter);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Changer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                final filteredPayments = _applyFilter(payments);

                if (filteredPayments.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(allPaymentsProvider);
                      await ref.read(allPaymentsProvider.future);
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.payment, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun paiement pour ${_getFilterLabel(_filter).toLowerCase()}',
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() => _filter = HistoryFilter.year);
                                  },
                                  child: const Text('Voir toute l\'année'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allPaymentsProvider);
                    await ref.read(allPaymentsProvider.future);
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final p = filteredPayments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(
                            p.description,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${DateFormat.yMMMd().format(DateTime.tryParse(p.createdAt) ?? DateTime.now())} • ${p.paymentType.name}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min, // 🔧 FIX: Ajout de cette ligne
                            children: [
                              Text(
                                '${double.tryParse(p.amount)?.toStringAsFixed(2) ?? '0.00'} FCFA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2), // 🔧 FIX: Réduction de 4 à 2
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), // 🔧 FIX: Réduction du padding
                                decoration: BoxDecoration(
                                  color: _statusColor(p.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10), // 🔧 FIX: Réduction de 12 à 10
                                  border: Border.all(color: _statusColor(p.status), width: 1),
                                ),
                                child: Text(
                                  p.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _statusColor(p.status),
                                    fontSize: 11, // 🔧 FIX: Réduction de 12 à 11
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigation vers les détails du paiement
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allPaymentsProvider);
                  await ref.read(allPaymentsProvider.future);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement: $error',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(allPaymentsProvider);
                              },
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String text, IconData icon, bool selected) {
    return Row(
      children: [
        Icon(icon, color: selected ? Colors.blue : Colors.grey),
        const SizedBox(width: 8),
        Text(text),
        if (selected) ...[
          const Spacer(),
          const Icon(Icons.check, color: Colors.blue),
        ]
      ],
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final HistoryFilter currentFilter;
  final Function(HistoryFilter) onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              Text(
                'Filtrer par période',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FilterOption(
            icon: Icons.today,
            title: 'Aujourd\'hui',
            description: 'Paiements d\'aujourd\'hui uniquement',
            isSelected: currentFilter == HistoryFilter.day,
            onTap: () => onFilterChanged(HistoryFilter.day),
          ),
          _FilterOption(
            icon: Icons.calendar_month,
            title: 'Ce mois',
            description: 'Paiements du mois en cours',
            isSelected: currentFilter == HistoryFilter.month,
            onTap: () => onFilterChanged(HistoryFilter.month),
          ),
          _FilterOption(
            icon: Icons.calendar_today,
            title: 'Cette année',
            description: 'Tous les paiements de l\'année',
            isSelected: currentFilter == HistoryFilter.year,
            onTap: () => onFilterChanged(HistoryFilter.year),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : null,
        ),
      ),
      subtitle: Text(description),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
      selected: isSelected,
    );
  }
}