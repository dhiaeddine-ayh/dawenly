import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../core/design_system/section_header.dart';
import '../../widgets/daftar_body_map.dart';
import '../../providers/data_provider.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  String? _selectedMood;
  String? _selectedBodyRegion;

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
                'تسجيل صحي / دوائي 🩺',
                style: GoogleFonts.lemonada(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'نوع السجل',
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
              const SizedBox(height: 14),
              TextField(
                controller: contentCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'التفاصيل',
                  hintText: 'مثال: جري نصف ساعة / بندول للصداع',
                ),
              ),
              const SizedBox(height: 20),
              SketchButton.primary(
                text: 'حفظ السجل',
                onPressed: () async {
                  final text = contentCtrl.text.trim();
                  if (text.isEmpty) return;
                  final success = await context.read<DataProvider>().addHealth(selectedCat, text);
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
    final healthItems = data.healthItems;

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.health,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة: عالم الصحة (page-head)
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
                      color: AppColors.healthWash,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.healthTint),
                    ),
                    child: Text(
                      'عالم الصحة',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.healthDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'جسمك يحدّثك',
                    style: GoogleFonts.lemonada(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              SketchButton.secondary(
                text: 'إضافة سجل +',
                isSmall: true,
                onPressed: () => _showAddHealthModal(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. كارت المزاج (مزاجك آخر أسبوع)
          SketchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مزاجك اليوم 🧠',
                      style: GoogleFonts.lemonada(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.healthWash,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        'من يومياتك',
                        style: GoogleFonts.tajawal(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.healthDeep,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'سجّل حالتك النفسية لتتبع أثر يومك.',
                  style: GoogleFonts.tajawal(
                    fontSize: 12.5,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 14),
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
                              content: Text('تم تسجيل حالتك: ${m['label']} ${m['emoji']}'),
                              backgroundColor: AppColors.brand,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.healthWash : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.health : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(m['emoji']!, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 4),
                            Text(
                              m['label']!,
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.healthDeep : AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. خريطة الجسم الأصلية (صحتك على الجسم)
          SketchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صحتك على الجسم',
                      style: GoogleFonts.lemonada(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    if (_selectedBodyRegion != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.healthWash,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          'المحدد: $_selectedBodyRegion',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.healthDeep,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'المس أي جزء في الجسم لرؤية الأعراض المسجلة فيه.',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.inkFaint,
                  ),
                ),
                const SizedBox(height: 16),
                DaftarBodyMap(
                  selectedRegion: _selectedBodyRegion,
                  onRegionSelected: (region) {
                    setState(() => _selectedBodyRegion = region);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. سجل الصحة والأنشطة
          const SectionHeader(title: 'سجل الأنشطة والأعراض'),

          if (healthItems.isEmpty)
            SketchCard(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  const Text('🩺', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    'مفيش سجلات صحية بعد',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تقدر تسجّل تمارينك، أكلك، أدويتك، أو أعراضك بالتفصيل.',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.inkFaint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...healthItems.map((item) {
              final icon = AppConstants.healthIcons[item.category] ?? '💊';
              return SketchCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.healthWash,
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
                            item.content,
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
