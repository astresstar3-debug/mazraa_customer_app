import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Keeps the existing UI untouched while allowing legacy `Image.asset(...)`
/// calls to render URLs returned by the API.
class NetworkAwareAssetBundle extends CachingAssetBundle {
  NetworkAwareAssetBundle({AssetBundle? fallback})
      : fallback = fallback ?? rootBundle;

  final AssetBundle fallback;
  final HttpClient _httpClient = HttpClient();

  @override
  Future<ByteData> load(String key) async {
    if (!_isNetworkKey(key)) return fallback.load(key);

    final request = await _httpClient.getUrl(Uri.parse(key));
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.drain<void>();
      throw HttpException(
        'Unable to load image ($key): HTTP ${response.statusCode}',
        uri: Uri.parse(key),
      );
    }

    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    return ByteData.sublistView(bytes);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (!_isNetworkKey(key)) return fallback.loadString(key, cache: cache);
    return super.loadString(key, cache: cache);
  }

  bool _isNetworkKey(String key) =>
      key.startsWith('http://') || key.startsWith('https://');

  void close() => _httpClient.close(force: true);
}
