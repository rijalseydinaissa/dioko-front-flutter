import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/exceptions.dart';
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
    try {
      final res = await _http.get('/payments/');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Payment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de la récupération des paiements',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Payment> show(String id) async {
    try {
      final res = await _http.get('/payments/$id');
      return Payment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de la récupération du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Création d'un paiement avec support Web (bytes) et Mobile (path)
  Future<Payment> create({
    required String description,
    required double amount,
    String? type,
    String? filePath,
    String? fileName,
    Uint8List? fileBytes, // <-- pour Web
  }) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('description', description));
      form.fields.add(MapEntry('amount', amount.toString()));
      if (type != null) form.fields.add(MapEntry('type', type));

      // Gestion fichier pour Web et Mobile
      if (fileBytes != null) {
        form.files.add(MapEntry(
          'proof',
          MultipartFile.fromBytes(fileBytes, filename: fileName ?? 'file.pdf'),
        ));
      } else if (filePath != null) {
        form.files.add(MapEntry(
          'proof',
          await MultipartFile.fromFile(filePath,
              filename: fileName ?? filePath.split('/').last),
        ));
      }

      final res = await _http.post('/payments/', data: form);
      return Payment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final firstError = errors != null && errors.isNotEmpty
            ? errors.values.first[0]
            : e.response?.data['message'] ?? 'Données invalides';
        throw AppException(firstError, statusCode: 422);
      }
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de la création du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Payment> cancel(String id) async {
    try {
      final res = await _http.patch('/payments/$id/cancel');
      return Payment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de l’annulation du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Payment> retry(String id) async {
    try {
      final res = await _http.patch('/payments/$id/retry');
      return Payment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de la ré-essai du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  String downloadUrl(String id) => '/files/payments/$id/download';
  String viewUrl(String id) => '/files/payments/$id/view';
}
