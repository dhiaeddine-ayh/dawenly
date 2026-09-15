import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';

class DafterTab extends StatefulWidget {
  const DafterTab({super.key});

  @override
  State<DafterTab> createState() => _DafterTabState();
}

class _DafterTabState extends State<DafterTab> {
  final String _selectedType = 'journal';

  final types = [
    {'type': 'journal', 'label': 'يوميات 📖'},
    {'type': 'thought', 'label': 'خواطر 💭'},
    {'type': 'idea', 'label': 'أفكار 💡'},
    {'type': 'problem', 'label': 'تحديات ⚡'},
  ];

  void _showAddEntryModal(BuildContext context) {
    final textCtrl = TextEditingController();
    String currentType = _selectedType;

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
                'تدوين جديد في دفترك',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: types.map((t) {
                  final isSelected = currentType == t['type'];
                  return ChoiceChip(
                    label: Text(t['label']!),
                    selected: isSelected,
                    onSelected: (_) => setModalState(() => currentType = t['type']!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'اكتب ما يدور في بالك…',
                  hintText: 'اليوم كان تجربة ممتازة لأن…',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final text = textCtrl.text.trim();
                  if (text.isEmpty) return;
                  final success = await context.read<DataProvider>().addEntry(text, type: currentType);
                  if (ctx.mounted && success) Navigator.pop(ctx);
                },
                child: const Text('حفظ في الدفتر'),
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
    final entries = data.entries;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_dafter_fab',
        onPressed: () => _showAddEntryModal(context),
        backgroundColor: AppColors.brandDark,
        child: const Icon(Icons.edit, color: Colors.white),
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
                  'دفترك الشخصي 📖',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${entries.length} تدوينة',
                  style: const TextStyle(fontSize: 13, color: AppColors.brand, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (entries.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('دفترك ينتظر أول فكرة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'اكتب أفكارك، يومياتك، أو مشاعرك بحرية تامة.',
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
              ...entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.text,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entry.type ?? 'يوميات',
                                style: const TextStyle(fontSize: 11, color: AppColors.brand, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              entry.createdAt.length >= 10 ? entry.createdAt.substring(0, 10) : '',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
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
