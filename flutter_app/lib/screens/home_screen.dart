import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/voice_fab.dart';
import 'chat_screen.dart';
import 'tabs/overview_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/habits_tab.dart';
import 'tabs/goals_tab.dart';
import 'tabs/finances_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/dafter_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAll();
    });
  }

  void _onSelectTab(int index) {
    setState(() => _currentIndex = index);
  }

  String get _currentTabTitle {
    switch (_currentIndex) {
      case 0:
        return 'النظرة العامة';
      case 1:
        return 'الصحة والنفسية';
      case 2:
        return 'متابعة العادات';
      case 3:
        return 'الأهداف الكبرى';
      case 4:
        return 'الفلوس والمصاريف';
      case 5:
        return 'المهام والتقويم';
      case 6:
        return 'دفترك الشخصي';
      default:
        return AppConstants.appName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final tabs = [
      OverviewTab(onTabChange: _onSelectTab),
      const HealthTab(),
      const HabitsTab(),
      const GoalsTab(),
      const FinancesTab(),
      const TasksTab(),
      const DafterTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/icon-192.png',
              width: 28,
              height: 28,
              errorBuilder: (_, _, _) => const Icon(Icons.edit_note, color: AppColors.brand),
            ),
            const SizedBox(width: 8),
            Text(
              _currentTabTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'المساعد الذكي',
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.brandLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: AppColors.brand, size: 22),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // User Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.brandLight,
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.brand,
                      child: Text(
                        (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'د',
                        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'مستخدم دوّنلي',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _drawerItem(0, 'النظرة العامة', Icons.dashboard_outlined),
                    _drawerItem(2, 'العادات', Icons.repeat),
                    _drawerItem(4, 'الفلوس والمصاريف', Icons.account_balance_wallet_outlined),
                    _drawerItem(5, 'المهام والتقويم', Icons.checklist_rtl),
                    _drawerItem(1, 'الصحة والنفسية', Icons.favorite_border),
                    _drawerItem(3, 'الأهداف', Icons.flag_outlined),
                    _drawerItem(6, 'دفترك (خواطر وأفكار)', Icons.menu_book_outlined),
                    const Divider(height: 24),
                    ListTile(
                      leading: const Icon(Icons.chat_outlined, color: AppColors.brand),
                      title: const Text('المساعد الذكي (Chat)', style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                      },
                    ),
                  ],
                ),
              ),

              // Offline Mode Status Indicator
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.brandLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brand.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: AppColors.brand, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'الوضع المحلي (Offline) مفعل بالكامل 📱',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.brandDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      floatingActionButton: const VoiceFab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
        onDestinationSelected: _onSelectTab,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: AppColors.brandLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.brand),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppColors.brand),
            label: 'الصحة',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat),
            selectedIcon: Icon(Icons.repeat_on, color: AppColors.brand),
            label: 'العادات',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag, color: AppColors.brand),
            label: 'الأهداف',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.brand),
            label: 'الفلوس',
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.brand : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.brand : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.brandLight.withOpacity(0.5),
      onTap: () {
        _onSelectTab(index);
        Navigator.pop(context);
      },
    );
  }
}
