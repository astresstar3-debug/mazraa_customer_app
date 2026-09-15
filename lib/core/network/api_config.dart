abstract final class ApiConfig {
  /// Android emulator default. Override for a physical device or hosted API:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5160
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5160',
  );

  static String resolveMediaUrl(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final path = value.trim();
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/${path.replaceAll(RegExp(r'^/+'), '')}';
  }
}
