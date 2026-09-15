import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String get baseUrl => _api.baseUrl;

  Future<void> setBaseUrl(String url) async {
    await _api.setBaseUrl(url);
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.init();
      final res = await _api.get('/api/me').timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        _user = UserModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // إذا كان بدون نت أو أوفلاين وكان هناك توكن أو جلسة سابقة
    }

    if (_api.isAuthenticated) {
      _user = UserModel(
        id: 1,
        name: 'مستخدم دوّنلي',
        email: 'user@dawenly.app',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // المستخدم الافتراضي لو مفيش تسجيل دخول (التطبيق يفتح محليًا بكل سلاسة)
    _user = UserModel(
      id: 1,
      name: 'مستخدم دوّنلي',
      email: 'local@dawenly.app',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password, {bool remember = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.post(
        '/api/login',
        body: {'email': email, 'password': password, 'remember': remember},
      );

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200 && data['ok'] == true) {
        final token = data['token']?.toString();
        await _api.setToken(token);

        // جلب بيانات الحساب
        final meRes = await _api.get('/api/me');
        if (meRes.statusCode == 200) {
          final meData = jsonDecode(utf8.decode(meRes.bodyBytes));
          _user = UserModel.fromJson(meData);
        } else {
          _user = UserModel(
            id: data['userId'] is int ? data['userId'] : 1,
            email: email,
            name: email.split('@').first,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error']?.toString() ?? 'بيانات الدخول غير صحيحة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'تعذر الاتصال بالخادم، تأكد من الاتصال بالشبكة';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/api/logout');
    } catch (_) {}
    await _api.setToken(null);
    _user = UserModel(
      id: 1,
      name: 'مستخدم دوّنلي',
      email: 'local@dawenly.app',
    );
    notifyListeners();
  }
}
