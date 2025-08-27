import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/http_client.dart';
import 'package:payments_app/features/auth/data/token_storage.dart';
import 'package:payments_app/features/dashboard/data/dashboard_repository.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';
import 'package:payments_app/features/dashboard/data/dashboard_models.dart';
// Provider pour le stockage sécurisé des tokens
final secureStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

// Provider pour le client HTTP
final httpClientProvider = Provider<HttpClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return HttpClient(storage);
});

// Provider pour le repository du dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.read(httpClientProvider);
  return DashboardRepository(client);
});

// Provider pour le repository des paiements (si pas encore défini ailleurs)
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final client = ref.read(httpClientProvider);
  return PaymentRepository(client);
});

// Provider pour récupérer les types de paiement
final paymentTypesProvider = FutureProvider.autoDispose<List<PaymentType>>((ref) async {
  final repository = ref.read(dashboardRepositoryProvider);
  return repository.fetchPaymentTypes();
});