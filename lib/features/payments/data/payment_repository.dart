import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:payments_app/core/exceptions.dart';
import 'package:payments_app/core/http_client.dart';
import 'payment_models.dart';


class PaymentRepository {
  final HttpClient _http;
  PaymentRepository(this._http);

  Future<List<Payment>> list() async {
    try {
      final res = await _http.get('/payments/');

      // CORRECTION: Accéder à data.payments au lieu de data directement
      final responseData = res.data as Map<String, dynamic>;
      final paymentsData = responseData['data'] as Map<String, dynamic>;
      final payments = paymentsData['payments'] as List<dynamic>;

      return payments.map((e) => Payment.fromJson(Map<String, dynamic>.from(e))).toList();
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
      // CORRECTION: Si l'API retourne aussi une structure similaire pour un seul paiement
      final responseData = res.data as Map<String, dynamic>;
      if (responseData.containsKey('data')) {
        return Payment.fromJson(Map<String, dynamic>.from(responseData['data']));
      } else {
        // Si l'API retourne directement le paiement
        return Payment.fromJson(Map<String, dynamic>.from(res.data));
      }
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de la récupération du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Payment> create({
    required String description,
    required double amount,
    int? paymentTypeId,
    String? filePath,
    String? fileName,
    Uint8List? fileBytes,
  }) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('description', description));
      form.fields.add(MapEntry('amount', amount.toString()));
      if (paymentTypeId != null) form.fields.add(MapEntry('payment_type_id', paymentTypeId.toString()));

      // ✅ Priorité à fileBytes (Web), fallback sur filePath (Mobile)
      if (fileBytes != null && fileName != null) {
        form.files.add(MapEntry(
          'attachment',
          MultipartFile.fromBytes(fileBytes, filename: fileName),
        ));
      } else if (filePath != null) {
        form.files.add(MapEntry(
          'attachment',
          await MultipartFile.fromFile(filePath, filename: fileName ?? filePath.split('/').last),
        ));
      }

      // 🔍 Debug log des champs envoyés
      for (var f in form.fields) {
        print('FIELD: ${f.key} = ${f.value}');
      }
      for (var f in form.files) {
        print('FILE: ${f.key} = ${f.value.filename} (${f.value.length} bytes)');
      }


      final res = await _http.post('/payments/', data: form);

      final responseData = res.data as Map<String, dynamic>;
      if (responseData.containsKey('data')) {
        return Payment.fromJson(Map<String, dynamic>.from(responseData['data']));
      } else {
        return Payment.fromJson(Map<String, dynamic>.from(res.data));
      }
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
      final responseData = res.data as Map<String, dynamic>;
      if (responseData.containsKey('data')) {
        return Payment.fromJson(Map<String, dynamic>.from(responseData['data']));
      } else {
        return Payment.fromJson(Map<String, dynamic>.from(res.data));
      }
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de l\'annulation du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> approvePayment(int paymentId) async {
    try {
      await _http.patch('/payments/$paymentId/approve');
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de l\'approbation',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> cancelPayment(int paymentId) async {
    try {
      await _http.patch('/payments/$paymentId/cancel');
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors de l\'annulation',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Payment> retry(String id) async {
    try {
      final res = await _http.patch('/payments/$id/retry');
      final responseData = res.data as Map<String, dynamic>;
      if (responseData.containsKey('data')) {
        return Payment.fromJson(Map<String, dynamic>.from(responseData['data']));
      } else {
        return Payment.fromJson(Map<String, dynamic>.from(res.data));
      }
    } on DioException catch (e) {
      throw AppException(
        e.response?.data['message'] ?? 'Erreur lors du re-essai du paiement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Payment> update(String id, Map<String, dynamic> data) async {
    try {
      final res = await _http.put('/payments/$id', data: data);
      final responseData = res.data as Map<String, dynamic>;
      return Payment.fromJson(responseData['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du paiement: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _http.delete('/payments/$id');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du paiement: $e');
    }
  }

  String downloadUrl(String id) => '/files/payments/$id/download';
  String viewUrl(String id) => '/files/payments/$id/view';
}