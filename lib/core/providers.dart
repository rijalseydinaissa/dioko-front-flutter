import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/core/http_client.dart';
import 'package:payments_app/features/auth/data/token_storage.dart';

final secureStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final httpClientProvider = Provider<HttpClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return HttpClient(storage);
});