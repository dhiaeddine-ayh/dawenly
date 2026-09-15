import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_button.dart';
import '../../core/design_system/sketch_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

import '../../services/direct_ai_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final ApiClient _api = ApiClient();
  final DirectAiService _directAi = DirectAiService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;
  bool _isCheckingVersion = false;

  bool _obscureApiKey = true;
  bool _obscureVoiceKey = true;
  bool _obscureTtsKey = true;
  bool _isTestingTts = false;

  String _provider = 'custom';
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _voiceKeyController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();

  // إعدادات الصوت والنطق TTS
  String _ttsModel = 'deepgram/flux-tts:free';
  String _ttsVoice = 'aura-asteria';
  final TextEditingController _ttsKeyController = TextEditingController();
  final TextEditingController _ttsModelController = TextEditingController(text: 'deepgram/flux-tts:free');
  Map<String, dynamic>? _ttsTestResult;
  String? _ttsKeyHint;

  String? _keyHint;
  bool _configured = false;
  String? _source;
  Map<String, dynamic>? _testResult;

  String? _versionSha;
  String? _versionSubject;
  String? _versionDate;

  final Map<String, Map<String, String>> _providersInfo = {
    'custom': {'label': 'مخصص (OpenAI-compatible) 🔌', 'defaultModel': 'gpt-5'},
    'openrouter': {'label': 'OpenRouter (يدعم النطق المجاني) 🌐', 'defaultModel': 'deepseek/deepseek-chat'},
    'openai': {'label': 'OpenAI 🤖', 'defaultModel': 'gpt-4o'},
    'gemini': {'label': 'Google Gemini ♊', 'defaultModel': 'gemini-2.5-flash'},
    'xai': {'label': 'xAI (Grok) ⚡', 'defaultModel': 'grok-4.6'},
  };

  final List<Map<String, String>> _deepgramVoices = [
    {'id': 'aura-asteria', 'label': 'Asteria (أنثوي واضح 🌸 - الافتراضي)'},
    {'id': 'aura-luna', 'label': 'Luna (أنثوي هادئ 🌙)'},
    {'id': 'aura-stella', 'label': 'Stella (أنثوي مشرق ✨)'},
    {'id': 'aura-athena', 'label': 'Athena (أنثوي واثق ورسمي 🏛️)'},
    {'id': 'aura-hera', 'label': 'Hera (أنثوي دافئ 🌿)'},
    {'id': 'aura-orion', 'label': 'Orion (ذكوري هادئ ومتزن 🎙️)'},
    {'id': 'aura-arcas', 'label': 'Arcas (ذكوري عميق 🏔️)'},
    {'id': 'aura-perseus', 'label': 'Perseus (ذكوري حيوي ⚡)'},
    {'id': 'aura-angus', 'label': 'Angus (ذكوري ناعم 🍂)'},
    {'id': 'aura-helios', 'label': 'Helios (ذكوري قوي ☀️)'},
    {'id': 'aura-zeus', 'label': 'Zeus (ذكوري فخم 👑)'},
  ];

  @override
  void initState() {
    super.initState();
    _serverUrlController.text = _api.baseUrl;
    _loadAllSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    _voiceKeyController.dispose();
    _serverUrlController.dispose();
    _ttsKeyController.dispose();
    _ttsModelController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSettings() async {
    setState(() => _isLoading = true);

    await _directAi.init();
    if (_directAi.isConfigured) {
      _provider = _directAi.provider;
      _modelController.text = _directAi.model;
      _baseUrlController.text = _directAi.baseUrl;
      _keyHint = _directAi.apiKey.length > 4
          ? '…${_directAi.apiKey.substring(_directAi.apiKey.length - 4)}'
          : _directAi.apiKey;
      _configured = true;
      _source = 'local';
    }

    _ttsModel = _directAi.ttsModel;
    _ttsVoice = _directAi.ttsVoice;
    _ttsModelController.text = _ttsModel;
    if (_directAi.ttsKey.isNotEmpty) {
      _ttsKeyHint = _directAi.ttsKey.length > 4
          ? '…${_directAi.ttsKey.substring(_directAi.ttsKey.length - 4)}'
          : _directAi.ttsKey;
    }

    try {
      final res = await _api.get('/api/admin/ai-settings').timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          _configured = data['configured'] == true || _configured;
          _source = data['source']?.toString() ?? _source;
          _provider = data['provider']?.toString() ?? _provider;
          if (_modelController.text.isEmpty) {
            _modelController.text = data['model']?.toString() ??
                _providersInfo[_provider]?['defaultModel'] ?? 'gpt-5';
          }
          if (_baseUrlController.text.isEmpty) {
            _baseUrlController.text = data['baseUrl']?.toString() ?? 'https://helpcoder.cc';
          }
          _keyHint = data['keyHint']?.toString() ?? _keyHint;

          if (data['ttsModel'] != null && data['ttsModel'].toString().isNotEmpty) {
            _ttsModel = data['ttsModel'].toString();
            _ttsModelController.text = _ttsModel;
          }
          if (data['ttsVoice'] != null && data['ttsVoice'].toString().isNotEmpty) {
            _ttsVoice = data['ttsVoice'].toString();
          }
          if (data['ttsKeyHint'] != null) {
            _ttsKeyHint = data['ttsKeyHint'].toString();
          }
        });
      }
    } catch (_) {}

    try {
      final vRes = await _api.get('/api/admin/version').timeout(const Duration(seconds: 2));
      if (vRes.statusCode == 200) {
        final vData = jsonDecode(utf8.decode(vRes.bodyBytes)) as Map<String, dynamic>;
        final cur = vData['current'] as Map<String, dynamic>?;
        if (cur != null) {
          setState(() {
            _versionSha = cur['sha']?.toString();
            _versionSubject = cur['subject']?.toString();
            _versionDate = cur['date']?.toString();
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAiConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim().isNotEmpty
        ? _modelController.text.trim()
        : (_providersInfo[_provider]?['defaultModel'] ?? 'gpt-5');
    final baseUrl = _baseUrlController.text.trim().isNotEmpty
        ? _baseUrlController.text.trim()
        : _directAi.baseUrl;

    // 1. أولاً: اختبار الاتصال المباشر من الهاتف (يعمل بدون الحاجة لسيرفر محلي)
    final directRes = await _directAi.testConnection(
      provider: _provider,
      apiKey: apiKey.isNotEmpty ? apiKey : _directAi.apiKey,
      model: model,
      baseUrl: baseUrl,
    );

    if (directRes['ok'] == true) {
      if (mounted) {
        setState(() {
          _testResult = {
            'ok': true,
            'model': directRes['model'],
            'reply': '${directRes['reply']} (اتصال مباشر ناجح ⚡)',
          };
          _configured = true;
          _isTesting = false;
        });
      }
      return;
    }

    // 2. ثانياً: إذا كان السيرفر متاحاً نجرب من خلاله أيضاً
    try {
      final payload = <String, dynamic>{
        'provider': _provider,
      };
      if (apiKey.isNotEmpty) payload['api_key'] = apiKey;
      payload['model'] = model;
      if (_provider == 'custom') payload['base_url'] = baseUrl;

      final res = await _api.post('/api/admin/ai-settings/test', body: payload);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        if (mounted) setState(() => _testResult = data);
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _testResult = {
          'ok': false,
          'error': directRes['error'] ?? 'تعذر الاتصال بمزود الذكاء',
        };
        _isTesting = false;
      });
    }
  }

  Future<void> _testTtsSound() async {
    setState(() {
      _isTestingTts = true;
      _ttsTestResult = null;
    });

    final model = _ttsModelController.text.trim().isNotEmpty
        ? _ttsModelController.text.trim()
        : 'deepgram/flux-tts:free';
    final key = _ttsKeyController.text.trim().isNotEmpty
        ? _ttsKeyController.text.trim()
        : (_provider == 'openrouter' ? _apiKeyController.text.trim() : '');

    // 1. تجربة النطق المباشر من الهاتف (Direct TTS on phone)
    final directRes = await _directAi.testTts(
      model: model,
      voice: _ttsVoice,
      apiKey: key.isNotEmpty ? key : null,
    );

    if (directRes['ok'] == true) {
      if (mounted) {
        setState(() {
          _ttsTestResult = directRes;
          _isTestingTts = false;
        });
      }
      return;
    }

    // 2. إذا تعذر مباشرة، نجرب من خلال السيرفر إن كان متاحاً
    try {
      final res = await _api.post('/api/admin/ai-settings/test-tts', body: {
        'model': model,
        'voice': _ttsVoice,
        'key': key,
        'provider': _provider,
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        if (data['ok'] == true && data['audioBase64'] != null) {
          final audioBytes = base64Decode(data['audioBase64']);
          await _directAi.player.play(BytesSource(audioBytes));
          if (mounted) {
            setState(() {
              _ttsTestResult = {
                'ok': true,
                'model': model,
                'voice': _ttsVoice,
                'message': 'تم تشغيل الصوت بنجاح عبر الخادم 🔊 ($model)',
              };
              _isTestingTts = false;
            });
          }
          return;
        } else if (mounted) {
          setState(() {
            _ttsTestResult = {
              'ok': false,
              'error': data['error'] ?? directRes['error'] ?? 'تعذر تشغيل الصوت',
            };
            _isTestingTts = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _ttsTestResult = {
          'ok': false,
          'error': directRes['error'] ?? 'تعذر اختبار الصوت. تحقق من مفتاح OpenRouter.',
        };
        _isTestingTts = false;
      });
    }
  }

  Future<void> _saveAiSettings() async {
    setState(() => _isSaving = true);
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim().isNotEmpty
        ? _modelController.text.trim()
        : _providersInfo[_provider]?['defaultModel'] ?? 'gpt-5';
    final baseUrl = _baseUrlController.text.trim();
    final voiceKey = _voiceKeyController.text.trim();
    final ttsModel = _ttsModelController.text.trim().isNotEmpty
        ? _ttsModelController.text.trim()
        : 'deepgram/flux-tts:free';
    final ttsKey = _ttsKeyController.text.trim();

    // 1. حفظ الإعدادات محلياً على الهاتف دائماً
    await _directAi.saveSettings(
      provider: _provider,
      apiKey: apiKey,
      model: model,
      baseUrl: baseUrl.isNotEmpty ? baseUrl : 'https://helpcoder.cc',
      voiceKey: voiceKey,
      ttsModel: ttsModel,
      ttsVoice: _ttsVoice,
      ttsKey: ttsKey,
    );

    // 2. محاولة حفظ الإعدادات على السيرفر إن كان متصلاً
    try {
      final payload = <String, dynamic>{
        'provider': _provider,
        'model': model,
        'tts_model': ttsModel,
        'tts_voice': _ttsVoice,
      };
      if (apiKey.isNotEmpty) payload['api_key'] = apiKey;
      if (_provider == 'custom') payload['base_url'] = baseUrl;
      if (voiceKey.isNotEmpty) payload['voice_key'] = voiceKey;
      if (ttsKey.isNotEmpty) payload['tts_key'] = ttsKey;

      await _api.put('/api/admin/ai-settings', body: payload).timeout(const Duration(seconds: 2));
    } catch (_) {}

    await _loadAllSettings();

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ وتفعيل إعدادات الذكاء والصوت بنجاح 💾🔊✅',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.brand,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveServerUrl() async {
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) return;

    await _api.setBaseUrl(url);
    if (!mounted) return;
    await context.read<AuthProvider>().setBaseUrl(url);
    if (!mounted) return;
    context.read<DataProvider>().loadAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث عنوان الخادم: $url 🌐',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.brand,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _checkUpdates() async {
    setState(() => _isCheckingVersion = true);
    try {
      final res = await _api.get('/api/admin/version');
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final cur = data['current'] as Map<String, dynamic>?;
        if (cur != null) {
          setState(() {
            _versionSha = cur['sha']?.toString();
            _versionSubject = cur['subject']?.toString();
            _versionDate = cur['date']?.toString();
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['updateAvailable'] == true
                    ? 'يوجد تحديث متاح للتطبيق! ⬇️'
                    : 'التطبيق على أحدث إصدار بالفعل ✨',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.brand,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فحص التحديثات: $e', style: GoogleFonts.tajawal()),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingVersion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllSettings,
      color: AppColors.brand,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة (Page Header)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandWash,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.brandTint),
                ),
                child: Text(
                  '⚙️ إعدادات التطبيق',
                  style: GoogleFonts.tajawal(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDeep,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'الضبط والتهيئة',
                style: GoogleFonts.lemonada(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'اضبط مزود الذكاء، إعدادات الخادم، وتحديثات دوّنلي بسهولة.',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. كارت مزود الذكاء الاصطناعي (AI Provider Settings)
          SketchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🧠', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'مزود الذكاء الاصطناعي',
                          style: GoogleFonts.lemonada(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _configured ? AppColors.brandWash : Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _configured ? AppColors.brand : Colors.amber.shade700,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        _configured
                            ? 'جاهز (${_source ?? 'db'})'
                            : 'يحتاج تهيئة',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _configured ? AppColors.brandDeep : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'المزود المسؤول عن استخراج المهام واليوميات والردود السياقية الصوتية والكتابية.',
                  style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 16),

                // اختيار المزود
                Text('المزود:', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _providersInfo.containsKey(_provider) ? _provider : 'gemini',
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.ink),
                      items: _providersInfo.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            e.value['label']!,
                            style: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _provider = val;
                            if (_modelController.text.isEmpty ||
                                _providersInfo.values.any((p) => p['defaultModel'] == _modelController.text)) {
                              _modelController.text = _providersInfo[val]?['defaultModel'] ?? '';
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // مفتاح الـ API
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مفتاح الـ API:', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (_keyHint != null)
                      Text(
                        'المفتاح الحالي: $_keyHint',
                        style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.brandDeep, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    hintText: _keyHint != null ? 'اتركه فارغاً للحفاظ على المفتاح الحالي' : 'ضع مفتاح الـ API هنا...',
                    hintStyle: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkFaint),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.inkMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // اسم الموديل
                Text('اسم الموديل (Model):', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    hintText: _providersInfo[_provider]?['defaultModel'] ?? 'اسم الموديل',
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                  ),
                ),

                // Base URL في حالة المزود المخصص
                if (_provider == 'custom') ...[
                  const SizedBox(height: 14),
                  Text('عنوان الخادم المخصص (Base URL):', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                      hintText: 'https://api.groq.com/openai/v1',
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                      ),
                    ),
                  ),
                ],

                // مفتاح OpenAI للصوت (اختياري عند اختيار غير OpenAI)
                if (_provider != 'openai') ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('مفتاح OpenAI للصوت (اختياري):', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('(لتفريغ Whisper والنطق)', style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.inkMuted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _voiceKeyController,
                    obscureText: _obscureVoiceKey,
                    decoration: InputDecoration(
                      hintText: 'sk-...',
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureVoiceKey ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.inkMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureVoiceKey = !_obscureVoiceKey),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // نتائج الاختبار الحي إن وجدت
                if (_testResult != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testResult!['ok'] == true
                          ? AppColors.brandWash
                          : AppColors.healthWash,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _testResult!['ok'] == true ? AppColors.brand : AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _testResult!['ok'] == true ? '✅' : '❌',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _testResult!['ok'] == true
                                    ? 'تم التحقق بنجاح! الاتصال يعمل بكفاءة.'
                                    : 'فشل اختبار المزود:',
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: _testResult!['ok'] == true
                                      ? AppColors.brandDeep
                                      : AppColors.dangerDeep,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _testResult!['ok'] == true
                                    ? 'الموديل: ${_testResult!['model'] ?? _modelController.text}'
                                    : '${_testResult!['error'] ?? 'خطأ غير محدد'}',
                                style: GoogleFonts.tajawal(fontSize: 11.5, color: AppColors.ink),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // أزرار الحفظ والاختبار
                Row(
                  children: [
                    Expanded(
                      child: SketchButton.secondary(
                        text: _isTesting ? 'جاري الفحص…' : '🧪 اختبار المزود',
                        onPressed: _isTesting ? () {} : _testAiConnection,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SketchButton.primary(
                        text: _isSaving ? 'جاري الحفظ…' : '💾 حفظ الإعدادات',
                        onPressed: _isSaving ? () {} : _saveAiSettings,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2.5 كارت إعدادات الصوت والنطق (TTS Settings - OpenRouter / deepgram/flux-tts:free)
          SketchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🔊', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'إعدادات الصوت والنطق (TTS)',
                          style: GoogleFonts.lemonada(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.brandWash,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.brand, width: 1.2),
                      ),
                      child: Text(
                        'OpenRouter 🆓',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandDeep,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'تحويل النص لصوت ونطق ردود المساعد عبر موديل deepgram/flux-tts:free المجاني من مزود OpenRouter.',
                  style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 16),

                // اسم الموديل مع زر تعيين الافتراضي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('موديل الصوت (TTS Model):', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _ttsModelController.text = 'deepgram/flux-tts:free';
                          _ttsVoice = 'aura-asteria';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandWash,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.brand, width: 1),
                        ),
                        child: Text(
                          'الموديل الافتراضي المجاني ✨',
                          style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.brandDeep),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _ttsModelController,
                  decoration: InputDecoration(
                    hintText: 'deepgram/flux-tts:free',
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // اختيار نبرة الصوت (Deepgram Aura Voices)
                Text('نبرة الصوت (Aura Voice):', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _deepgramVoices.any((v) => v['id'] == _ttsVoice) ? _ttsVoice : 'aura-asteria',
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.ink),
                      items: _deepgramVoices.map((v) {
                        return DropdownMenuItem(
                          value: v['id'],
                          child: Text(
                            v['label']!,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _ttsVoice = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // مفتاح OpenRouter للصوت
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مفتاح OpenRouter للصوت:', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (_ttsKeyHint != null)
                      Text(
                        'المفتاح: $_ttsKeyHint',
                        style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.brandDeep, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _provider == 'openrouter'
                      ? '💡 يتم استخدام مفتاح OpenRouter الرئيسي تلقائياً، أو يمكنك إدخال مفتاح مخصص هنا.'
                      : 'أدخل مفتاح OpenRouter (sk-or-...) لتفعيل نطق الصوت بموديل deepgram/flux-tts:free.',
                  style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _ttsKeyController,
                  obscureText: _obscureTtsKey,
                  decoration: InputDecoration(
                    hintText: _ttsKeyHint != null ? 'الحفاظ على المفتاح المحفوظ ($_ttsKeyHint)' : 'sk-or-v1-...',
                    hintStyle: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkFaint),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureTtsKey ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.inkMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureTtsKey = !_obscureTtsKey),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // نتائج اختبار الصوت إن وجدت
                if (_ttsTestResult != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _ttsTestResult!['ok'] == true
                          ? AppColors.brandWash
                          : AppColors.healthWash,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _ttsTestResult!['ok'] == true ? AppColors.brand : AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _ttsTestResult!['ok'] == true ? '🔊' : '❌',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ttsTestResult!['ok'] == true
                                    ? 'تم نطق الصوت بنجاح عبر مكبر الصوت 🎵'
                                    : 'فشل اختبار الصوت:',
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: _ttsTestResult!['ok'] == true
                                      ? AppColors.brandDeep
                                      : AppColors.dangerDeep,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _ttsTestResult!['ok'] == true
                                    ? '${_ttsTestResult!['message'] ?? 'الموديل جاهز للاستخدام في دوّنلي!'}'
                                    : '${_ttsTestResult!['error'] ?? 'خطأ غير معروف'}',
                                style: GoogleFonts.tajawal(fontSize: 11.5, color: AppColors.ink),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // أزرار تجربة النطق وحفظ إعدادات الصوت
                Row(
                  children: [
                    Expanded(
                      child: SketchButton.secondary(
                        text: _isTestingTts ? 'جاري التشغيل… 🔊' : '🔊 تجربة الصوت والنطق',
                        onPressed: _isTestingTts ? () {} : _testTtsSound,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SketchButton.primary(
                        text: _isSaving ? 'جاري الحفظ…' : '💾 حفظ إعدادات الصوت',
                        onPressed: _isSaving ? () {} : _saveAiSettings,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. كارت إعدادات الخادم والاتصال (Server & Network)
          SketchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'خادم دوّنلي (Server API)',
                      style: GoogleFonts.lemonada(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'عنوان السيرفر المحلي أو الشبكي الذي يتصل به تطبيق فلاتر.',
                  style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _serverUrlController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الخادم (Base URL)',
                    hintText: 'http://127.0.0.1:3000',
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SketchButton.secondary(
                  text: 'حفظ عنوان الخادم وإعادة الاتصال',
                  onPressed: _saveServerUrl,
                ),
                const SizedBox(height: 14),

                // صندوق مساعدة وتوجيه للهاتف المحمول
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandWash,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.brandTint, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📱', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            'تنبيه لمستخدمي الهاتف المحمول:',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandDeep,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'عند تشغيل التطبيق من الهاتف، كلمة localhost تعني الهاتف نفسه وليس حاسوبك.\n• إذا أردت ربط الهاتف بسيرفر الحاسوب عبر شبكة Wi-Fi، استخدم IP الحاسوب المحلي:',
                        style: GoogleFonts.tajawal(fontSize: 11.5, color: AppColors.inkMuted, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() => _serverUrlController.text = 'http://192.168.1.10:3000');
                          _saveServerUrl();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brand, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi, size: 16, color: AppColors.brand),
                              const SizedBox(width: 6),
                              Text(
                                'تعيين IP الحاسوب: http://192.168.1.10:3000',
                                style: GoogleFonts.tajawal(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• أو يمكنك استخدام وضع الذكاء المباشر عبر إدخال مفتاحك والموديل في الكارت أعلاه دون الحاجة لتشغيل أي سيرفر!',
                        style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.brandDeep, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 4. كارت إصدار النظام والتحديثات (Version & About)
          SketchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📦', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'نظام دوّنلي ومعلومات النسخة',
                      style: GoogleFonts.lemonada(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_versionSha != null) ...[
                  Text('الكوميت الحالي: $_versionSha', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold)),
                  if (_versionSubject != null) ...[
                    const SizedBox(height: 2),
                    Text('$_versionSubject', style: GoogleFonts.tajawal(fontSize: 11.5, color: AppColors.inkMuted)),
                  ],
                  if (_versionDate != null) ...[
                    const SizedBox(height: 2),
                    Text('تاريخ التحديث: ${_versionDate!.split('T').first}', style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.inkFaint)),
                  ],
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: SketchButton.secondary(
                        text: _isCheckingVersion ? 'جاري الفحص…' : '🔄 فحص التحديثات',
                        onPressed: _isCheckingVersion ? () {} : _checkUpdates,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SketchButton.secondary(
                        text: 'مزامنة البيانات 🔄',
                        onPressed: () {
                          context.read<DataProvider>().loadAll();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت مزامنة جميع العوالم بنجاح ✅', style: GoogleFonts.tajawal()),
                              backgroundColor: AppColors.brand,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
