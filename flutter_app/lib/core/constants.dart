import 'package:flutter/material.dart';

class AppColors {
  // Brand Sage Greens
  static const Color brand = Color(0xFF5C8A6B);
  static const Color brandDark = Color(0xFF446950);
  static const Color brandLight = Color(0xFFE8F2EC);

  // Warm Paper Backgrounds
  static const Color bgLight = Color(0xFFF6F1E4);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAltLight = Color(0xFFFCFAF5);

  // Dark Mode Surfaces
  static const Color bgDark = Color(0xFF161917);
  static const Color cardDark = Color(0xFF212522);
  static const Color cardAltDark = Color(0xFF2B302C);

  // Accents & Borders
  static const Color accent = Color(0xFFD97706); // Amber
  static const Color accentLight = Color(0xFFFEF3C7);
  static const Color borderLight = Color(0xFFE5DECB);
  static const Color borderDark = Color(0xFF373D38);

  // Text
  static const Color textPrimaryLight = Color(0xFF1E2320);
  static const Color textSecondaryLight = Color(0xFF6B726D);
  static const Color textPrimaryDark = Color(0xFFF0F4F1);
  static const Color textSecondaryDark = Color(0xFF9CA39E);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class AppConstants {
  static const String appName = 'دوّنلي';
  static const String appTagline = 'احكِ لي يومك وأنا أرتّبه';
  static const String defaultServerUrl = 'http://10.0.2.2:3000'; // Standard Android Emulator URL
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
