import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
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

  // إعدادات النطق الصوتي (TTS)
  String _ttsModel = 'deepgram/flux-tts:free';
  String _ttsVoice = 'aura-asteria';
  String _ttsKey = '';

  AudioPlayer? _audioPlayer;
  bool _isPlayingAudio = false;

  String get provider => _provider;
  String get apiKey => _apiKey;
  String get model => _model;
  String get baseUrl => _baseUrl;
  String get voiceKey => _voiceKey;
  String get ttsModel => _ttsModel;
  String get ttsVoice => _ttsVoice;
  String get ttsKey => _ttsKey;
  bool get isConfigured => _apiKey.isNotEmpty;
  bool get isPlayingAudio => _isPlayingAudio;

  AudioPlayer get player {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _provider = prefs.getString('dawenly_ai_provider') ?? 'custom';
    _apiKey = prefs.getString('dawenly_ai_key') ?? '';
    _model = prefs.getString('dawenly_ai_model') ?? 'gpt-5';
    _baseUrl = prefs.getString('dawenly_ai_base_url') ?? 'https://helpcoder.cc';
    _voiceKey = prefs.getString('dawenly_ai_voice_key') ?? '';
    _ttsModel = prefs.getString('dawenly_ai_tts_model') ?? 'deepgram/flux-tts:free';
    _ttsVoice = prefs.getString('dawenly_ai_tts_voice') ?? 'aura-asteria';
    _ttsKey = prefs.getString('dawenly_ai_tts_key') ?? '';
  }

  Future<void> saveSettings({
    required String provider,
    required String apiKey,
    required String model,
    String? baseUrl,
    String? voiceKey,
    String? ttsModel,
    String? ttsVoice,
    String? ttsKey,
  }) async {
    _provider = provider;
    if (apiKey.isNotEmpty) _apiKey = apiKey;
    _model = model;
    if (baseUrl != null) _baseUrl = baseUrl;
    if (voiceKey != null) _voiceKey = voiceKey;
    if (ttsModel != null) _ttsModel = ttsModel;
    if (ttsVoice != null) _ttsVoice = ttsVoice;
    if (ttsKey != null) _ttsKey = ttsKey;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dawenly_ai_provider', _provider);
    if (_apiKey.isNotEmpty) await prefs.setString('dawenly_ai_key', _apiKey);
    await prefs.setString('dawenly_ai_model', _model);
    await prefs.setString('dawenly_ai_base_url', _baseUrl);
    await prefs.setString('dawenly_ai_voice_key', _voiceKey);
    await prefs.setString('dawenly_ai_tts_model', _ttsModel);
    await prefs.setString('dawenly_ai_tts_voice', _ttsVoice);
    if (_ttsKey.isNotEmpty) await prefs.setString('dawenly_ai_tts_key', _ttsKey);
  }

  String _cleanChatEndpoint(String rawBase) {
    var base = rawBase.trim().replaceAll(RegExp(r'/+$'), '');
    if (base.isEmpty) base = 'https://api.openai.com';
    if (base == 'https://openrouter.ai/api/v1') {
      return 'https://openrouter.ai/api/v1/chat/completions';
    }
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
    final base = (baseUrl != null && baseUrl.isNotEmpty)
        ? baseUrl
        : (prov == 'openrouter' ? 'https://openrouter.ai/api/v1' : _baseUrl);

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
        // OpenAI / OpenRouter / Custom (OneAPI / Helpcoder) / Grok
        final endpoint = _cleanChatEndpoint(base);
        final uri = Uri.parse(endpoint);

        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        };
        if (prov == 'openrouter' || endpoint.contains('openrouter')) {
          headers['HTTP-Referer'] = 'https://dawenly.app';
          headers['X-Title'] = 'Dawenly';
        }

        final res = await http.post(
          uri,
          headers: headers,
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

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };
      if (_provider == 'openrouter' || endpoint.contains('openrouter')) {
        headers['HTTP-Referer'] = 'https://dawenly.app';
        headers['X-Title'] = 'Dawenly';
      }

      final res = await http.post(
        uri,
        headers: headers,
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

  /* ===================== تحويل النص لصوت (TTS) ===================== */

  Future<Uint8List?> synthesizeSpeech({
    required String text,
    String? model,
    String? voice,
    String? apiKey,
  }) async {
    final chosenModel = (model != null && model.isNotEmpty) ? model : _ttsModel;
    final chosenVoice = (voice != null && voice.isNotEmpty) ? voice : _ttsVoice;

    final isOpenRouter = chosenModel.contains('flux-tts') ||
        chosenModel.contains('deepgram') ||
        _provider == 'openrouter' ||
        (_ttsKey.isNotEmpty && _ttsKey.startsWith('sk-or-'));

    final openRouterKey = (apiKey != null && apiKey.isNotEmpty)
        ? apiKey
        : (_ttsKey.isNotEmpty
            ? _ttsKey
            : (_provider == 'openrouter' ? _apiKey : ''));

    if (isOpenRouter) {
      if (openRouterKey.isEmpty) {
        debugPrint('OpenRouter TTS key is missing');
        return null;
      }
      try {
        final uri = Uri.parse('https://openrouter.ai/api/v1/audio/speech');
        final res = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openRouterKey',
            'HTTP-Referer': 'https://dawenly.app',
            'X-Title': 'Dawenly',
          },
          body: jsonEncode({
            'model': chosenModel, // 'deepgram/flux-tts:free'
            'input': text,
            'voice': chosenVoice, // 'aura-asteria'
          }),
        ).timeout(const Duration(seconds: 25));

        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res.bodyBytes;
        } else {
          debugPrint('OpenRouter TTS error: ${res.statusCode} - ${res.body}');
        }
      } catch (e) {
        debugPrint('OpenRouter TTS exception: $e');
      }
      return null;
    }

    // OpenAI TTS
    final openAiKey = (apiKey != null && apiKey.isNotEmpty)
        ? apiKey
        : (_voiceKey.isNotEmpty
            ? _voiceKey
            : (_provider == 'openai' ? _apiKey : ''));

    if (openAiKey.isNotEmpty) {
      try {
        final uri = Uri.parse('https://api.openai.com/v1/audio/speech');
        final res = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAiKey',
          },
          body: jsonEncode({
            'model': chosenModel.contains('tts') ? chosenModel : 'tts-1',
            'input': text,
            'voice': chosenVoice.startsWith('aura-') ? 'alloy' : chosenVoice,
          }),
        ).timeout(const Duration(seconds: 25));

        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res.bodyBytes;
        }
      } catch (e) {
        debugPrint('OpenAI TTS exception: $e');
      }
    }
    return null;
  }

  Future<bool> playSpeech(String text, {VoidCallback? onComplete}) async {
    try {
      await stopAudio();
      final bytes = await synthesizeSpeech(text: text);
      if (bytes == null || bytes.isEmpty) return false;

      _isPlayingAudio = true;
      final p = player;
      p.onPlayerComplete.first.then((_) {
        _isPlayingAudio = false;
        if (onComplete != null) onComplete();
      });
      await p.play(BytesSource(bytes));
      return true;
    } catch (e) {
      _isPlayingAudio = false;
      debugPrint('Play speech error: $e');
      return false;
    }
  }

  Future<void> stopAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
    } catch (_) {}
    _isPlayingAudio = false;
  }

  Future<Map<String, dynamic>> testTts({
    String? model,
    String? voice,
    String? apiKey,
  }) async {
    final chosenModel = (model != null && model.isNotEmpty) ? model : _ttsModel;
    final chosenVoice = (voice != null && voice.isNotEmpty) ? voice : _ttsVoice;
    const sampleText = 'مرحباً بك في دوّنلي، تم ضبط وتفعيل الصوت بنجاح!';

    final bytes = await synthesizeSpeech(
      text: sampleText,
      model: chosenModel,
      voice: chosenVoice,
      apiKey: apiKey,
    );

    if (bytes != null && bytes.isNotEmpty) {
      try {
        await stopAudio();
        _isPlayingAudio = true;
        player.onPlayerComplete.first.then((_) {
          _isPlayingAudio = false;
        });
        await player.play(BytesSource(bytes));
      } catch (_) {}
      return {
        'ok': true,
        'model': chosenModel,
        'voice': chosenVoice,
        'bytes': bytes.length,
        'message': 'تم تشغيل الصوت بنجاح 🔊 ($chosenModel)',
      };
    } else {
      return {
        'ok': false,
        'error': 'تعذر استخراج الصوت من $chosenModel. تأكد من إدخال مفتاح OpenRouter بشكل صحيح.',
      };
    }
  }
}
