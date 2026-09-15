import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/stat_card.dart';
import '../chat_screen.dart';

class OverviewTab extends StatelessWidget {
  final Function(int) onTabChange;

  const OverviewTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<DataProvider>();

    final user = auth.user;
    final streak = user?.streak ?? 0;

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.brand,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Greeting & Streak Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهلاً، ${user?.name ?? "يا صديقي"} 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'احكِ لي يومك، وأنا أرتّب الباقي.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              // Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '$streak ${streak == 1 ? "يوم" : "أيام"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Daily Check-in Card (بطاقة الفحص اليومي)
          Card(
            color: AppColors.brandLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.brand.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'الفحص اليومي (Check-in)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'إيه الأخبار النهاردة؟ صرفت حاجة؟ التزمت بعاداتك؟ حاسس بإيه؟ اضغط على زرار المايك واحكيلي.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimaryLight, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('افتح المحادثة مع دوّنلي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Summary Grid
          const Text(
            'نظرة سريعة على يومك',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'المصاريف',
                  value: '${data.totalExpenses.toStringAsFixed(0)} 🪙',
                  subtitle: 'إجمالي الشهر الحالي',
                  icon: const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 18),
                  iconBgColor: AppColors.accentLight,
                  onTap: () => onTabChange(4), // Finances tab
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'المهام المتبقية',
                  value: '${data.pendingTasksCount}',
                  subtitle: 'مهام تحتاج لإنجاز',
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.brand, size: 18),
                  iconBgColor: AppColors.brandLight,
                  onTap: () => onTabChange(5), // Tasks tab
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'العادات النشطة',
                  value: '${data.habits.length}',
                  subtitle: 'عادات تتابعها يومياً',
                  icon: const Icon(Icons.repeat, color: Colors.purple, size: 18),
                  iconBgColor: Colors.purple.withOpacity(0.12),
                  onTap: () => onTabChange(2), // Habits tab
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'الأهداف',
                  value: '${data.goals.length}',
                  subtitle: 'أهداف تسعى لتحقيقها',
                  icon: const Icon(Icons.track_changes, color: Colors.blue, size: 18),
                  iconBgColor: Colors.blue.withOpacity(0.12),
                  onTap: () => onTabChange(3), // Goals tab
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر ما دوّنته',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => onTabChange(6), // Dafter tab
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (data.entries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    const Icon(Icons.menu_book, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'دفترك لسه فاضي',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اضغط على زرار المايك وسجّل أول خاطرة أو مصروف.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...data.entries.take(3).map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.brandLight,
                        child: const Icon(Icons.edit_note, color: AppColors.brand),
                      ),
                      title: Text(
                        entry.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        entry.createdAt.length >= 10 ? entry.createdAt.substring(0, 10) : '',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
