import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/http_client.dart';
import 'package:payments_app/core/providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.read(httpClientProvider);
  return DashboardRepository(client);
});

class DashboardRepository {
  final HttpClient _http;
  DashboardRepository(this._http);

  Future<Map<String, dynamic>> index() async {
    final res = await _http.get('/dashboard/');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<dynamic>> monthlyStats() async {
    final res = await _http.get('/dashboard/monthly-stats');
    return (res.data as List<dynamic>);
  }

  Future<List<dynamic>> paymentTypeStats() async {
    final res = await _http.get('/dashboard/payment-type-stats');
    return (res.data as List<dynamic>);
  }
}
