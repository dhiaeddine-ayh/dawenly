import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_chip.dart';
import '../../core/design_system/section_header.dart';
import '../../core/design_system/composer_card.dart';
import '../../core/design_system/world_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/voice_modal.dart';

class OverviewTab extends StatelessWidget {
  final Function(int) onTabChange;

  const OverviewTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<DataProvider>();

    final user = auth.user;
    final streak = (user?.streak != null && user!.streak > 0) ? '${user.streak}' : '—';
    final today = user?.today ?? '—';

    // بيانات العوالم الأربعة
    final habitsDone = data.habits.where((h) => h.logs.isNotEmpty).length;
    final topGoal = data.goals.isNotEmpty ? data.goals.first : null;

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.brand,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة: الترحيب والبادجات (page-head)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'صباح الخير 👋',
                style: GoogleFonts.lemonada(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'هذه حياتك مرتّبة — حتى الآن.',
                style: GoogleFonts.tajawal(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.inkMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // صف البادجات البيضاوية (date, streak, cost)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SketchChip.date(
                    date: today,
                  ),
                  SketchChip.streak(
                    streak: streak,
                  ),
                  SketchChip.cost(
                    cost: '—',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. كارت الكومبوزر السكتش المرسوم باليد (احكِ لي ماذا فعلت اليوم...)
          ComposerCard(
            onSubmit: (text) async {
              await data.addEntry(text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تدوين يومك بنجاح ✍️'),
                    backgroundColor: AppColors.brand,
                  ),
                );
              }
            },
            onRecordVoice: () => VoiceModal.show(context),
          ),

          // 3. قسم "العوالم الأربعة"
          const SectionHeader(
            title: 'العوالم الأربعة',
            subtitle: 'اضغط أي عالم تشوف تفاصيله',
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              WorldCard(
                kind: WorldKind.health,
                title: 'الصحة',
                metric: data.healthItems.isNotEmpty
                    ? '${data.healthItems.length} تدوينات'
                    : 'لا تزال هادئة',
                caption: data.healthItems.isNotEmpty
                    ? data.healthItems.first.title
                    : 'احكِ لي عن نومك وجسمك',
                onTap: () => onTabChange(1),
              ),
              WorldCard(
                kind: WorldKind.habits,
                title: 'العادات',
                metric: data.habits.isNotEmpty
                    ? 'ستريك ${data.habits.first.streak} يوم 🔥'
                    : 'ابدأ عادة',
                caption: data.habits.isNotEmpty
                    ? '${data.habits.first.title} · $habitsDone/${data.habits.length} اليوم'
                    : 'قل لدوّنلي «ألعب رياضة كل يوم»',
                onTap: () => onTabChange(2),
              ),
              WorldCard(
                kind: WorldKind.goals,
                title: 'الأهداف',
                metric: topGoal != null
                    ? '${topGoal.progress}٪ من هدفك'
                    : 'حدّد هدف',
                caption: topGoal != null
                    ? topGoal.title
                    : 'قل لدوّنلي «أريد الوصول…»',
                onTap: () => onTabChange(3),
              ),
              WorldCard(
                kind: WorldKind.finances,
                title: 'الفلوس',
                metric: data.finances.isNotEmpty
                    ? 'صرفت ${data.totalExpenses.toStringAsFixed(0)} ج.م'
                    : 'سجّل أول عملية',
                caption: data.finances.isNotEmpty
                    ? 'اضغط لرؤية تفاصيل مصاريفك هذا الشهر'
                    : 'قل لدوّنلي «صرفت ٢٠٠ على الطعام»',
                onTap: () => onTabChange(4),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4. قسم "مهام النهاردة"
          SectionHeader(
            title: '📋 مهام النهاردة',
            actionText: 'كل المهام ←',
            onAction: () => onTabChange(5),
          ),
          SketchCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 24),
            child: data.tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'مفيش مهام النهاردة — يوم خفيف 🌤️',
                        style: GoogleFonts.tajawal(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: data.tasks.take(4).map((task) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.done,
                              activeColor: AppColors.brand,
                              onChanged: (_) => data.toggleTask(task),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.title,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  decoration: task.done ? TextDecoration.lineThrough : null,
                                  color: task.done ? AppColors.inkFaint : AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // 5. قسم "آخر ما دوّنته"
          const SectionHeader(
            title: 'آخر ما دوّنته',
          ),
          if (data.entries.isEmpty)
            SketchCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'دفترك لسه فاضي — سجّل أول خاطرة من الكومبوزر فوق ✍️',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.inkFaint,
                  ),
                ),
              ),
            )
          else
            ...data.entries.take(4).map(
                  (entry) => SketchCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.ink,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.createdAt.length >= 10 ? entry.createdAt.substring(0, 10) : '',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: AppColors.inkFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
