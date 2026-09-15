import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    // السبت هو أول الأسبوع (Egypt/Arab standard)
    final diff = (now.weekday + 1) % 7;
    final saturday = now.subtract(Duration(days: diff));
    return List.generate(7, (i) => saturday.add(Duration(days: i)));
  }

  void _showAddHabitModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    String selectedIcon = '🏃';
    final icons = ['🏃', '📚', '💧', '🧘', '💊', '🥗', '😴', '✨', '🎯'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة عادة جديدة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم العادة',
                  hintText: 'مثال: قراءة ٢٠ دقيقة',
                  prefixIcon: Icon(Icons.star_border),
                ),
              ),
              const SizedBox(height: 16),
              const Text('اختر أيقونة:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: icons.map((ico) {
                  final isSelected = selectedIcon == ico;
                  return InkWell(
                    onTap: () => setModalState(() => selectedIcon = ico),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brandLight : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.brand : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(ico, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final success = await context.read<DataProvider>().addHabit(
                        title,
                        icon: selectedIcon,
                      );
                  if (ctx.mounted && success) Navigator.pop(ctx);
                },
                child: const Text('حفظ العادة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final habits = data.habits;
    final weekDays = _getCurrentWeekDays();
    final todayIso = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_habit_fab',
        onPressed: () => _showAddHabitModal(context),
        backgroundColor: AppColors.brand,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => data.loadAll(),
        color: AppColors.brand,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عاداتك الأسبوعية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${habits.length} عادات',
                  style: const TextStyle(fontSize: 13, color: AppColors.brand, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (habits.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('لسه معندكش عادات مسجلة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'ابدأ أضف عادة جديدة تتابع التزامك فيها كل يوم.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...habits.map((habit) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(habit.icon ?? '✨', style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                habit.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '🔥 ${habit.streak}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Week Days Row: س ح ن ث ر خ ج
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (i) {
                            final d = weekDays[i];
                            final iso = d.toIso8601String().substring(0, 10);
                            final isDone = habit.isDoneOn(iso);
                            final isToday = iso == todayIso;

                            return InkWell(
                              onTap: () => data.toggleHabit(habit.id, iso),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 38,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppColors.brand
                                      : (isToday ? AppColors.brandLight : Colors.transparent),
                                  border: Border.all(
                                    color: isDone
                                        ? AppColors.brand
                                        : (isToday ? AppColors.brand : Colors.grey.withOpacity(0.3)),
                                    width: isToday ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      AppConstants.dayLetters[d.weekday % 7],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDone ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Icon(
                                      isDone ? Icons.check : Icons.circle_outlined,
                                      size: 14,
                                      color: isDone ? Colors.white : Colors.grey.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
