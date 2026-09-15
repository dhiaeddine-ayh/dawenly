import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawenly_app/services/direct_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DirectAiService & OpenRouter TTS Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('DirectAiService initializes with default deepgram/flux-tts:free', () async {
      final service = DirectAiService();
      await service.init();

      expect(service.ttsModel, 'deepgram/flux-tts:free');
      expect(service.ttsVoice, 'aura-asteria');
    });

    test('DirectAiService saves and retrieves OpenRouter TTS settings', () async {
      final service = DirectAiService();
      await service.saveSettings(
        provider: 'openrouter',
        apiKey: 'sk-or-v1-testkey123456',
        model: 'deepseek/deepseek-chat',
        ttsModel: 'deepgram/flux-tts:free',
        ttsVoice: 'aura-luna',
        ttsKey: 'sk-or-v1-testkey123456',
      );

      expect(service.provider, 'openrouter');
      expect(service.apiKey, 'sk-or-v1-testkey123456');
      expect(service.ttsModel, 'deepgram/flux-tts:free');
      expect(service.ttsVoice, 'aura-luna');
      expect(service.ttsKey, 'sk-or-v1-testkey123456');
    });
  });
}
