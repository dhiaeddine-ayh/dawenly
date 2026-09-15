import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String _baseUrl = AppConstants.defaultLocalUrl;
  String? _token;

  String get baseUrl => _baseUrl;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('dawenly_token');
    _baseUrl = prefs.getString('dawenly_base_url') ?? AppConstants.defaultLocalUrl;
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dawenly_base_url', _baseUrl);
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('dawenly_token', token);
    } else {
      await prefs.remove('dawenly_token');
    }
  }

  Map<String, String> get _headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_token';
    }
    return map;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$_baseUrl$cleanPath';
    return Uri.parse(fullUrl).replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    final uri = _buildUri(path, query);
    return await http.get(uri, headers: _headers);
  }

  Future<http.Response> post(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    return await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    return await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String path) async {
    final uri = _buildUri(path);
    return await http.delete(uri, headers: _headers);
  }

  // إرسال الصوت الخام إلى /api/voice
  Future<http.Response> uploadVoice(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final uri = _buildUri('/api/voice');

    final headers = <String, String>{
      'Content-Type': 'audio/m4a',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return await http.post(uri, headers: headers, body: bytes);
  }
}
