class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://tolak-bencana.miomidev.com/api',
  );
}
