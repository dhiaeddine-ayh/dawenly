import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../core/design_system/section_header.dart';
import '../../providers/data_provider.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  void _showAddGoalModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              'هدف جديد 🎯',
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
                labelText: 'اسم الهدف',
                hintText: 'مثال: أوصل ٥٠٠ ألف / قراءة ٥ كتب',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                labelText: 'تاريخ الإنجاز المستهدف (اختياري)',
                hintText: 'مثال: نهاية العام',
              ),
            ),
            const SizedBox(height: 20),
            SketchButton.primary(
              text: 'إضافة الهدف',
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                await context.read<DataProvider>().addGoal(
                      title,
                      targetDate: dateCtrl.text.trim().isNotEmpty ? dateCtrl.text.trim() : null,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final goals = data.goals;

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.goals,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة: عالم الأهداف (page-head)
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
                      color: AppColors.goalsWash,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.goalsTint),
                    ),
                    child: Text(
                      'عالم الأهداف',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goalsDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اقتربت من القمة',
                    style: GoogleFonts.lemonada(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              SketchButton.secondary(
                text: 'هدف جديد +',
                isSmall: true,
                onPressed: () => _showAddGoalModal(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. كارت ملخص الأهداف
          SketchCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.goalsWash,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎯', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأهداف المفتوحة حالياً',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${goals.length} أهداف تسعى لتحقيقها',
                        style: GoogleFonts.lemonada(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goalsDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. لستة الأهداف
          const SectionHeader(title: 'أهدافك الكبرى'),

          if (goals.isEmpty)
            SketchCard(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(
                    'لسه معندكش أهداف مضافة',
                    style: GoogleFonts.lemonada(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'حدد هدفاً مالياً أو مهنياً أو شخصياً واقترب منه خطوة بخطوة.',
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
            ...goals.map((goal) {
              final progressPercent = (goal.progress.clamp(0, 100)) / 100.0;
              return SketchCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goalsWash,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            '${goal.progress}٪',
                            style: GoogleFonts.lemonada(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goalsDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // شريط التقدّم
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: AppColors.paperDeep,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goals),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (goal.targetDate != null && goal.targetDate!.isNotEmpty)
                      Text(
                        'المستهدف: ${goal.targetDate}',
                        style: GoogleFonts.tajawal(
                          fontSize: 11.5,
                          color: AppColors.inkFaint,
                        ),
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
