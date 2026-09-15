import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/design_system/daftar_topbar.dart';
import '../core/design_system/daftar_bottom_nav.dart';
import '../core/design_system/daftar_fabs.dart';
import '../providers/data_provider.dart';
import '../widgets/dw_bottom_nav.dart';
import '../widgets/dw_sidebar.dart';
import '../widgets/more_sheet.dart';
import '../widgets/notif_modal.dart';
import '../widgets/voice_modal.dart';
import 'chat_screen.dart';
import 'tabs/overview_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/habits_tab.dart';
import 'tabs/goals_tab.dart';
import 'tabs/finances_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/dafter_tab.dart';
import 'tabs/assets_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DwTab _currentTab = DwTab.overview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAll();
    });
  }

  void _onTabSelected(DwTab tab) {
    setState(() => _currentTab = tab);
  }

  void _openMoreSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoreSheet(
        onSelectTab: (tab) => setState(() => _currentTab = tab),
        onReportIssue: _openReportModal,
      ),
    );
  }

  void _openReportModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Text(
          'بلّغ عن مشكلة 🐞',
          style: GoogleFonts.lemonada(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إذا واجهتك أي مشكلة أو كان لديك اقتراح، اكتبه وسنتابعه فوراً.',
              style: GoogleFonts.tajawal(fontSize: 12.5, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'عنوان المشكلة أو الملاحظة',
                labelStyle: GoogleFonts.tajawal(fontSize: 12),
                hintText: 'مثال: خطأ في إضافة هدف',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'التفاصيل',
                labelStyle: GoogleFonts.tajawal(fontSize: 12),
                hintText: 'اشرح ما حدث بالتفصيل...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty) {
                final fullMsg = desc.isNotEmpty ? '$title\n\n$desc' : title;
                await context.read<DataProvider>().reportIssue(fullMsg, page: '/flutter-home');
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال تقريرك بنجاح، شكراً لك! 🙏'),
                      backgroundColor: AppColors.brand,
                    ),
                  );
                }
              }
            },
            child: Text('إرسال', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await context.read<DataProvider>().loadAll();
  }

  Widget _buildCurrentView() {
    switch (_currentTab) {
      case DwTab.overview:
        return OverviewTab(
          onTabChange: (index) {
            final tabMap = [
              DwTab.overview,
              DwTab.health,
              DwTab.habits,
              DwTab.goals,
              DwTab.finances,
              DwTab.tasks,
              DwTab.dafter,
            ];
            if (index >= 0 && index < tabMap.length) {
              setState(() => _currentTab = tabMap[index]);
            }
          },
        );
      case DwTab.health:
        return const HealthTab();
      case DwTab.habits:
        return const HabitsTab();
      case DwTab.goals:
        return const GoalsTab();
      case DwTab.finances:
        return const FinancesTab();
      case DwTab.tasks:
        return const TasksTab();
      case DwTab.dafter:
        return const DafterTab();
      case DwTab.assets:
        return const AssetsTab();
      case DwTab.ask:
        return const ChatScreen();
      case DwTab.files:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              '📎 مركز الملفات\nجاري تهيئته.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.inkMuted),
            ),
          ),
        );
      case DwTab.chats:
        return const ChatScreen();
      case DwTab.about:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              '🧠 دوّنلي يعرف عنك\nجاري تهيئته.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.inkMuted),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final unread = data.unreadNotificationsCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.paper,
        appBar: DaftarTopBar(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          onRefresh: _handleRefresh,
          onNotificationsPressed: () => NotifModal.show(context),
          unreadNotificationsCount: unread,
        ),
        drawer: DwSidebar(
          currentTab: _currentTab,
          onSelectTab: (tab) {
            Navigator.pop(context);
            setState(() => _currentTab = tab);
          },
          onReportIssue: () {
            Navigator.pop(context);
            _openReportModal();
          },
          onRefresh: _handleRefresh,
          onNotificationsPressed: () {
            Navigator.pop(context);
            NotifModal.show(context);
          },
          unreadNotificationsCount: unread,
        ),
        body: Stack(
          children: [
            // محتوى الصفحة الحالية
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(_currentTab),
                child: _buildCurrentView(),
              ),
            ),

            // الأزرار العائمة مع الهالات الناعمة المطابقة للقطة الشاشة
            DaftarFabs(
              onVoicePressed: () => VoiceModal.show(context),
              onToolsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: DaftarBottomNav(
          currentTab: _currentTab,
          onTabSelected: _onTabSelected,
          onMorePressed: _openMoreSheet,
        ),
      ),
    );
  }
}
