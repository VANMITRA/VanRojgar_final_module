import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'catalog_providers.dart';

/// Sign in, create account, restore and sign out against the shop server; null when no server address was given
/// (development and tests): then the screens keep their in-memory behaviour.
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final api = ref.watch(shopApiClientProvider);
  if (api == null) return null;
  return AuthRepository(api, ref.watch(tokenStorageProvider));
});
