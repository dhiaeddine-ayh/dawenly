import 'dart:convert';
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

  String _provider = 'custom';
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _voiceKeyController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();

  String? _keyHint;
  bool _configured = false;
  String? _source;
  Map<String, dynamic>? _testResult;

  String? _versionSha;
  String? _versionSubject;
  String? _versionDate;

  final Map<String, Map<String, String>> _providersInfo = {
    'custom': {'label': 'مخصص (OpenAI-compatible) 🔌', 'defaultModel': 'gpt-5'},
    'openai': {'label': 'OpenAI 🤖', 'defaultModel': 'gpt-4o'},
    'gemini': {'label': 'Google Gemini ♊', 'defaultModel': 'gemini-2.5-flash'},
    'xai': {'label': 'xAI (Grok) ⚡', 'defaultModel': 'grok-4.6'},
  };

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

  Future<void> _saveAiSettings() async {
    setState(() => _isSaving = true);
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim().isNotEmpty
        ? _modelController.text.trim()
        : _providersInfo[_provider]?['defaultModel'] ?? 'gpt-5';
    final baseUrl = _baseUrlController.text.trim();
    final voiceKey = _voiceKeyController.text.trim();

    // 1. حفظ الإعدادات محلياً على الهاتف دائماً
    await _directAi.saveSettings(
      provider: _provider,
      apiKey: apiKey,
      model: model,
      baseUrl: baseUrl.isNotEmpty ? baseUrl : 'https://helpcoder.cc',
      voiceKey: voiceKey,
    );

    // 2. محاولة حفظ الإعدادات على السيرفر إن كان متصلاً
    try {
      final payload = <String, dynamic>{
        'provider': _provider,
        'model': model,
      };
      if (apiKey.isNotEmpty) payload['api_key'] = apiKey;
      if (_provider == 'custom') payload['base_url'] = baseUrl;
      if (voiceKey.isNotEmpty) payload['voice_key'] = voiceKey;

      await _api.put('/api/admin/ai-settings', body: payload).timeout(const Duration(seconds: 2));
    } catch (_) {}

    await _loadAllSettings();

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ وتفعيل إعدادات الذكاء بنجاح على هاتفك 💾✅',
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
