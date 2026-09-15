import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../models/entry_item.dart';
import '../../providers/data_provider.dart';
import '../../widgets/voice_modal.dart';

class DafterTab extends StatefulWidget {
  const DafterTab({super.key});

  @override
  State<DafterTab> createState() => _DafterTabState();
}

class _DafterTabState extends State<DafterTab> {
  String _selectedSub = 'journal'; // 'journal', 'thoughts', 'ideas', 'problems'
  final TextEditingController _composerCtrl = TextEditingController();
  final TextEditingController _ideaCtrl = TextEditingController();
  final TextEditingController _problemCtrl = TextEditingController();

  final List<Map<String, String>> _subTabs = [
    {'key': 'journal', 'label': '📓 اليوميات'},
    {'key': 'thoughts', 'label': '💭 خواطر'},
    {'key': 'ideas', 'label': '💡 أفكار وخطط'},
    {'key': 'problems', 'label': '🧩 مشاكل'},
  ];

  @override
  void dispose() {
    _composerCtrl.dispose();
    _ideaCtrl.dispose();
    _problemCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitJournalEntry() async {
    final text = _composerCtrl.text.trim();
    if (text.isEmpty) return;
    await context.read<DataProvider>().addEntry(text, type: _selectedSub);
    _composerCtrl.clear();
  }

  Future<void> _submitIdea() async {
    final text = _ideaCtrl.text.trim();
    if (text.isEmpty) return;
    await context.read<DataProvider>().addEntry(text, type: 'ideas');
    _ideaCtrl.clear();
  }

  Future<void> _submitProblem() async {
    final text = _problemCtrl.text.trim();
    if (text.isEmpty) return;
    await context.read<DataProvider>().addEntry(text, type: 'problems');
    _problemCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final allEntries = data.entries;

    // Filter entries by current selected sub tab
    final currentEntries = allEntries.where((e) {
      final type = e.type ?? 'journal';
      if (_selectedSub == 'journal') return type == 'journal' || type == 'daily';
      if (_selectedSub == 'thoughts') return type == 'thoughts' || type == 'thought';
      if (_selectedSub == 'ideas') return type == 'ideas' || type == 'idea';
      if (_selectedSub == 'problems') return type == 'problems' || type == 'problem';
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.brand,
      backgroundColor: AppColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 120),
        children: [
          // 1. رأس الصفحة (Page Head)
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
                      color: AppColors.brandWash,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Text(
                      'مساحتك الخاصة · دفترك 📓',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'دفترك',
                    style: GoogleFonts.lemonada(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'سجل أفكارك، يومياتك، وتحدياتك في مكان واحد ✨',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Text(
                  '${allEntries.length} تدوينة ✍️',
                  style: GoogleFonts.tajawal(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. شريط التبويبات المقسمة (.seg-bar) بخط اليد
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.ink, width: 1.8),
            ),
            child: Row(
              children: _subTabs.map((sub) {
                final isSelected = _selectedSub == sub['key'];
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSub = sub['key']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brand : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: isSelected
                            ? Border.all(color: AppColors.ink, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        sub['label']!,
                        style: GoogleFonts.tajawal(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 3. المحتوى حسب التبويب المختار
          if (_selectedSub == 'journal')
            _buildJournalSubTab(currentEntries, data)
          else if (_selectedSub == 'thoughts')
            _buildThoughtsSubTab(currentEntries, data)
          else if (_selectedSub == 'ideas')
            _buildIdeasSubTab(currentEntries, data)
          else if (_selectedSub == 'problems')
            _buildProblemsSubTab(currentEntries, data),
        ],
      ),
    );
  }

  // ====================== 1. اليوميات ======================
  Widget _buildJournalSubTab(List<EntryItemModel> entries, DataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // كارت التدوين بالصوت أو الكتابة
        SketchCard(
          backgroundColor: AppColors.surfaceCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'احكِ لدوّنلي عن يومك…',
                    style: GoogleFonts.lemonada(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _composerCtrl,
                maxLines: 3,
                style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.ink, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'كيف سار يومك اليوم؟ ما الذي أسعدك أو أنجزته؟…',
                  hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.inkMuted),
                  fillColor: AppColors.paper,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.brand, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SketchButton.secondary(
                    text: '🎙️ سجّل صوت',
                    onPressed: () => VoiceModal.show(context),
                  ),
                  SketchButton.primary(
                    text: '💾 حفظ في اليوميات',
                    onPressed: _submitJournalEntry,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // قائمة التدوينات
        _buildEntriesList(entries, data, 'دفترك ينتظر أول تدوينة لليوم 📖'),
      ],
    );
  }

  // ====================== 2. خواطر ======================
  Widget _buildThoughtsSubTab(List<EntryItemModel> entries, DataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SketchCard(
          backgroundColor: AppColors.surfaceCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('💭', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'عصف ذهني وكلام حُرّ',
                    style: GoogleFonts.lemonada(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'افتح المايك واتكلّم لحد ٢٠ دقيقة أو اكتب — بنحفظه خام زي ما هو بدون ترتيب 💭',
                style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _composerCtrl,
                maxLines: 3,
                style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'اتكلّم بحرية… فكرة، خاطرة، موقف في بالك…',
                  hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.inkMuted),
                  fillColor: AppColors.paper,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SketchButton.secondary(
                    text: '🎙️ سجّل خاطرة',
                    onPressed: () => VoiceModal.show(context),
                  ),
                  SketchButton.primary(
                    text: '💾 حفظ الخاطرة',
                    onPressed: _submitJournalEntry,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildEntriesList(entries, data, 'مفيش خواطر مسجلة — فرّغ رأسك وسجل أول خاطرة 💭'),
      ],
    );
  }

  // ====================== 3. أفكار وخطط ======================
  Widget _buildIdeasSubTab(List<EntryItemModel> entries, DataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SketchCard(
          backgroundColor: AppColors.surfaceCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'فكرة جديدة 💡',
                style: GoogleFonts.lemonada(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ideaCtrl,
                      style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: 'فكرة، مشروع، أو حاجة ناوي تعملها…',
                        hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.inkMuted),
                        fillColor: AppColors.paper,
                        filled: true,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SketchButton.primary(
                    text: '＋ إضافة',
                    onPressed: _submitIdea,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'أو قل لدوّنلي «عندي فكرة…» وسيضعها هنا مباشرة، وتقدر تحوّلها لمهمة في أي وقت ✓',
                style: GoogleFonts.tajawal(fontSize: 11.5, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildEntriesList(entries, data, 'مفيش أفكار مسجلة بعد — دوّن أفكارك قبل أن تطير 💡'),
      ],
    );
  }

  // ====================== 4. مشاكل ======================
  Widget _buildProblemsSubTab(List<EntryItemModel> entries, DataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SketchCard(
          backgroundColor: AppColors.surfaceCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مشكلة أو همّ جديد 🧩',
                style: GoogleFonts.lemonada(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'احكِ لدوّنلي اللي مضايقك وهو يتابعه معاك حتى يتحل بالكامل.',
                style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _problemCtrl,
                      style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: 'إيه اللي شاغل بالك أو مضايقك؟…',
                        hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.inkMuted),
                        fillColor: AppColors.paper,
                        filled: true,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SketchButton.primary(
                    text: '＋ إضافة',
                    onPressed: _submitProblem,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildEntriesList(entries, data, 'لا توجد هموم مسجلة، أسعد الله أيامك بكل خير 🌿'),
      ],
    );
  }

  Widget _buildEntriesList(List<EntryItemModel> entries, DataProvider data, String emptyText) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text('📝', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              emptyText,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13.5,
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: entries.map((entry) {
        final dateSub = entry.createdAt.length >= 10 ? entry.createdAt.substring(0, 10) : '';
        return SketchCard(
          margin: const EdgeInsets.only(bottom: 12),
          backgroundColor: AppColors.surfaceCard,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.ink, width: 1),
                    ),
                    child: Text(
                      '🗓 $dateSub',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => data.deleteEntry(entry.id),
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.inkMuted),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.text,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
