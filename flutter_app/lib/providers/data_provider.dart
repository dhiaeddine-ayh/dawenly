import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/task_item.dart';
import '../models/finance_item.dart';
import '../models/health_item.dart';
import '../models/goal_item.dart';
import '../models/entry_item.dart';
import '../models/asset_item.dart';
import '../services/local_storage_service.dart';

class DataProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = false;
  List<HabitModel> _habits = [];
  List<TaskModel> _tasks = [];
  List<FinanceItemModel> _finances = [];
  List<HealthItemModel> _healthItems = [];
  List<GoalItemModel> _goals = [];
  List<EntryItemModel> _entries = [];
  List<AssetItemModel> _assets = [];
  Map<String, dynamic> _overview = {};

  double _goldG24Price = 3720.0;
  double _usdRate = 48.60;

  bool get isLoading => _isLoading;
  List<HabitModel> get habits => _habits;
  List<TaskModel> get tasks => _tasks;
  List<FinanceItemModel> get finances => _finances;
  List<HealthItemModel> get healthItems => _healthItems;
  List<GoalItemModel> get goals => _goals;
  List<EntryItemModel> get entries => _entries;
  List<AssetItemModel> get assets => _assets;
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

    try {
      final data = await _storage.loadData();

      // Habits
      final habitsList = (data['habits'] ?? []) as List;
      _habits = habitsList.map((e) => HabitModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Tasks
      final tasksList = (data['tasks'] ?? []) as List;
      _tasks = tasksList.map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Finances
      final financesList = (data['finances'] ?? []) as List;
      _finances = financesList.map((e) => FinanceItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Health
      final healthList = (data['health'] ?? []) as List;
      _healthItems = healthList.map((e) => HealthItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Goals
      final goalsList = (data['goals'] ?? []) as List;
      _goals = goalsList.map((e) => GoalItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Entries
      final entriesList = (data['entries'] ?? []) as List;
      _entries = entriesList.map((e) => EntryItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Assets
      final assetsList = (data['assets'] ?? []) as List;
      _assets = assetsList.map((e) => AssetItemModel.fromJson(Map<String, dynamic>.from(e))).toList();

      // Overview
      _overview = Map<String, dynamic>.from(data['checkin'] ?? {});
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistAll() async {
    try {
      final data = {
        'habits': _habits.map((h) => {
          'id': h.id,
          'title': h.title,
          'icon': h.icon,
          'streak': h.streak,
          'logs': h.logs,
        }).toList(),
        'tasks': _tasks.map((t) => {
          'id': t.id,
          'title': t.title,
          'done': t.done,
          'date': t.date,
          'time': t.time,
        }).toList(),
        'finances': _finances.map((f) => {
          'id': f.id,
          'amount': f.amount,
          'category': f.category,
          'type': f.type,
          'note': f.note,
          'date': f.date,
        }).toList(),
        'health': _healthItems.map((h) => {
          'id': h.id,
          'category': h.category,
          'content': h.content,
          'date': h.date,
        }).toList(),
        'goals': _goals.map((g) => {
          'id': g.id,
          'title': g.title,
          'progress': g.progress,
          'target_date': g.targetDate,
        }).toList(),
        'entries': _entries.map((e) => {
          'id': e.id,
          'text': e.text,
          'type': e.type,
          'created_at': e.createdAt,
        }).toList(),
        'assets': _assets.map((a) => a.toJson()).toList(),
        'checkin': _overview,
      };

      await _storage.saveData(data);
    } catch (_) {}
  }

  // Habits Operations
  Future<void> toggleHabit(int habitId, String isoDate) async {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx != -1) {
      final habit = _habits[idx];
      final currentLogs = List<String>.from(habit.logs);
      if (currentLogs.contains(isoDate)) {
        currentLogs.remove(isoDate);
      } else {
        currentLogs.add(isoDate);
      }
      final newStreak = currentLogs.length;
      _habits[idx] = HabitModel(
        id: habit.id,
        title: habit.title,
        icon: habit.icon,
        streak: newStreak,
        logs: currentLogs,
      );
      notifyListeners();
      await _persistAll();
    }
  }

  Future<bool> addHabit(String title, {String? icon, String? frequency}) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _habits.insert(
      0,
      HabitModel(
        id: newId,
        title: title,
        icon: icon ?? '✨',
        streak: 0,
        logs: [],
      ),
    );
    notifyListeners();
    await _persistAll();
    return true;
  }

  // Tasks Operations
  Future<void> toggleTask(TaskModel task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task.copyWith(done: !task.done);
      notifyListeners();
      await _persistAll();
    }
  }

  Future<bool> addTask(String title, {String? date, String? time}) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _tasks.insert(
      0,
      TaskModel(
        id: newId,
        title: title,
        done: false,
        date: date ?? DateTime.now().toIso8601String().substring(0, 10),
        time: time,
      ),
    );
    notifyListeners();
    await _persistAll();
    return true;
  }

  // Finance Operations
  Future<bool> addFinance({
    required double amount,
    required String category,
    String? note,
    String type = 'expense',
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _finances.insert(
      0,
      FinanceItemModel(
        id: newId,
        amount: amount,
        category: category,
        type: type,
        note: note,
        date: DateTime.now().toIso8601String().substring(0, 10),
      ),
    );
    notifyListeners();
    await _persistAll();
    return true;
  }

  // Health Operations
  Future<bool> addHealth(String category, String content) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _healthItems.insert(
      0,
      HealthItemModel(
        id: newId,
        category: category,
        content: content,
        date: DateTime.now().toIso8601String().substring(0, 10),
      ),
    );
    notifyListeners();
    await _persistAll();
    return true;
  }

  // Goals Operations
  Future<bool> addGoal(String title, {String? targetDate, int progress = 0}) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _goals.insert(
      0,
      GoalItemModel(
        id: newId,
        title: title,
        targetDate: targetDate ?? DateTime.now().add(const Duration(days: 90)).toIso8601String().substring(0, 10),
        progress: progress,
      ),
    );
    notifyListeners();
    await _persistAll();
    return true;
  }

  // Entries (Dafter) Operations
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
    await _persistAll();
    return true;
  }

  Future<void> deleteTask(int taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    await _persistAll();
  }

  Future<void> deleteEntry(int entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
    await _persistAll();
  }

  // Assets Operations
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
    await _persistAll();
    return true;
  }

  Future<void> deleteAsset(int assetId) async {
    _assets.removeWhere((a) => a.id == assetId);
    notifyListeners();
    await _persistAll();
  }

  Future<void> refreshMarketRates() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulate slight live market movement
    _goldG24Price = 3720.0 + (DateTime.now().second % 15);
    _usdRate = 48.60 + ((DateTime.now().millisecond % 10) / 100.0);
    _isLoading = false;
    notifyListeners();
  }
}
