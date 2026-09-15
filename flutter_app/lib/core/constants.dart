import 'package:flutter/material.dart';

class AppColors {
  // ---- الورق والأسطح ----
  static const Color paper = Color(0xFFF6F1E4);
  static const Color paperDeep = Color(0xFFEFE8D6);
  static const Color surfaceCard = Color(0xFFFFFCF5);
  static const Color surfaceRaised = Color(0xFFFFFFFF);

  // ---- الحبر ----
  static const Color ink = Color(0xFF34302A);
  static const Color inkMuted = Color(0xFF6E665A);
  static const Color inkFaint = Color(0xFF9A9082);
  static const Color hairline = Color(0xFFDFD7C4);
  static const Color hairlineStrong = Color(0xFFC9BFA8);

  // ---- البراند: أخضر هادي ----
  static const Color brand = Color(0xFF5C8A6B);
  static const Color brandDeep = Color(0xFF426B52);
  static const Color brandTint = Color(0xFFBCD4C2);
  static const Color brandWash = Color(0xFFE4EEE6);

  // ---- العوالم الأربعة ----
  // الصحة (مرجاني)
  static const Color health = Color(0xFFE0705C);
  static const Color healthDeep = Color(0xFFC4543F);
  static const Color healthTint = Color(0xFFF6D5CD);
  static const Color healthWash = Color(0xFFFBEAE5);

  // العادات (كهرماني)
  static const Color habits = Color(0xFFE3A24A);
  static const Color habitsDeep = Color(0xFFC07F25);
  static const Color habitsTint = Color(0xFFF6E1BE);
  static const Color habitsWash = Color(0xFFFBF0D9);

  // الأهداف (أزرق)
  static const Color goals = Color(0xFF5285A6);
  static const Color goalsDeep = Color(0xFF3A647F);
  static const Color goalsTint = Color(0xFFC3DAE7);
  static const Color goalsWash = Color(0xFFE3EEF4);

  // الفلوس (أخضر ورقي)
  static const Color finances = Color(0xFF6FA84A);
  static const Color financesDeep = Color(0xFF527F35);
  static const Color financesTint = Color(0xFFCFE3BD);
  static const Color financesWash = Color(0xFFEAF2E1);
  static const Color coin = Color(0xFFC9962E);

  // الحالات
  static const Color success = Color(0xFF6FA84A);
  static const Color warning = Color(0xFFE3A24A);
  static const Color danger = Color(0xFFE0705C);
  static const Color dangerDeep = Color(0xFFC4543F);

  // الأفكار والمشاكل
  static const Color ideas = Color(0xFF7C6BC9);
  static const Color ideasDeep = Color(0xFF5B4CA0);
  static const Color ideasTint = Color(0xFFD9D2F0);
  static const Color ideasWash = Color(0xFFECE8F8);

  static const Color problems = Color(0xFFD06A8C);
  static const Color problemsDeep = Color(0xFFA84668);
  static const Color problemsTint = Color(0xFFF2CEDB);
  static const Color problemsWash = Color(0xFFFBE9F0);

  static const Color onAccent = Color(0xFFFFFCF5);

  // Aliases for compatibility with existing tab widgets
  static const Color bgLight = paper;
  static const Color cardLight = surfaceCard;
  static const Color cardAltLight = paperDeep;
  static const Color borderLight = hairline;
  static const Color textPrimaryLight = ink;
  static const Color textSecondaryLight = inkMuted;
  static const Color accent = habits;
  static const Color brandLight = brandWash;
  static const Color brandDark = brandDeep;
  static const Color accentLight = habitsWash;
  static const Color bgDark = Color(0xFF1E1C18);
  static const Color cardDark = Color(0xFF262420);
  static const Color borderDark = Color(0xFF38342D);
  static const Color textPrimaryDark = Color(0xFFF0EBE0);
  static const Color textSecondaryDark = Color(0xFFA69E8D);
}

class AppRadii {
  static const double sm = 14.0;
  static const double md = 20.0;
  static const double lg = 28.0;
  static const double pill = 999.0;
}

class AppShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color(0x0F34302A),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow md = BoxShadow(
    color: Color(0x1434302A),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color(0x1F34302A),
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  static const BoxShadow voiceFab = BoxShadow(
    color: Color(0x735C8A6B),
    blurRadius: 26,
    offset: Offset(0, 10),
  );

  static const BoxShadow toolsFab = BoxShadow(
    color: Color(0x66282420),
    blurRadius: 26,
    offset: Offset(0, 10),
  );
}

class AppConstants {
  static const String appName = 'دوّنلي';
  static const String appTagline = 'احكِ لي يومك وأنا أرتّبه';
  static const String defaultServerUrl = 'http://10.0.2.2:3000';
  static const String defaultLocalUrl = 'http://localhost:3000';

  // Category Icons for Finances
  static const Map<String, String> catIcons = {
    'أكل': '🍔',
    'مواصلات': '🚌',
    'فواتير': '🧾',
    'صحة': '💊',
    'تسوق': '🛍️',
    'ترفيه': '🎮',
    'بيت': '🏠',
    'شغل': '💼',
    'تعليم': '📚',
    'أخرى': '📦',
  };

  // Health Category Icons
  static const Map<String, String> healthIcons = {
    'تمرين': '🏃',
    'دواء': '💊',
    'أكل': '🍽️',
    'عرض': '🤒',
    'نوم': '😴',
    'نفسية': '🧠',
    'ملاحظة': '📝',
  };

  // Days of week (Arabic letter)
  static const List<String> dayLetters = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
}
