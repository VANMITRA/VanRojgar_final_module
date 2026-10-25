import 'package:flutter/foundation.dart' show kReleaseMode;

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000/api/v1',
  );

  /// The livelihood report server (Python). It trusts the sign-in token of the server above.
  static const String livelihoodBaseUrl = String.fromEnvironment(
    'LIVELIHOOD_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// PIN pre-filled by the demo account buttons. It must match SEED_DEMO_PASSWORD on the server.
  static const String demoPin = String.fromEnvironment('DEMO_PIN', defaultValue: '123456');

  /// Demo account buttons and the server-target dialog on the login screen. On in debug runs, off in release
  /// builds unless the build sets --dart-define=DEV_TOOLS=true (for example a labelled demo APK).
  static const bool devTools = bool.fromEnvironment(
    'DEV_TOOLS',
    defaultValue: !kReleaseMode,
  );
}
