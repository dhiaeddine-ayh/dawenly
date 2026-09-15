import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../core/design_system/section_header.dart';
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
                'عملية جديدة 💰',
                style: GoogleFonts.lemonada(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              // النوع: صرف أو دخل
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedType = 'expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedType == 'expense' ? AppColors.healthWash : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedType == 'expense' ? AppColors.health : AppColors.hairline,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'صرف ➖',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            color: selectedType == 'expense' ? AppColors.healthDeep : AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedType = 'income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedType == 'income' ? AppColors.financesWash : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedType == 'income' ? AppColors.finances : AppColors.hairline,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'دخل ➕',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            color: selectedType == 'income' ? AppColors.financesDeep : AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'المبلغ (ج.م)',
                  hintText: 'مثال: ١٥٠',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
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
              const SizedBox(height: 14),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  hintText: 'مثال: غداء مع الأصدقاء',
                ),
              ),
              const SizedBox(height: 20),
              SketchButton.primary(
                text: 'حفظ العملية',
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (amount <= 0) return;
                  final success = await context.read<DataProvider>().addFinance(
                        type: selectedType,
                        amount: amount,
                        category: selectedCat,
                        note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                      );
                  if (ctx.mounted && success) Navigator.pop(ctx);
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
    final finances = data.finances;
    final totalExpenses = data.totalExpenses;
    final totalIncome = data.totalIncome;
    final balance = totalIncome - totalExpenses;

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.finances,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة: عالم الفلوس (page-head)
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
                      color: AppColors.financesWash,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.financesTint),
                    ),
                    child: Text(
                      'عالم الفلوس',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.financesDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'نبتتك تكبر 🌱',
                    style: GoogleFonts.lemonada(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              SketchButton.secondary(
                text: 'عملية جديدة +',
                isSmall: true,
                onPressed: () => _showAddFinanceModal(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. كارت ملخص المصاريف والدخل
          SketchCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'إجمالي الصرف 💸',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalExpenses.toStringAsFixed(0)} ج.م',
                        style: GoogleFonts.lemonada(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dangerDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: AppColors.hairline),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'إجمالي الدخل 💰',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalIncome.toStringAsFixed(0)} ج.م',
                        style: GoogleFonts.lemonada(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.financesDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: AppColors.hairline),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'الصافي',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${balance.toStringAsFixed(0)} ج.م',
                        style: GoogleFonts.lemonada(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: balance >= 0 ? AppColors.financesDeep : AppColors.dangerDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. لستة العمليات
          const SectionHeader(title: 'كل العمليات المسجلة'),

          if (finances.isEmpty)
            SketchCard(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  const Text('💳', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(
                    'مفيش عمليات مسجلة بعد',
                    style: GoogleFonts.lemonada(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سجّل مشترياتك ومصاريفك اليومية لترى تحليلاً دقيقاً.',
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
            ...finances.map((item) {
              final isExpense = item.type == 'expense';
              final icon = AppConstants.catIcons[item.category] ?? '📦';

              return SketchCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isExpense ? AppColors.healthWash : AppColors.financesWash,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.note?.isNotEmpty == true ? item.note! : item.category,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category} • ${item.date}',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isExpense ? "-" : "+"}${item.amount.toStringAsFixed(0)} ج.م',
                      style: GoogleFonts.lemonada(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: isExpense ? AppColors.dangerDeep : AppColors.financesDeep,
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
