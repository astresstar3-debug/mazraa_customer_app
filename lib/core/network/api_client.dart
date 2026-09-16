import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String baseUrl = ApiConfig.baseUrl})
      : baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  final String baseUrl;
  final HttpClient _client = HttpClient();
  String? accessToken;
  String? refreshToken;

  int _activeRequestCount = 0;
  int get activeRequestCount => _activeRequestCount;
  bool get hasPendingRequests => _activeRequestCount > 0;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query}) =>
      _send('POST', path, body: body, query: query);

  Future<dynamic> put(String path, {Object? body, Map<String, dynamic>? query}) =>
      _send('PUT', path, body: body, query: query);

  Future<dynamic> delete(String path, {Object? body, Map<String, dynamic>? query}) =>
      _send('DELETE', path, body: body, query: query);

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> files,
    Map<String, String> fields = const {},
  }) async {
    _activeRequestCount++;
    try {
      final uri = Uri.parse('$baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}');
      final request = http.MultipartRequest('POST', uri)
        ..headers[HttpHeaders.acceptHeader] = 'application/json'
        ..fields.addAll(fields);
      final token = accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
      for (final entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
      final response = await request.send();
      final text = await response.stream.bytesToString();
      final decoded = _decode(text);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_message(decoded), statusCode: response.statusCode);
      }
      return decoded;
    } finally {
      _activeRequestCount--;
    }
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    _activeRequestCount++;
    try {
      final base = Uri.parse('$baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}');
      final uri = base.replace(
        queryParameters: query?.map(
          (key, value) => MapEntry(key, value == null ? '' : '$value'),
        ),
      );
      final request = await _client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final token = accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final text = await utf8.decoder.bind(response).join();
      final decoded = _decode(text);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_message(decoded), statusCode: response.statusCode);
      }
      return decoded;
    } finally {
      _activeRequestCount--;
    }
  }

  dynamic _decode(String text) {
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  String _message(dynamic decoded) {
    var message = 'تعذر الاتصال بالخادم';
    if (decoded is Map) {
      message = '${decoded['message'] ?? decoded['Message'] ?? decoded['title'] ?? message}';
    } else if (decoded is String && decoded.trim().isNotEmpty) {
      message = decoded;
    }
    return message;
  }

  void close() => _client.close(force: true);
}

Map<String, dynamic> jsonMap(dynamic value) =>
    value is Map<String, dynamic>
        ? value
        : Map<String, dynamic>.from(value as Map);

dynamic jsonValue(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) return map[key];
  final pascal = key.isEmpty ? key : '${key[0].toUpperCase()}${key.substring(1)}';
  if (map.containsKey(pascal)) return map[pascal];
  final lower = key.toLowerCase();
  for (final entry in map.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value;
  }
  return null;
}
