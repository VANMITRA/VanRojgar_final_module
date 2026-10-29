import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../features/livelihood/data/livelihood_api.dart';
import '../../features/livelihood/providers/livelihood_providers.dart';
import 'catalog_providers.dart';

/// The address of the livelihood report server, given when the app is built
/// (`--dart-define=VANMITRA_LIVELIHOOD_URL=https://...`). Empty in development and in tests.
const String livelihoodServerUrl = String.fromEnvironment('VANMITRA_LIVELIHOOD_URL');

/// Provider overrides for the live servers. Put them in the app's root `ProviderScope`.
/// The livelihood server trusts the same sign-in token as the shop server, so the saved token is sent to it.
final List<Override> liveServerOverrides = [
  if (livelihoodServerUrl.isNotEmpty)
    livelihoodApiProvider.overrideWith(
      (ref) => HostApiAdapter(
        ApiClient(baseUrl: livelihoodServerUrl, tokenProvider: ref.read(tokenStorageProvider).read),
      ),
    ),
];
