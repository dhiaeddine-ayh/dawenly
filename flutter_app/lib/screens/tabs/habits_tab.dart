import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../core/design_system/section_header.dart';
import '../../providers/data_provider.dart';

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
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
          decoration: const BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'عادة جديدة 🔁',
                style: GoogleFonts.lemonada(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم العادة',
                  hintText: 'مثال: قراءة ٢٠ دقيقة / رياضة الصباح',
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'اختر أيقونة:',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: icons.map((ico) {
                  final isSelected = selectedIcon == ico;
                  return InkWell(
                    onTap: () => setModalState(() => selectedIcon = ico),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.habitsWash : AppColors.surfaceCard,
                        border: Border.all(
                          color: isSelected ? AppColors.habits : AppColors.hairline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(ico, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SketchButton.primary(
                text: 'إضافة العادة',
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  await context.read<DataProvider>().addHabit(title, icon: selectedIcon);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
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
    final totalStreak = habits.fold<int>(0, (sum, h) => sum + h.streak);

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.habits,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة: عالم العادات (page-head)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.habitsWash,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.habitsTint),
                    ),
                    child: Text(
                      'عالم العادات',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.habitsDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'كل يوم تُكمل،\nوالشعلة تكبر',
                    style: GoogleFonts.lemonada(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              SketchButton.secondary(
                text: 'عادة جديدة +',
                isSmall: true,
                onPressed: () => _showAddHabitModal(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. كارت الستريك الرئيسي (streakPanel)
          SketchCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.habitsWash,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🔥', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي أيام الالتزام',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalStreak يوم استمرارية',
                        style: GoogleFonts.lemonada(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.habitsDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. لستة العادات الأسبوعية
          const SectionHeader(title: 'عاداتك الأسبوعية'),

          if (habits.isEmpty)
            SketchCard(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(
                    'لسه معندكش عادات مسجلة',
                    style: GoogleFonts.lemonada(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ابدأ أضف عادة جديدة تتابع التزامك فيها كل يوم.',
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: AppColors.inkFaint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...habits.map((habit) {
              return SketchCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14.0),
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
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.habitsWash,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(color: AppColors.habitsTint),
                          ),
                          child: Text(
                            '🔥 ${habit.streak}',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.habitsDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

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
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 38,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppColors.habits
                                  : (isToday ? AppColors.habitsWash : Colors.transparent),
                              border: Border.all(
                                color: isDone
                                    ? AppColors.habitsDeep
                                    : (isToday ? AppColors.habits : AppColors.hairline),
                                width: isToday ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  AppConstants.dayLetters[d.weekday % 7],
                                  style: GoogleFonts.tajawal(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDone ? Colors.white : AppColors.inkMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  isDone ? Icons.check : Icons.circle_outlined,
                                  size: 14,
                                  color: isDone ? Colors.white : AppColors.inkFaint,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
