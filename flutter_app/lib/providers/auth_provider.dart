import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user = UserModel(
    id: 1,
    name: 'مستخدم دوّنلي',
    email: 'local@dawenly.app',
    streak: 12,
  );
  final bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => true;
  String get baseUrl => '';

  Future<bool> checkAuth() async {
    _user ??= UserModel(
      id: 1,
      name: 'مستخدم دوّنلي',
      email: 'local@dawenly.app',
      streak: 12,
    );
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password, {bool remember = true}) async {
    _user = UserModel(
      id: 1,
      name: 'مستخدم دوّنلي',
      email: email.isNotEmpty ? email : 'local@dawenly.app',
      streak: 12,
    );
    notifyListeners();
    return true;
  }

  Future<void> setBaseUrl(String url) async {}

  Future<void> logout() async {
    // في الوضع المحلي، نحتفظ بالمستخدم الافتراضي
    _user = UserModel(
      id: 1,
      name: 'مستخدم دوّنلي',
      email: 'local@dawenly.app',
      streak: 12,
    );
    notifyListeners();
  }
}
