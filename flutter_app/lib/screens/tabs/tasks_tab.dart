import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  int _filterIndex = 0; // 0: All, 1: Pending, 2: Done

  void _showAddTaskModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

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
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'إضافة مهمة جديدة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم المهمة',
                hintText: 'مثال: ميتنج مع العميل',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'الميعاد (اختياري)',
                hintText: 'مثال: الساعة ٥ مساءً',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                final success = await context.read<DataProvider>().addTask(
                      title,
                      date: DateTime.now().toIso8601String().substring(0, 10),
                      time: timeCtrl.text.trim().isNotEmpty ? timeCtrl.text.trim() : null,
                    );
                if (ctx.mounted && success) Navigator.pop(ctx);
              },
              child: const Text('حفظ المهمة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final allTasks = data.tasks;

    final filteredTasks = allTasks.where((t) {
      if (_filterIndex == 1) return !t.done;
      if (_filterIndex == 2) return t.done;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_task_fab',
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: AppColors.brand,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => data.loadAll(),
        color: AppColors.brand,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Filter Chips
            Row(
              children: [
                ChoiceChip(
                  label: Text('الكل (${allTasks.length})'),
                  selected: _filterIndex == 0,
                  onSelected: (_) => setState(() => _filterIndex = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('قيد الإنجاز (${allTasks.where((t) => !t.done).length})'),
                  selected: _filterIndex == 1,
                  onSelected: (_) => setState(() => _filterIndex = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('المكتملة (${allTasks.where((t) => t.done).length})'),
                  selected: _filterIndex == 2,
                  onSelected: (_) => setState(() => _filterIndex = 2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (filteredTasks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('مفيش مهام هنا', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'اضغط على زرار + لإضافة مهمة أو قول للمايك «عندي ميتنج بكرة».',
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
              ...filteredTasks.map((task) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.done,
                      activeColor: AppColors.brand,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (_) => data.toggleTask(task),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                        color: task.done
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.45)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: (task.time != null || task.date != null)
                        ? Text(
                            '${task.date ?? ''} ${task.time ?? ''}'.trim(),
                            style: const TextStyle(fontSize: 11),
                          )
                        : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
