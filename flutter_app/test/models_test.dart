import 'package:flutter_test/flutter_test.dart';
import 'package:dawenly_app/models/task_item.dart';
import 'package:dawenly_app/models/habit.dart';
import 'package:dawenly_app/models/finance_item.dart';
import 'package:dawenly_app/models/goal_item.dart';
import 'package:dawenly_app/models/asset_item.dart';
import 'package:dawenly_app/models/health_item.dart';

void main() {
  group('Dawenli Models Parity Tests', () {
    test('TaskModel handles done / pending status correctly', () {
      final task = TaskModel.fromJson({
        'id': 101,
        'title': 'مراجعة الميزانية الشهرية',
        'status': 'done',
        'due_date': '2026-09-15',
        'note': 'مهم جداً',
      });

      expect(task.id, 101);
      expect(task.title, 'مراجعة الميزانية الشهرية');
      expect(task.isCompleted, true);
      expect(task.dueDate, '2026-09-15');
    });

    test('HabitModel handles logs and completion status', () {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final habit = HabitModel.fromJson({
        'id': 201,
        'title': 'القراءة اليومية',
        'emoji': '📖',
        'streak': 7,
        'total': 25,
        'logs': [todayStr, '2026-09-14'],
      });

      expect(habit.id, 201);
      expect(habit.emoji, '📖');
      expect(habit.streak, 7);
      expect(habit.isCompletedToday, true);
    });

    test('FinanceItemModel correctly identifies income and expense', () {
      final expense = FinanceItemModel.fromJson({
        'id': 301,
        'title': 'مشتريات بقالة',
        'amount': 450.0,
        'direction': 'expense',
        'category': 'طعام',
      });
      expect(expense.isExpense, true);
      expect(expense.amount, 450.0);

      final income = FinanceItemModel.fromJson({
        'id': 302,
        'title': 'راتب شهري',
        'amount': 15000.0,
        'direction': 'income',
        'category': 'راتب',
      });
      expect(income.isExpense, false);
      expect(income.amount, 15000.0);
    });

    test('GoalItemModel calculates progress percentage correctly', () {
      final goal = GoalItemModel.fromJson({
        'id': 401,
        'title': 'حفظ ٥ أجزاء من القرآن',
        'current': 3,
        'target': 5,
        'unit': 'أجزاء',
      });

      expect(goal.progress, 60);
      expect(goal.isCompleted, false);
    });

    test('AssetItemModel calculates gold and foreign cash value in EGP', () {
      final goldAsset = AssetItemModel.fromJson({
        'id': 501,
        'name': 'سبيكة ذهب',
        'type': 'gold',
        'quantity': 10.0,
        'karat': 24,
      });

      final valGold = goldAsset.calculateValueEgp(goldG24: 7000.0);
      expect(valGold, 70000.0);

      final usdAsset = AssetItemModel.fromJson({
        'id': 502,
        'name': 'دولارات نقدية',
        'type': 'cash',
        'quantity': 1000.0,
        'currency': 'USD',
      });

      final valUsd = usdAsset.calculateValueEgp(rates: {'USD': 50.0});
      expect(valUsd, 50000.0);
    });

    test('HealthItemModel parses body region and category', () {
      final health = HealthItemModel.fromJson({
        'id': 601,
        'category': 'صداع',
        'detail': 'صداع خفيف بعد العمل',
        'body_region': 'head',
        'entry_date': '2026-09-15',
      });

      expect(health.id, 601);
      expect(health.category, 'صداع');
      expect(health.bodyRegion, 'head');
    });
  });
}
