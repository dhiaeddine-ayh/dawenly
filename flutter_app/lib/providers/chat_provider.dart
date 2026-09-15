import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/chat_message.dart';
import '../services/local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final LocalStorageService _storage = LocalStorageService();
  final List<ChatMessageModel> _messages = [];
  bool _isSending = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isSending => _isSending;

  Future<void> loadHistory() async {
    try {
      final res = await _api.get('/api/ask/history');
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          _messages.clear();
          for (final item in list) {
            final role = item['role']?.toString();
            final content = item['content']?.toString() ?? '';
            if (content.isNotEmpty) {
              _messages.add(ChatMessageModel(
                id: (item['id']?.toString()) ?? DateTime.now().millisecondsSinceEpoch.toString(),
                text: content,
                isUser: role == 'user',
                timestamp: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
              ));
            }
          }
          if (_messages.isNotEmpty) {
            notifyListeners();
            return;
          }
        }
      }
    } catch (_) {}

    // استرجاع التاريخ المحلي عند انقطاع الاتصال
    try {
      final data = await _storage.loadData();
      final list = (data['chat'] ?? []) as List;
      _messages.clear();

      for (final item in list) {
        final text = item['text']?.toString() ?? '';
        if (text.isNotEmpty) {
          _messages.add(ChatMessageModel(
            id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            text: text,
            isUser: item['is_user'] == true,
            timestamp: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
          ));
        }
      }

      if (_messages.isEmpty) {
        _messages.add(ChatMessageModel.fromAi(
          'أهلاً بك في دوّنلي! أنا مساعدك الشخصي الذكي، جاهز دائماً لمساعدتك في تنظيم يومك، تتبع عاداتك، والإجابة عن أي تساؤل من واقع دفترك 🌟',
        ));
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> sendMessage(String text, {String scope = 'all', bool fast = false}) async {
    final query = text.trim();
    if (query.isEmpty) return;

    final userMsg = ChatMessageModel.fromUser(query);
    _messages.add(userMsg);
    _isSending = true;
    notifyListeners();

    try {
      final payload = _messages
          .where((m) => m.text.isNotEmpty)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      final res = await _api.post('/api/ask', body: {
        'messages': payload,
        'scope': scope,
        'fast': fast,
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final reply = data['reply']?.toString() ?? '';
        if (reply.isNotEmpty) {
          _messages.add(ChatMessageModel.fromAi(reply));
          _isSending = false;
          notifyListeners();
          await _persistChatHistory();
          return;
        }
      }
    } catch (e) {
      debugPrint('Chat API error: $e');
    }

    // بديل ذكي محلي في حالة تعذر الوصول للسيرفر
    await Future.delayed(const Duration(milliseconds: 500));
    final fallback = _generateLocalAiReply(query);
    _messages.add(ChatMessageModel.fromAi(fallback));
    _isSending = false;
    notifyListeners();

    await _persistChatHistory();
  }

  Future<void> clearHistory() async {
    try {
      await _api.delete('/api/ask/history');
    } catch (_) {}
    _messages.clear();
    _messages.add(ChatMessageModel.fromAi(
      'تم مسح المحادثة السابقة بنجاح. كيف يمكنني مساعدتك الآن؟ ✨',
    ));
    notifyListeners();
    await _persistChatHistory();
  }

  void addDirectAiMessage(String text) {
    _messages.add(ChatMessageModel.fromAi(text));
    notifyListeners();
    _persistChatHistory();
  }

  Future<void> _persistChatHistory() async {
    try {
      final data = await _storage.loadData();
      data['chat'] = _messages.map((m) => {
        'id': m.id,
        'text': m.text,
        'is_user': m.isUser,
        'created_at': m.timestamp.toIso8601String(),
      }).toList();
      await _storage.saveData(data);
    } catch (_) {}
  }

  String _generateLocalAiReply(String query) {
    final q = query.toLowerCase();

    if (q.contains('مرحبا') || q.contains('أهلا') || q.contains('سلام') || q.contains('مساء') || q.contains('صباح')) {
      return 'أهلاً وسهلاً بك! كيف يمكنني مساعدتك في تنظيم يومك ومتابعة إنجازاتك اليوم؟ 😊';
    }

    if (q.contains('عادة') || q.contains('عادات') || q.contains('التزام') || q.contains('روتين')) {
      return 'العادات تبنى بالاستمرارية اليومية وليس بالجهد المضاعف المؤقت! حاول البدء بخطوات بسيطة (أقل من 5 دقائق يومياً) وثبّت وقتها في جدولك، وسجل تقدمك يومياً في تبويب **العادات** 🌿';
    }

    if (q.contains('مهمة') || q.contains('مهام') || q.contains('تسويف') || q.contains('تنظيم') || q.contains('شغل')) {
      return 'لتنظيم مهامك بكفاءة:\n1. حدد **3 مهام رئيسية فقط** تركز عليها اليوم.\n2. قسّم المهام الكبيرة إلى خطوات صغيرة سهلة البدء.\n3. استخدم مؤقت للعمل 25 دقيقة متواصلة دون مقاطعات.\n\nتستطيع إضافة مهامك ومتابعتها مباشرة من تبويب **المهام** ✅';
    }

    if (q.contains('فلوس') || q.contains('مصاريف') || q.contains('ميزانية') || q.contains('صرف') || q.contains('دخل')) {
      return 'أهم قاعدة مالية هي **«ادخر قبل أن تنفق»**! سجل كل نفقة مهما كانت بسيطة فور حدوثها في تبويب **المالية** لتتعرف على وجهة أموالك وتتحكم في ميزانيتك الشهرية بدقة 🪙';
    }

    if (q.contains('صحة') || q.contains('تعب') || q.contains('نوم') || q.contains('مزاج') || q.contains('رياضة')) {
      return 'صحتك وراحتك النفسية هي محرك كل إنتاجية! احرص على:\n- شرب كوب ماء كل ساعة.\n- المشي وتغيير وضعية الجلوس.\n- النوم من 7 إلى 8 ساعات يومياً.\n\nيمكنك تسجيل حالتك ومزاجك اليومي في تبويب **الصحة** 🩺';
    }

    if (q.contains('هدف') || q.contains('أهداف') || q.contains('حلم') || q.contains('خطة')) {
      return 'الأهداف الواضحة المحددة بوقت تزيد نسبة تحقيقها بـ 80%! حدد موعداً نهائياً لكل هدف وقسمه إلى محطات شهرية، وتابع مؤشر تقدمك في تبويب **الأهداف** 🎯';
    }

    if (q.contains('شكرا') || q.contains('تسلم') || q.contains('يعطيك')) {
      return 'العفو، دائماً في خدمتك! أنا هنا لمساعدتك في أي وقت لتحقيق أفضل ما لديك ✨';
    }

    return 'سؤال ممتاز! لتطبيق ذلك في يومك، دوّن أفكارك وخطواتك القادمة أولاً بأول. تذكر أن التغيير الحقيقي يبدأ بالتدوين المنتظم والمراجعة اليومية. هل ترغب في إضافة مهمة أو فكرة جديدة في دفترك الآن؟ 💡';
  }
}
