class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000/api/v1',
  );

  static const bool devTools = bool.fromEnvironment(
    'DEV_TOOLS',
    defaultValue: true,
  );
}
