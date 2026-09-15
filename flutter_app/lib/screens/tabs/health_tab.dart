import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  String? _selectedMood;

  final moods = [
    {'emoji': '😄', 'label': 'ممتاز'},
    {'emoji': '😊', 'label': 'رايق'},
    {'emoji': '😐', 'label': 'عادي'},
    {'emoji': '😫', 'label': 'مضغوط'},
    {'emoji': '🤒', 'label': 'تعبان'},
  ];

  void _showAddHealthModal(BuildContext context) {
    final contentCtrl = TextEditingController();
    String selectedCat = 'تمرين';

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
                'تسجيل صحي / دوائي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'نوع السجل',
                  prefixIcon: Icon(Icons.health_and_safety_outlined),
                ),
                items: AppConstants.healthIcons.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.value} ${e.key}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedCat = val);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'التفاصيل',
                  hintText: 'مثال: جري نصف ساعة / بندول للصداع',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final text = contentCtrl.text.trim();
                  if (text.isEmpty) return;
                  final success = await context.read<DataProvider>().addHealth(selectedCat, text);
                  if (ctx.mounted && success) Navigator.pop(ctx);
                },
                child: const Text('حفظ السجل'),
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
    final healthItems = data.healthItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_health_fab',
        onPressed: () => _showAddHealthModal(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => data.loadAll(),
        color: AppColors.brand,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Mood Tracker Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'كيف حالك اليوم؟ 🧠',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سجّل حالتك النفسية لتتبع أثر يومك.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: moods.map((m) {
                        final isSelected = _selectedMood == m['label'];
                        return InkWell(
                          onTap: () async {
                            setState(() => _selectedMood = m['label']);
                            await data.addHealth('نفسية', 'الحالة النفسية: ${m['label']} ${m['emoji']}');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم تسجيل مزاجك: ${m['label']} ${m['emoji']}'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandLight : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.brand : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(m['emoji']!, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(m['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Health Log List
            const Text(
              'سجل الصحة والنشاطات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (healthItems.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text('🩺', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('مفيش سجلات صحية بعد', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'تقدر تسجّل تمارينك، أكلك، أدويتك، أو أعراضك بالتفصيل.',
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
              ...healthItems.map((item) {
                final icon = AppConstants.healthIcons[item.category] ?? '💊';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withOpacity(0.12),
                      child: Text(icon, style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(
                      item.content,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${item.category} • ${item.date}',
                      style: const TextStyle(fontSize: 11),
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
