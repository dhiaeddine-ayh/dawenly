import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _storageFileName = 'dawenly_offline_data.json';
  File? _dataFile;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _dataFile = File('${dir.path}/$_storageFileName');
      _initialized = true;
    } catch (_) {
      _initialized = true;
    }
  }

  Future<Map<String, dynamic>> loadData() async {
    await init();
    try {
      if (_dataFile != null && await _dataFile!.exists()) {
        final content = await _dataFile!.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      }
    } catch (_) {}

    // Fallback to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final backup = prefs.getString('dawenly_offline_backup');
      if (backup != null && backup.isNotEmpty) {
        final decoded = jsonDecode(backup);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}

    // First run: return rich default seed data
    final initial = _getInitialSeedData();
    await saveData(initial);
    return initial;
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    await init();
    final jsonStr = jsonEncode(data);
    try {
      if (_dataFile != null) {
        await _dataFile!.writeAsString(jsonStr, flush: true);
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dawenly_offline_backup', jsonStr);
    } catch (_) {}
  }

  Map<String, dynamic> _getInitialSeedData() {
    final now = DateTime.now();
    final todayIso = now.toIso8601String().substring(0, 10);
    final yesterdayIso = now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

    return {
      'habits': [
        {
          'id': 1,
          'title': 'قراءة أذكار الصباح وتدبر القرآن',
          'icon': '📖',
          'streak': 6,
          'logs': [todayIso, yesterdayIso],
        },
        {
          'id': 2,
          'title': 'ممارسة الرياضة الصباحية 25 دقيقة',
          'icon': '🏃',
          'streak': 4,
          'logs': [todayIso, yesterdayIso],
        },
        {
          'id': 3,
          'title': 'شرب 2 لتر من الماء على مدار اليوم',
          'icon': '💧',
          'streak': 9,
          'logs': [todayIso],
        },
        {
          'id': 4,
          'title': 'قراءة 20 صفحة من كتاب مفيد',
          'icon': '📚',
          'streak': 3,
          'logs': [yesterdayIso],
        },
      ],
      'tasks': [
        {
          'id': 1,
          'title': 'مراجعة أولويات الأسبوع وتحديد المهام الهامة',
          'done': true,
          'date': todayIso,
          'time': '09:00',
        },
        {
          'id': 2,
          'title': 'جلسة تركيز لإنجاز المشروع الرئيسي (Deep Work)',
          'done': false,
          'date': todayIso,
          'time': '11:30',
        },
        {
          'id': 3,
          'title': 'تسجيل المصاريف ومتابعة الميزانية الشهرية',
          'done': false,
          'date': todayIso,
          'time': '16:00',
        },
        {
          'id': 4,
          'title': 'المشي المسائي والاسترخاء الذهني',
          'done': false,
          'date': todayIso,
          'time': '19:00',
        },
      ],
      'finances': [
        {
          'id': 1,
          'amount': 45.0,
          'category': 'طعام ومشروبات',
          'type': 'expense',
          'note': 'فطور صحي وقهوة',
          'date': todayIso,
        },
        {
          'id': 2,
          'amount': 150.0,
          'category': 'تسوق',
          'type': 'expense',
          'note': 'مشتريات منزلية أسبوعية',
          'date': yesterdayIso,
        },
        {
          'id': 3,
          'amount': 3200.0,
          'category': 'عمل حر',
          'type': 'income',
          'note': 'دفعة مشروع مستقل',
          'date': yesterdayIso,
        },
      ],
      'health': [
        {
          'id': 1,
          'category': 'المزاج',
          'content': 'نشاط وحماس عاليين وبداية موفقة ليوم منتج ✨',
          'date': todayIso,
        },
        {
          'id': 2,
          'category': 'رياضة',
          'content': 'مشي 4000 خطوة صباحية في الهواء الطلق 🏃‍♂️',
          'date': todayIso,
        },
        {
          'id': 3,
          'category': 'نوم',
          'content': 'نوم هادئ لمدة 7.5 ساعات 🌙',
          'date': yesterdayIso,
        },
      ],
      'goals': [
        {
          'id': 1,
          'title': 'إنهاء قراءة 12 كتاباً هذا العام',
          'progress': 65,
          'target_date': '${now.year}-12-31',
        },
        {
          'id': 2,
          'title': 'الوصول للوزن المثالي والحفاظ على اللياقة',
          'progress': 80,
          'target_date': '${now.year}-11-15',
        },
        {
          'id': 3,
          'title': 'بناء صندوق الطوارئ والادخار المالي',
          'progress': 50,
          'target_date': '${now.year}-10-30',
        },
      ],
      'entries': [
        {
          'id': 1,
          'content': 'بداية مرحلة جديدة مليئة بالتركيز والوضوح. كل خطوة صغيرة ومستمرة تصنع فارقاً حقيقياً في المستقبل.',
          'type': 'journal',
          'created_at': '${todayIso}T08:30:00.000Z',
        },
        {
          'id': 2,
          'content': 'فكرة مشروع: أتمتة تدفقات العمل وتخصيص ساعات الصباح الأولى للإنجاز الإبداعي الخالي من المشتتات.',
          'type': 'idea',
          'created_at': '${yesterdayIso}T15:20:00.000Z',
        },
      ],
      'chat': [
        {
          'id': 'msg_0',
          'text': 'أهلاً بك في دوّنلي! أنا مساعدك الشخصي الذكي، جاهز دائماً لمساعدتك في تنظيم يومك، تتبع عاداتك، وتقديم أفضل النصائح 🌟',
          'is_user': false,
          'created_at': '${todayIso}T08:00:00.000Z',
        }
      ],
      'checkin': {
        'last_date': todayIso,
        'streak': 12,
        'mood': 'ممتاز',
      }
    };
  }
}
