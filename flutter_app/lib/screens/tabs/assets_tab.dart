import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../models/asset_item.dart';
import '../../providers/data_provider.dart';

class AssetsTab extends StatefulWidget {
  const AssetsTab({super.key});

  @override
  State<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends State<AssetsTab> {
  String _selectedType = 'gold'; // 'gold', 'cash', 'other', 'liability'
  int _selectedKarat = 21;
  String _selectedCurrency = 'EGP';

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _valCtrl = TextEditingController();

  final List<Map<String, String>> _types = [
    {'key': 'gold', 'label': '🪙 دهب'},
    {'key': 'cash', 'label': '💵 كاش / عملة'},
    {'key': 'other', 'label': '🏷️ أصل تاني'},
    {'key': 'liability', 'label': '📉 التزام (دين)'},
  ];

  final List<int> _karats = [24, 22, 21, 18, 14];

  final List<String> _currencies = ['EGP', 'USD', 'EUR', 'SAR', 'AED', 'GBP'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _valCtrl.dispose();
    super.dispose();
  }

  String _formatNum(num n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  String _formatCurrency(double n) {
    final s = n.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i > 0 && s[i - 1] != '-') {
        buffer.write(',');
      }
    }
    return '${buffer.toString().split('').reversed.join()} ج.م';
  }

  Future<void> _submitAsset() async {
    final name = _nameCtrl.text.trim();
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0.0;
    final val = double.tryParse(_valCtrl.text.trim());

    if (name.isEmpty && _selectedType == 'other') return;
    if (_selectedType != 'other' && qty <= 0) return;

    final defaultName = _selectedType == 'gold'
        ? 'قطع دهب عيار $_selectedKarat'
        : _selectedType == 'cash'
            ? 'كاش بـ $_selectedCurrency'
            : _selectedType == 'liability'
                ? 'التزام مالي'
                : 'أصل استثماري';

    await context.read<DataProvider>().addAsset(
          name: name.isNotEmpty ? name : defaultName,
          type: _selectedType,
          quantity: qty,
          karat: _selectedType == 'gold' ? _selectedKarat : null,
          currency: (_selectedType == 'cash' || _selectedType == 'liability')
              ? _selectedCurrency
              : 'EGP',
          manualValue: _selectedType == 'other' ? val : null,
        );

    _nameCtrl.clear();
    _qtyCtrl.clear();
    _valCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final assets = data.assets;
    final total = data.totalNetWorth;
    final liquid = data.liquidNetWorth;
    final goldSum = data.totalGoldValue;
    final cashSum = data.totalCashValue;
    final otherSum = data.totalOtherValue;
    final liabilities = data.totalLiabilities;

    return RefreshIndicator(
      onRefresh: () => data.refreshMarketRates(),
      color: AppColors.finances,
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
                      color: AppColors.financesWash,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Text(
                      'عالم المال · صافي ثروتك 💰',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.financesDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الأصول',
                    style: GoogleFonts.lemonada(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تتبع مدخراتك من الذهب، الكاش، والاستثمارات ✨',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => data.refreshMarketRates(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, size: 14, color: AppColors.ink),
                      const SizedBox(width: 4),
                      Text(
                        'حدّث الأسعار',
                        style: GoogleFonts.tajawal(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. كارت إجمالي صافي الثروة بخط اليد (Assets Total Card)
          SketchCard(
            backgroundColor: AppColors.surfaceCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صافي ثروتك التقريبي',
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.financesWash,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.finances, width: 1),
                      ),
                      child: Text(
                        'حساب حي 📊',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.financesDeep,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(total),
                  style: GoogleFonts.lemonada(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'صافي الثروة السائلة (دهب + كاش): ${_formatCurrency(liquid)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.inkFaint, height: 1),
                const SizedBox(height: 10),

                // تفصيل الفئات
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBreakdownChip('🪙 دهب', _formatCurrency(goldSum), AppColors.habitsWash),
                    _buildBreakdownChip('💵 كاش', _formatCurrency(cashSum), AppColors.brandWash),
                    if (otherSum > 0)
                      _buildBreakdownChip('🏷️ أصول', _formatCurrency(otherSum), AppColors.paper),
                    if (liabilities > 0)
                      _buildBreakdownChip('📉 التزامات', '−${_formatCurrency(liabilities)}', const Color(0xFFFBEBEB)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. كارت أسعار السوق الحية (Market Rates)
          SketchCard(
            backgroundColor: AppColors.financesWash,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '🪙 سعر جرام الذهب (ع٢٤)',
                      style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.inkMuted),
                    ),
                    Text(
                      '${_formatNum(data.goldG24Price)} ج.م',
                      style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: AppColors.inkFaint),
                Column(
                  children: [
                    Text(
                      '💵 سعر صرف الدولار',
                      style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.inkMuted),
                    ),
                    Text(
                      '${_formatNum(data.usdRate)} ج.م',
                      style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. نموذج إضافة أصل جديد (Add Asset Form)
          SketchCard(
            backgroundColor: AppColors.surfaceCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ضيف أصل جديد 🪙',
                  style: GoogleFonts.lemonada(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),

                // اختيار نوع الأصل
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _types.map((t) {
                    final isSel = _selectedType == t['key'];
                    return InkWell(
                      onTap: () => setState(() => _selectedType = t['key']!),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.brand : AppColors.paper,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        child: Text(
                          t['label']!,
                          style: GoogleFonts.tajawal(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // حقول النموذج الديناميكية
                TextField(
                  controller: _nameCtrl,
                  style: GoogleFonts.tajawal(fontSize: 13.5, color: AppColors.ink),
                  decoration: InputDecoration(
                    labelText: 'اسم / وصف الأصل (اختياري)',
                    labelStyle: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                    fillColor: AppColors.paper,
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                if (_selectedType == 'gold') ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.tajawal(fontSize: 13.5, color: AppColors.ink),
                          decoration: InputDecoration(
                            labelText: 'الوزن بالجرام',
                            labelStyle: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                            fillColor: AppColors.paper,
                            filled: true,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          value: _selectedKarat,
                          items: _karats.map((k) {
                            return DropdownMenuItem(value: k, child: Text('عيار $k'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedKarat = val);
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.paper,
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (_selectedType == 'cash' || _selectedType == 'liability') ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.tajawal(fontSize: 13.5, color: AppColors.ink),
                          decoration: InputDecoration(
                            labelText: 'المبلغ',
                            labelStyle: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                            fillColor: AppColors.paper,
                            filled: true,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          items: _currencies.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrency = val);
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.paper,
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TextField(
                    controller: _valCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.tajawal(fontSize: 13.5, color: AppColors.ink),
                    decoration: InputDecoration(
                      labelText: 'القيمة التقديرية بالجنيه',
                      labelStyle: GoogleFonts.tajawal(fontSize: 12, color: AppColors.inkMuted),
                      fillColor: AppColors.paper,
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                SketchButton.primary(
                  text: '＋ إضافة الأصل',
                  onPressed: _submitAsset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. قائمة الأصول (Assets List)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أصولك المسجلة 📋',
                style: GoogleFonts.lemonada(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '${assets.length} أصل',
                style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (assets.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    'مفيش أصول مسجلة بعد — ضيف دهب أو كاش من فوق!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...assets.map((asset) => _buildAssetCard(asset, data)),
        ],
      ),
    );
  }

  Widget _buildBreakdownChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ink, width: 1.2),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.tajawal(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: AppColors.ink,
        ),
      ),
    );
  }

  Widget _buildAssetCard(AssetItemModel asset, DataProvider data) {
    final valueEgp = asset.calculateValueEgp(goldG24: data.goldG24Price);
    final isLiability = asset.type == 'liability';

    final String icon = asset.type == 'gold'
        ? '🪙'
        : asset.type == 'cash'
            ? '💵'
            : asset.type == 'liability'
                ? '📉'
                : '🏷️';

    String detail = '';
    if (asset.type == 'gold') {
      detail = '${_formatNum(asset.quantity)} جرام · عيار ${asset.karat}';
    } else if (asset.type == 'cash' || asset.type == 'liability') {
      detail = '${_formatNum(asset.quantity)} ${asset.currency}';
    }

    return SketchCard(
      margin: const EdgeInsets.only(bottom: 10),
      backgroundColor: isLiability ? const Color(0xFFFFF7F7) : AppColors.surfaceCard,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: GoogleFonts.tajawal(
                      fontSize: 11.5,
                      color: AppColors.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isLiability ? '−' : ''}${_formatCurrency(valueEgp)}',
                style: GoogleFonts.lemonada(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isLiability ? Colors.red.shade700 : AppColors.ink,
                ),
              ),
              IconButton(
                onPressed: () => data.deleteAsset(asset.id),
                icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.inkMuted),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
