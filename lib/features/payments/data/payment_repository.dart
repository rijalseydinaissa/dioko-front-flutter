import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/http_client.dart';
import 'package:payments_app/core/providers.dart';
import 'package:payments_app/features/payments/data/payment_models.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final client = ref.read(httpClientProvider);
  return PaymentRepository(client);
});

class PaymentRepository {
  final HttpClient _http;
  PaymentRepository(this._http);

  Future<List<Payment>> list() async {
    final res = await _http.get('/payments/');
    final data = res.data as List<dynamic>;
    return data.map((e) => Payment.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Payment> show(String id) async {
    final res = await _http.get('/payments/$id');
    return Payment.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Payment> create({
    required String description,
    required double amount,
    String? type,
    String? filePath,
    String? fileName,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('description', description));
    form.fields.add(MapEntry('amount', amount.toString()));
    if (type != null) form.fields.add(MapEntry('type', type));
    if (filePath != null) {
      form.files.add(MapEntry(
        'proof',
        await MultipartFile.fromFile(filePath, filename: fileName ?? filePath.split('/').last),
      ));
    }
    final res = await _http.post('/payments/', data: form);
    return Payment.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Payment> cancel(String id) async {
    final res = await _http.patch('/payments/$id/cancel');
    return Payment.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Payment> retry(String id) async {
    final res = await _http.patch('/payments/$id/retry');
    return Payment.fromJson(Map<String, dynamic>.from(res.data));
  }

  String downloadUrl(String id) => '/files/payments/$id/download';
  String viewUrl(String id) => '/files/payments/$id/view';
}