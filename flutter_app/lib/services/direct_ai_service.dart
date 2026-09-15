import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DirectAiService {
  static final DirectAiService _instance = DirectAiService._internal();
  factory DirectAiService() => _instance;
  DirectAiService._internal();

  String _provider = 'custom';
  String _apiKey = '';
  String _model = 'gpt-5';
  String _baseUrl = 'https://helpcoder.cc';
  String _voiceKey = '';

  String get provider => _provider;
  String get apiKey => _apiKey;
  String get model => _model;
  String get baseUrl => _baseUrl;
  bool get isConfigured => _apiKey.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _provider = prefs.getString('dawenly_ai_provider') ?? 'custom';
    _apiKey = prefs.getString('dawenly_ai_key') ?? '';
    _model = prefs.getString('dawenly_ai_model') ?? 'gpt-5';
    _baseUrl = prefs.getString('dawenly_ai_base_url') ?? 'https://helpcoder.cc';
    _voiceKey = prefs.getString('dawenly_ai_voice_key') ?? '';
  }

  Future<void> saveSettings({
    required String provider,
    required String apiKey,
    required String model,
    String? baseUrl,
    String? voiceKey,
  }) async {
    _provider = provider;
    if (apiKey.isNotEmpty) _apiKey = apiKey;
    _model = model;
    if (baseUrl != null) _baseUrl = baseUrl;
    if (voiceKey != null) _voiceKey = voiceKey;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dawenly_ai_provider', _provider);
    if (_apiKey.isNotEmpty) await prefs.setString('dawenly_ai_key', _apiKey);
    await prefs.setString('dawenly_ai_model', _model);
    await prefs.setString('dawenly_ai_base_url', _baseUrl);
    await prefs.setString('dawenly_ai_voice_key', _voiceKey);
  }

  String _cleanChatEndpoint(String rawBase) {
    var base = rawBase.trim().replaceAll(RegExp(r'/+$'), '');
    if (base.isEmpty) base = 'https://api.openai.com';
    if (!base.endsWith('/v1') && !base.endsWith('/v1/chat/completions')) {
      base = '$base/v1';
    }
    if (base.endsWith('/v1')) {
      return '$base/chat/completions';
    }
    return base;
  }

  Future<Map<String, dynamic>> testConnection({
    String? provider,
    String? apiKey,
    String? model,
    String? baseUrl,
  }) async {
    final prov = provider ?? _provider;
    final key = (apiKey != null && apiKey.isNotEmpty) ? apiKey : _apiKey;
    final mod = (model != null && model.isNotEmpty) ? model : _model;
    final base = baseUrl ?? _baseUrl;

    if (key.isEmpty) {
      return {'ok': false, 'error': 'لم يتم إدخال مفتاح الـ API'};
    }

    try {
      if (prov == 'gemini') {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$mod:generateContent?key=$key',
        );
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': 'رد بكلمة واحدة: تمام'}
                ]
              }
            ]
          }),
        ).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'تمام';
          return {'ok': true, 'model': mod, 'reply': reply.toString().trim()};
        } else {
          return {'ok': false, 'error': 'Gemini Error: ${res.statusCode} - ${res.body}'};
        }
      } else {
        // OpenAI / Custom (OneAPI / Helpcoder) / Grok
        final endpoint = _cleanChatEndpoint(base);
        final uri = Uri.parse(endpoint);

        final res = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          },
          body: jsonEncode({
            'model': mod,
            'messages': [
              {'role': 'user', 'content': 'رد بكلمة واحدة فقط: تمام'}
            ],
            'max_tokens': 20,
          }),
        ).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          final reply = data['choices']?[0]?['message']?['content'] ?? 'تمام';
          return {'ok': true, 'model': mod, 'reply': reply.toString().trim()};
        } else {
          String errMsg = 'HTTP ${res.statusCode}';
          try {
            final errObj = jsonDecode(utf8.decode(res.bodyBytes));
            errMsg = errObj['error']?['message'] ?? errObj['message'] ?? errMsg;
          } catch (_) {}
          return {'ok': false, 'error': errMsg};
        }
      }
    } catch (e) {
      return {'ok': false, 'error': 'تعذر الاتصال بالمزود: $e'};
    }
  }

  Future<String?> chat({
    required List<Map<String, String>> messages,
    String? systemPrompt,
  }) async {
    if (_apiKey.isEmpty) await init();
    if (_apiKey.isEmpty) return null;

    try {
      final endpoint = _cleanChatEndpoint(_baseUrl);
      final uri = Uri.parse(endpoint);

      final promptMessages = <Map<String, String>>[];
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        promptMessages.add({'role': 'system', 'content': systemPrompt});
      }
      promptMessages.addAll(messages);

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': promptMessages,
          'max_tokens': 1500,
        }),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['choices']?[0]?['message']?['content']?.toString();
      }
    } catch (e) {
      debugPrint('Direct AI chat error: $e');
    }
    return null;
  }
}
