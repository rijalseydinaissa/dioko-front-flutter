import 'package:payments_app/core/http_client.dart';
import 'package:payments_app/features/dashboard/data/dashboard_models.dart';

class DashboardRepository {
  final HttpClient _http;
  DashboardRepository(this._http);

  Future<Stats> fetchStats() async {
    final res = await _http.get('/dashboard/');
    final statsJson = res.data['data']['stats'] as Map<String, dynamic>;
    return Stats.fromJson(statsJson);
  }

  Future<List<Payment>> fetchRecentPayments() async {
    final res = await _http.get('/dashboard/');
    final paymentsJson = res.data['data']['recent_payments'] as List<dynamic>;
    return paymentsJson.map((e) => Payment.fromJson(e)).toList();
  }

  Future<List<PaymentType>> fetchPaymentTypes() async {
    final res = await _http.get('/dashboard/');
    final typesJson = res.data['data']['payment_types'] as List<dynamic>;
    return typesJson.map((e) => PaymentType.fromJson(e)).toList();
  }
}
