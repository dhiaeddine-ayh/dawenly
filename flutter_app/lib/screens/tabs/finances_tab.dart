import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';

class FinancesTab extends StatelessWidget {
  const FinancesTab({super.key});

  void _showAddFinanceModal(BuildContext context) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedCat = 'أكل';
    String selectedType = 'expense';

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
                'إضافة عملية مالية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Type Selector: Expense or Income
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('مصروف 💸')),
                      selected: selectedType == 'expense',
                      selectedColor: AppColors.danger.withOpacity(0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'expense'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('دخل 💰')),
                      selected: selectedType == 'income',
                      selectedColor: AppColors.success.withOpacity(0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'income'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.catIcons.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.value} ${e.key}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedCat = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  hintText: 'مثال: غدا مع الأصحاب',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (amt <= 0) return;
                  final success = await context.read<DataProvider>().addFinance(
                        amt,
                        selectedCat,
                        note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                        type: selectedType,
                      );
                  if (ctx.mounted && success) Navigator.pop(ctx);
                },
                child: const Text('حفظ العملية'),
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
    final finances = data.finances;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_finance_fab',
        onPressed: () => _showAddFinanceModal(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => data.loadAll(),
        color: AppColors.brand,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Financial Summary Card
            Card(
              color: AppColors.cardLight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'صافي الرصيد والمصاريف',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(data.totalIncome - data.totalExpenses).toStringAsFixed(0)} 🪙',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('المصروفات', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                            const SizedBox(height: 4),
                            Text(
                              '-${data.totalExpenses.toStringAsFixed(0)} 🪙',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.3)),
                        Column(
                          children: [
                            const Text('الدخل', style: TextStyle(fontSize: 12, color: AppColors.success)),
                            const SizedBox(height: 4),
                            Text(
                              '+${data.totalIncome.toStringAsFixed(0)} 🪙',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            const Text(
              'سجل العمليات المالية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (finances.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('مفيش مصاريف مسجلة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'اضغط على زرار + أو تكلّم بالمايك وهيتم تسجيلها تلقائياً.',
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
              ...finances.map((item) {
                final isExpense = item.type == 'expense';
                final icon = AppConstants.catIcons[item.category] ?? '📦';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpense
                          ? AppColors.danger.withOpacity(0.12)
                          : AppColors.success.withOpacity(0.12),
                      child: Text(icon, style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(
                      item.category,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      item.note != null && item.note!.isNotEmpty
                          ? '${item.note} • ${item.date}'
                          : item.date,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '${isExpense ? '-' : '+'}${item.amount.toStringAsFixed(0)} 🪙',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isExpense ? AppColors.danger : AppColors.success,
                      ),
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
