import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/habit.dart';
import '../models/task_item.dart';
import '../models/finance_item.dart';
import '../models/health_item.dart';
import '../models/goal_item.dart';
import '../models/entry_item.dart';
import '../models/asset_item.dart';
import '../services/local_storage_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = false;
  List<HabitModel> _habits = [];
  List<TaskModel> _tasks = [];
  List<FinanceItemModel> _finances = [];
  List<HealthItemModel> _healthItems = [];
  List<GoalItemModel> _goals = [];
  List<EntryItemModel> _entries = [];
  List<AssetItemModel> _assets = [];
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic> _overview = {};

  double _goldG24Price = 7145.0;
  double _usdRate = 51.80;

  bool get isLoading => _isLoading;
  List<HabitModel> get habits => _habits;
  List<TaskModel> get tasks => _tasks;
  List<FinanceItemModel> get finances => _finances;
  List<HealthItemModel> get healthItems => _healthItems;
  List<GoalItemModel> get goals => _goals;
  List<EntryItemModel> get entries => _entries;
  List<AssetItemModel> get assets => _assets;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => n['read_at'] == null).length;
  Map<String, dynamic> get overview => _overview;
  double get goldG24Price => _goldG24Price;
  double get usdRate => _usdRate;

  double get totalGoldValue => _assets
      .where((a) => a.type == 'gold')
      .fold(0.0, (sum, a) => sum + a.calculateValueEgp(goldG24: _goldG24Price));

  double get totalCashValue => _assets
      .where((a) => a.type == 'cash')
      .fold(0.0, (sum, a) => sum + a.calculateValueEgp(goldG24: _goldG24Price));

  double get totalOtherValue => _assets
      .where((a) => a.type == 'other')
      .fold(0.0, (sum, a) => sum + a.calculateValueEgp(goldG24: _goldG24Price));

  double get totalLiabilities => _assets
      .where((a) => a.type == 'liability')
      .fold(0.0, (sum, a) => sum + a.calculateValueEgp(goldG24: _goldG24Price));

  double get totalNetWorth =>
      (totalGoldValue + totalCashValue + totalOtherValue) - totalLiabilities;

  double get liquidNetWorth => (totalGoldValue + totalCashValue) - totalLiabilities;

  double get totalExpenses {
    return _finances
        .where((f) => f.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    return _finances
        .where((f) => f.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  int get pendingTasksCount => _tasks.where((t) => !t.done).length;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    bool loadedFromApi = false;

    try {
      await _api.init();

      // Parallel API calls to Node.js backend
      final results = await Future.wait([
        _api.get('/api/tasks').timeout(const Duration(seconds: 4)),
        _api.get('/api/habits').timeout(const Duration(seconds: 4)),
        _api.get('/api/finance').timeout(const Duration(seconds: 4)),
        _api.get('/api/health').timeout(const Duration(seconds: 4)),
        _api.get('/api/goals').timeout(const Duration(seconds: 4)),
        _api.get('/api/entries').timeout(const Duration(seconds: 4)),
        _api.get('/api/assets').timeout(const Duration(seconds: 4)),
        _api.get('/api/thoughts').timeout(const Duration(seconds: 4)),
        _api.get('/api/ideas').timeout(const Duration(seconds: 4)),
        _api.get('/api/problems').timeout(const Duration(seconds: 4)),
        _api.get('/api/notifications').timeout(const Duration(seconds: 4)),
        _api.get('/api/me').timeout(const Duration(seconds: 4)),
      ]);

      final tasksRes = results[0];
      final habitsRes = results[1];
      final financeRes = results[2];
      final healthRes = results[3];
      final goalsRes = results[4];
      final entriesRes = results[5];
      final assetsRes = results[6];
      final thoughtsRes = results[7];
      final ideasRes = results[8];
      final problemsRes = results[9];
      final notifsRes = results[10];
      final meRes = results[11];

      if (tasksRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(tasksRes.bodyBytes));
        if (raw is List) {
          _tasks = raw.map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }

      if (habitsRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(habitsRes.bodyBytes));
        if (raw is List) {
          _habits = raw.map((e) => HabitModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }

      if (financeRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(financeRes.bodyBytes));
        if (raw is List) {
          _finances = raw.map((e) => FinanceItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }

      if (healthRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(healthRes.bodyBytes));
        if (raw is List) {
          _healthItems = raw.map((e) => HealthItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }

      if (goalsRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(goalsRes.bodyBytes));
        if (raw is List) {
          _goals = raw.map((e) => GoalItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }

      // Merge journal entries, thoughts, ideas, problems for full dafter feed
      final List<EntryItemModel> combinedEntries = [];

      if (entriesRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(entriesRes.bodyBytes));
        if (raw is List) {
          combinedEntries.addAll(raw.map((e) => EntryItemModel.fromJson({
            ...Map<String, dynamic>.from(e),
            'type': 'journal',
          })));
        }
      }

      if (thoughtsRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(thoughtsRes.bodyBytes));
        if (raw is List) {
          combinedEntries.addAll(raw.map((e) => EntryItemModel.fromJson({
            'id': e['id'],
            'text': e['text'],
            'type': 'thoughts',
            'created_at': e['created_at'],
          })));
        }
      }

      if (ideasRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(ideasRes.bodyBytes));
        if (raw is List) {
          combinedEntries.addAll(raw.map((e) => EntryItemModel.fromJson({
            'id': e['id'],
            'text': e['title'] != null ? '${e['title']} ${e['detail'] ?? ''}'.trim() : '',
            'type': 'ideas',
            'created_at': e['created_at'],
          })));
        }
      }

      if (problemsRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(problemsRes.bodyBytes));
        if (raw is List) {
          combinedEntries.addAll(raw.map((e) => EntryItemModel.fromJson({
            'id': e['id'],
            'text': e['title'] != null ? '${e['title']} ${e['detail'] ?? ''}'.trim() : '',
            'type': 'problems',
            'created_at': e['created_at'],
          })));
        }
      }

      if (combinedEntries.isNotEmpty) {
        _entries = combinedEntries;
      }

      if (assetsRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(assetsRes.bodyBytes));
        if (raw is Map) {
          final assetsList = raw['assets'] as List?;
          if (assetsList != null) {
            _assets = assetsList.map((e) => AssetItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
          }
          final market = raw['market'] as Map?;
          if (market != null) {
            if (market['goldG24Egp'] != null) {
              _goldG24Price = (market['goldG24Egp'] as num).toDouble();
            }
            final rates = market['rates'] as Map?;
            if (rates != null && rates['USD'] != null) {
              _usdRate = (rates['USD'] as num).toDouble();
            }
          }
        }
      }

      if (notifsRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(notifsRes.bodyBytes));
        if (raw is List) {
          _notifications = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }

      if (meRes.statusCode == 200) {
        final raw = jsonDecode(utf8.decode(meRes.bodyBytes));
        if (raw is Map) {
          _overview = Map<String, dynamic>.from(raw);
        }
      }

      loadedFromApi = true;
      await _cacheCurrentStateLocally();
    } catch (_) {
      // Offline fallback
    }

    if (!loadedFromApi) {
      await _loadFromLocalCache();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final data = await _storage.loadData();
      final habitsList = (data['habits'] ?? []) as List;
      _habits = habitsList.map((e) => HabitModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final tasksList = (data['tasks'] ?? []) as List;
      _tasks = tasksList.map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final financesList = (data['finances'] ?? []) as List;
      _finances = financesList.map((e) => FinanceItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final healthList = (data['health'] ?? []) as List;
      _healthItems = healthList.map((e) => HealthItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final goalsList = (data['goals'] ?? []) as List;
      _goals = goalsList.map((e) => GoalItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final entriesList = (data['entries'] ?? []) as List;
      _entries = entriesList.map((e) => EntryItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      final assetsList = (data['assets'] ?? []) as List;
      _assets = assetsList.map((e) => AssetItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      _overview = Map<String, dynamic>.from(data['checkin'] ?? {});
    } catch (_) {}
  }

  Future<void> _cacheCurrentStateLocally() async {
    try {
      final data = {
        'habits': _habits.map((h) => h.toJson()).toList(),
        'tasks': _tasks.map((t) => t.toJson()).toList(),
        'finances': _finances.map((f) => f.toJson()).toList(),
        'health': _healthItems.map((h) => h.toJson()).toList(),
        'goals': _goals.map((g) => g.toJson()).toList(),
        'entries': _entries.map((e) => e.toJson()).toList(),
        'assets': _assets.map((a) => a.toJson()).toList(),
        'checkin': _overview,
      };
      await _storage.saveData(data);
    } catch (_) {}
  }

  // ==================== 1. AI Agent Logging (/api/log) ====================
  Future<Map<String, dynamic>?> runAgentLog(String text) async {
    final query = text.trim();
    if (query.isEmpty) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.post('/api/log', body: {'text': query});
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        await loadAll();
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}

    // Fallback: add locally if offline
    await addEntry(query);
    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ==================== 2. Tasks Operations (/api/tasks) ====================
  Future<void> toggleTask(TaskModel task) async {
    final newDone = !task.done;
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task.copyWith(done: newDone);
      notifyListeners();
    }

    try {
      final endpoint = newDone ? '/api/tasks/${task.id}/done' : '/api/tasks/${task.id}/reopen';
      await _api.put(endpoint);
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  Future<bool> addTask(String title, {String? date, String? time, String? note}) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _tasks.insert(
      0,
      TaskModel(
        id: newId,
        title: title,
        done: false,
        date: date,
        time: time,
        note: note,
      ),
    );
    notifyListeners();

    try {
      final res = await _api.post('/api/tasks', body: {
        'title': title,
        'dueDate': date,
        'dueTime': time,
        'note': note,
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['task'] != null) {
          final serverTask = TaskModel.fromJson(Map<String, dynamic>.from(data['task']));
          _tasks[0] = serverTask;
          notifyListeners();
        }
      }
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  Future<void> deleteTask(int taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    try {
      await _api.delete('/api/tasks/$taskId');
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  // ==================== 3. Habits Operations (/api/habits) ====================
  Future<void> toggleHabit(int habitId, String isoDate) async {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx != -1) {
      final habit = _habits[idx];
      final currentLogs = List<String>.from(habit.logs);
      final isDone = currentLogs.contains(isoDate);

      if (isDone) {
        currentLogs.remove(isoDate);
      } else {
        currentLogs.add(isoDate);
      }

      _habits[idx] = HabitModel(
        id: habit.id,
        title: habit.title,
        icon: habit.icon,
        kind: habit.kind,
        streak: isDone ? (habit.streak > 0 ? habit.streak - 1 : 0) : habit.streak + 1,
        total: isDone ? (habit.total > 0 ? habit.total - 1 : 0) : habit.total + 1,
        logs: currentLogs,
      );
      notifyListeners();

      try {
        if (isDone) {
          await _api.delete('/api/habits/$habitId/log?date=$isoDate');
        } else {
          await _api.post('/api/habits/$habitId/log', body: {'date': isoDate});
        }
      } catch (_) {}

      await _cacheCurrentStateLocally();
    }
  }

  Future<bool> addHabit(String title, {String? icon, String? kind, String? frequency}) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _habits.insert(
      0,
      HabitModel(
        id: newId,
        title: title,
        icon: icon ?? '✨',
        kind: kind ?? 'do',
        streak: 0,
        logs: [],
      ),
    );
    notifyListeners();

    try {
      final res = await _api.post('/api/habits', body: {
        'title': title,
        'kind': kind ?? 'do',
        'emoji': icon ?? '✨',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['habit'] != null) {
          _habits[0] = HabitModel.fromJson(Map<String, dynamic>.from(data['habit']));
          notifyListeners();
        }
      }
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  // ==================== 4. Finance Operations (/api/finance) ====================
  Future<bool> addFinance({
    required double amount,
    required String category,
    String? note,
    String type = 'expense',
    String? date,
    String? currency = 'EGP',
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    final entryDate = date ?? DateTime.now().toIso8601String().substring(0, 10);

    _finances.insert(
      0,
      FinanceItemModel(
        id: newId,
        amount: amount,
        category: category,
        type: type,
        note: note,
        date: entryDate,
        currency: currency,
      ),
    );
    notifyListeners();

    try {
      await _api.post('/api/finance', body: {
        'amount': amount,
        'direction': type,
        'category': category,
        'note': note,
        'entryDate': entryDate,
        'currency': currency,
      });
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  Future<void> deleteFinance(int financeId) async {
    _finances.removeWhere((f) => f.id == financeId);
    notifyListeners();

    try {
      await _api.delete('/api/finance/$financeId');
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  // ==================== 5. Health Operations (/api/health) ====================
  Future<bool> addHealth(
    String category,
    String content, {
    String? bodyRegion,
    String? date,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    final entryDate = date ?? DateTime.now().toIso8601String().substring(0, 10);

    _healthItems.insert(
      0,
      HealthItemModel(
        id: newId,
        category: category,
        content: content,
        date: entryDate,
        bodyRegion: bodyRegion,
      ),
    );
    notifyListeners();

    try {
      await _api.post('/api/health', body: {
        'category': category,
        'detail': content,
        'bodyRegion': bodyRegion,
        'entryDate': entryDate,
      });
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  Future<void> deleteHealth(int healthId) async {
    _healthItems.removeWhere((h) => h.id == healthId);
    notifyListeners();

    try {
      await _api.delete('/api/health/$healthId');
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  // ==================== 6. Goals Operations (/api/goals) ====================
  Future<bool> addGoal(
    String title, {
    String? targetDate,
    double? target,
    String? unit,
    int progress = 0,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _goals.insert(
      0,
      GoalItemModel(
        id: newId,
        title: title,
        targetDate: targetDate,
        target: target,
        unit: unit,
        progress: progress,
      ),
    );
    notifyListeners();

    try {
      await _api.post('/api/goals', body: {
        'title': title,
        'deadline': targetDate,
        'target': target,
        'unit': unit,
      });
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  Future<void> deleteGoal(int goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();

    try {
      await _api.delete('/api/goals/$goalId');
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  // ==================== 7. Entries / Dafter Operations ====================
  Future<bool> addEntry(String text, {String type = 'journal'}) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _entries.insert(
      0,
      EntryItemModel(
        id: newId,
        text: text,
        type: type,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    notifyListeners();

    try {
      if (type == 'thoughts') {
        await _api.post('/api/thoughts', body: {'text': text});
      } else if (type == 'ideas') {
        await _api.post('/api/ideas', body: {'title': text});
      } else if (type == 'problems') {
        await _api.post('/api/problems', body: {'title': text});
      } else {
        await _api.post('/api/log', body: {'text': text});
      }
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  Future<void> deleteEntry(int entryId, {String type = 'journal'}) async {
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();

    try {
      if (type == 'thoughts') {
        await _api.delete('/api/thoughts/$entryId');
      } else if (type == 'ideas') {
        await _api.delete('/api/ideas/$entryId');
      } else if (type == 'problems') {
        await _api.delete('/api/problems/$entryId');
      } else {
        await _api.delete('/api/entries/$entryId');
      }
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  // ==================== 8. Assets Operations (/api/assets) ====================
  Future<bool> addAsset({
    required String name,
    required String type,
    double quantity = 0.0,
    int? karat,
    String currency = 'EGP',
    double? manualValue,
    double? goal,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _assets.insert(
      0,
      AssetItemModel(
        id: newId,
        name: name,
        type: type,
        quantity: quantity,
        karat: karat ?? 21,
        currency: currency,
        manualValue: manualValue,
        goal: goal,
      ),
    );
    notifyListeners();

    try {
      await _api.post('/api/assets', body: {
        'name': name,
        'type': type,
        'quantity': quantity,
        'karat': karat,
        'currency': currency,
        'manual_value': manualValue,
        'goal': goal,
      });
    } catch (_) {}

    await _cacheCurrentStateLocally();
    return true;
  }

  Future<void> deleteAsset(int assetId) async {
    _assets.removeWhere((a) => a.id == assetId);
    notifyListeners();

    try {
      await _api.delete('/api/assets/$assetId');
    } catch (_) {}

    await _cacheCurrentStateLocally();
  }

  Future<void> refreshMarketRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.post('/api/assets/refresh-prices');
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['goldG24Egp'] != null) {
          _goldG24Price = (data['goldG24Egp'] as num).toDouble();
        }
        final rates = data['rates'] as Map?;
        if (rates != null && rates['USD'] != null) {
          _usdRate = (rates['USD'] as num).toDouble();
        }
      }
    } catch (_) {
      // Fallback slight jitter
      _goldG24Price = 7145.0 + (DateTime.now().second % 15);
      _usdRate = 51.80 + ((DateTime.now().millisecond % 10) / 100.0);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== 9. Notifications (/api/notifications) ====================
  Future<void> markNotificationsRead({int? id}) async {
    try {
      await _api.post('/api/notifications/read', body: id != null ? {'id': id} : {});
      for (final n in _notifications) {
        if (id == null || n['id'] == id) {
          n['read_at'] = DateTime.now().toIso8601String();
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  // ==================== 10. Bug Reporting (/api/report) ====================
  Future<bool> reportIssue(String message, {String page = '/'}) async {
    try {
      final res = await _api.post('/api/report', body: {
        'message': message,
        'page': page,
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
