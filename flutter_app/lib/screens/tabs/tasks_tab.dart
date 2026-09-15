import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/design_system/sketch_card.dart';
import '../../core/design_system/sketch_button.dart';
import '../../models/task_item.dart';
import '../../providers/data_provider.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  late DateTime _selectedDate;
  late DateTime _calendarMonth;
  final TextEditingController _taskTitleCtrl = TextEditingController();
  final TextEditingController _taskTimeCtrl = TextEditingController();
  bool _isGeneralTask = false;

  final List<String> _weekdaysAr = [
    'سبت',
    'أحد',
    'اثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
  ];

  final List<String> _monthNamesAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _calendarMonth = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _taskTitleCtrl.dispose();
    _taskTimeCtrl.dispose();
    super.dispose();
  }

  String _formatDateIso(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _toArabicNum(int n) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var s = n.toString();
    for (int i = 0; i < en.length; i++) {
      s = s.replaceAll(en[i], ar[i]);
    }
    return s;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _prevMonth() {
    setState(() {
      _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _calendarMonth = DateTime(now.year, now.month, 1);
    });
  }

  Future<void> _submitNewTask() async {
    final title = _taskTitleCtrl.text.trim();
    if (title.isEmpty) return;

    final dateStr = _isGeneralTask ? null : _formatDateIso(_selectedDate);
    final timeStr = _taskTimeCtrl.text.trim().isNotEmpty ? _taskTimeCtrl.text.trim() : null;

    await context.read<DataProvider>().addTask(
          title,
          date: dateStr,
          time: timeStr,
        );

    _taskTitleCtrl.clear();
    _taskTimeCtrl.clear();
    setState(() {
      _isGeneralTask = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final allTasks = data.tasks;
    final selectedIso = _formatDateIso(_selectedDate);
    final now = DateTime.now();
    final isTodaySelected = _isSameDay(_selectedDate, now);

    // Filter day tasks & general tasks
    final dayTasks = allTasks.where((t) => t.date == selectedIso).toList()
      ..sort((a, b) => (a.time ?? '99').compareTo(b.time ?? '99'));

    final generalTasks = allTasks.where((t) => t.date == null || t.date!.isEmpty).toList();

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      color: AppColors.goals,
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
                      color: AppColors.goalsWash,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Text(
                      'عالم الأهداف · دفترك 🎯',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goalsDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'المهام والتقويم',
                    style: GoogleFonts.lemonada(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'خطواتك اليومية، تفتح لك أبواب الغد ✨',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              // زر العودة لليوم
              InkWell(
                onTap: _goToday,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    'اليوم 📅',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. كارت التقويم الشهري التفاعلي بخط اليد (Calendar Card)
          _buildCalendarCard(allTasks),
          const SizedBox(height: 18),

          // 3. كارت مهام اليوم المحدد (Day Tasks Card)
          _buildDayTasksCard(dayTasks, isTodaySelected, data),
          const SizedBox(height: 18),

          // 4. كارت المهام العامة بدون تاريخ (General Tasks Card)
          _buildGeneralTasksCard(generalTasks, data),
          const SizedBox(height: 18),

          // 5. نصيحة دوّنلي الذكية في الأسفل
          _buildSmartTipCard(),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(List<TaskModel> allTasks) {
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final monthTitle = '${_monthNamesAr[month - 1]} ${_toArabicNum(year)}';

    final daysInMonth = DateTime(year, month + 1, 0).day;
    // DateTime.weekday: Monday is 1, Sunday is 7. In Arabic week (starts Saturday):
    // Saturday = 6 -> index 0, Sunday = 7 -> index 1, Monday = 1 -> index 2, etc.
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadBlanks = (firstWeekday + 1) % 7;

    // Group tasks by date
    final Map<String, List<TaskModel>> byDate = {};
    for (final t in allTasks) {
      if (t.date != null && t.date!.isNotEmpty) {
        byDate.putIfAbsent(t.date!, () => []).add(t);
      }
    }

    return SketchCard(
      backgroundColor: AppColors.surfaceCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط عنوان الشهر والتنقل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthTitle,
                style: GoogleFonts.lemonada(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Row(
                children: [
                  _buildNavArrow('›', _prevMonth),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _goToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: Text(
                        'اليوم',
                        style: GoogleFonts.tajawal(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildNavArrow('‹', _nextMonth),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // أسماء أيام الأسبوع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdaysAr.map((wd) {
              return Expanded(
                child: Center(
                  child: Text(
                    wd,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.inkFaint, height: 1),
          const SizedBox(height: 10),

          // شبكة الأيام
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.1,
            ),
            itemCount: leadBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadBlanks) {
                return const SizedBox.shrink();
              }

              final dayNum = index - leadBlanks + 1;
              final cellDate = DateTime(year, month, dayNum);
              final cellIso = _formatDateIso(cellDate);
              final isSelected = _isSameDay(cellDate, _selectedDate);
              final isToday = _isSameDay(cellDate, DateTime.now());

              final tasksForDay = byDate[cellIso] ?? [];
              final hasPending = tasksForDay.any((t) => !t.done);
              final hasDone = tasksForDay.any((t) => t.done);

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brand
                        : isToday
                            ? AppColors.brandWash
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: AppColors.ink, width: 2)
                        : isToday
                            ? Border.all(color: AppColors.brand, width: 1.5)
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _toArabicNum(dayNum),
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.brandDeep
                                  : AppColors.ink,
                        ),
                      ),
                      if (tasksForDay.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasPending)
                              Container(
                                width: 4.5,
                                height: 4.5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : AppColors.brand,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasDone)
                              Container(
                                width: 4.5,
                                height: 4.5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white70 : AppColors.goals,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavArrow(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildDayTasksCard(
    List<TaskModel> dayTasks,
    bool isTodaySelected,
    DataProvider data,
  ) {
    final title = isTodaySelected
        ? 'مهام اليوم 📋'
        : 'مهام ${_monthNamesAr[_selectedDate.month - 1]} ${_toArabicNum(_selectedDate.day)} 📋';

    return SketchCard(
      backgroundColor: AppColors.surfaceCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.lemonada(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandWash,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.brand, width: 1),
                ),
                child: Text(
                  '${_toArabicNum(dayTasks.where((t) => t.done).length)} / ${_toArabicNum(dayTasks.length)} مكتملة',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // نموذج إضافة مهمة جديدة بخط اليد
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _taskTitleCtrl,
                  style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'مهمة جديدة لليوم…',
                    hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.inkMuted),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.brand, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // حقل الوقت
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _taskTimeCtrl,
                        style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.ink),
                        decoration: InputDecoration(
                          hintText: '⏰ 15:30 (اختياري)',
                          hintStyle: GoogleFonts.tajawal(fontSize: 11, color: AppColors.inkMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // عامة (من غير يوم)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _isGeneralTask,
                          activeColor: AppColors.goals,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: AppColors.ink, width: 1.5),
                          onChanged: (val) {
                            setState(() {
                              _isGeneralTask = val ?? false;
                            });
                          },
                        ),
                        Text(
                          'عامة',
                          style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.ink),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // زر الإضافة
                    SketchButton.primary(
                      text: '＋ إضافة',
                      onPressed: _submitNewTask,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // قائمة مهام اليوم
          if (dayTasks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('✍️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    'مفيش مهام في هذا اليوم — ضيف واحدة فوق!',
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
            ...dayTasks.map((task) => _buildTaskRow(task, data)),
        ],
      ),
    );
  }

  Widget _buildGeneralTasksCard(List<TaskModel> generalTasks, DataProvider data) {
    return SketchCard(
      backgroundColor: AppColors.surfaceCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '📌 مهام عامة',
                style: GoogleFonts.lemonada(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '— ملهاش يوم محدّد',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${_toArabicNum(generalTasks.length)} مهمة',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (generalTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'مفيش مهام عامة — فعّل «عامة» وانت بتضيف مهمة ملهاش يوم 📌',
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 12.5,
                  color: AppColors.inkMuted,
                ),
              ),
            )
          else
            ...generalTasks.map((task) => _buildTaskRow(task, data)),
        ],
      ),
    );
  }

  Widget _buildTaskRow(TaskModel task, DataProvider data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: task.done ? AppColors.brandWash.withOpacity(0.5) : AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.done ? AppColors.brand.withOpacity(0.5) : AppColors.ink,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // صندوق الاختيار بخط اليد
          GestureDetector(
            onTap: () => data.toggleTask(task),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: task.done ? AppColors.brand : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.done ? AppColors.brandDeep : AppColors.ink,
                  width: 1.8,
                ),
              ),
              child: task.done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),

          // عنوان المهمة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    decoration: task.done ? TextDecoration.lineThrough : null,
                    color: task.done ? AppColors.inkMuted : AppColors.ink,
                  ),
                ),
                if (task.time != null && task.time!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.habitsWash,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.ink, width: 1),
                        ),
                        child: Text(
                          '⏰ ${task.time}',
                          style: GoogleFonts.tajawal(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // زر الحذف
          IconButton(
            onPressed: () => data.deleteTask(task.id),
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.inkMuted),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartTipCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goalsWash,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⏰', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'قل لدوّنلي في الشات الصوتي «عندي اجتماع غدًا الساعة ٥» وستجدها مسجلة هنا مباشرة 💡',
              style: GoogleFonts.tajawal(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
