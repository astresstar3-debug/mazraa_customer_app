abstract final class ApiConfig {
  /// Single source of truth for the server address.
  /// Change this default value once to point the whole app at another server.
  /// It can also be overridden without editing code:
  /// flutter run --dart-define=API_BASE_URL=https://example.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mzraa.runasp.net',
  );

  static String resolveMediaUrl(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final path = value.trim();
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/${path.replaceAll(RegExp(r'^/+'), '')}';
  }
}
