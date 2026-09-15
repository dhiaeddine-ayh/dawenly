import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import 'dw_bottom_nav.dart';
import 'dw_icons.dart';

class DwSidebar extends StatelessWidget {
  final DwTab currentTab;
  final ValueChanged<DwTab> onSelectTab;
  final VoidCallback onReportIssue;
  final VoidCallback? onAiSettings;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onNotificationsPressed;
  final int unreadNotificationsCount;

  const DwSidebar({
    super.key,
    required this.currentTab,
    required this.onSelectTab,
    required this.onReportIssue,
    this.onAiSettings,
    this.onRefresh,
    this.onNotificationsPressed,
    this.unreadNotificationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'مستخدم دوّنلي';
    final avatarLetter = userName.isNotEmpty ? userName[0] : 'د';

    return Drawer(
      backgroundColor: AppColors.surfaceCard,
      surfaceTintColor: Colors.transparent,
      width: 270,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Scrollable Nav Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الشعار
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 20, top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                          'assets/logo/dawwenli-logo.svg',
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // النظرة العامة
                    _buildNavButton(
                      tab: DwTab.overview,
                      title: 'النظرة العامة',
                      svgIcon: DwIcons.overview,
                      activeColor: AppColors.brandDeep,
                      washColor: AppColors.brandWash,
                      indicatorColor: AppColors.brand,
                    ),

                    const SizedBox(height: 10),
                    _buildNavGroup('يومياتك (هتدخلها دايمًا)'),
                    _buildNavButton(
                      tab: DwTab.health,
                      title: 'الصحة',
                      svgIcon: DwIcons.healthWithPulse,
                      activeColor: AppColors.healthDeep,
                      washColor: AppColors.healthWash,
                      indicatorColor: AppColors.health,
                    ),
                    _buildNavButton(
                      tab: DwTab.habits,
                      title: 'العادات',
                      svgIcon: DwIcons.habits,
                      activeColor: AppColors.habitsDeep,
                      washColor: AppColors.habitsWash,
                      indicatorColor: AppColors.habits,
                    ),
                    _buildNavButton(
                      tab: DwTab.goals,
                      title: 'الأهداف',
                      svgIcon: DwIcons.goals,
                      activeColor: AppColors.goalsDeep,
                      washColor: AppColors.goalsWash,
                      indicatorColor: AppColors.goals,
                    ),
                    _buildNavButton(
                      tab: DwTab.finances,
                      title: 'الفلوس',
                      svgIcon: DwIcons.finances,
                      activeColor: AppColors.financesDeep,
                      washColor: AppColors.financesWash,
                      indicatorColor: AppColors.finances,
                    ),
                    _buildNavButton(
                      tab: DwTab.tasks,
                      title: 'المهام والتقويم',
                      svgIcon: DwIcons.tasks,
                      activeColor: AppColors.goalsDeep,
                      washColor: AppColors.goalsWash,
                      indicatorColor: AppColors.goals,
                    ),

                    const SizedBox(height: 10),
                    _buildNavGroup('دفترك (من وقت للتاني)'),
                    _buildNavButton(
                      tab: DwTab.dafter,
                      title: 'دفترك',
                      subtitle: 'يوميات · خواطر · أفكار',
                      svgIcon: DwIcons.dafter,
                      activeColor: AppColors.brandDeep,
                      washColor: AppColors.brandWash,
                      indicatorColor: AppColors.brand,
                    ),
                    _buildNavButton(
                      tab: DwTab.assets,
                      title: 'الأصول',
                      svgIcon: DwIcons.assets,
                      activeColor: AppColors.financesDeep,
                      washColor: AppColors.financesWash,
                      indicatorColor: AppColors.finances,
                    ),

                    const SizedBox(height: 10),
                    _buildNavGroup('أدوات'),
                    _buildNavButton(
                      tab: DwTab.ask,
                      title: 'اسأل دوّنلي',
                      svgIcon: DwIcons.ask,
                      activeColor: AppColors.brandDeep,
                      washColor: AppColors.brandWash,
                      indicatorColor: AppColors.brand,
                    ),
                    _buildNavButton(
                      tab: DwTab.files,
                      title: 'مركز الملفات',
                      svgIcon: DwIcons.files,
                      activeColor: AppColors.healthDeep,
                      washColor: AppColors.healthWash,
                      indicatorColor: AppColors.health,
                    ),
                    _buildNavButton(
                      tab: DwTab.chats,
                      title: 'المحادثات',
                      svgIcon: DwIcons.chats,
                      activeColor: AppColors.brandDeep,
                      washColor: AppColors.brandWash,
                      indicatorColor: AppColors.brand,
                    ),
                    _buildNavButton(
                      tab: DwTab.about,
                      title: 'دوّنلي يعرف عنك',
                      svgIcon: DwIcons.about,
                      activeColor: AppColors.brandDeep,
                      washColor: AppColors.brandWash,
                      indicatorColor: AppColors.brand,
                    ),
                    _buildNavButton(
                      tab: DwTab.settings,
                      title: 'الإعدادات (الذكاء والتهيئة)',
                      svgIcon: DwIcons.settings,
                      activeColor: AppColors.brandDeep,
                      washColor: AppColors.brandWash,
                      indicatorColor: AppColors.brand,
                    ),
                    _buildActionNavButton(
                      title: 'بلّغ عن مشكلة',
                      svgIcon: DwIcons.report,
                      onTap: onReportIssue,
                    ),

                    // صندوق النصيحة السريعة
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.brandWash,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: AppColors.brandTint, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎙️ دوّن بسرعة',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandDeep,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'سجّل صوتك أو اكتب عن يومك وأنا أرتّبه في عوالمك.',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // User Footer Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.hairline, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // الأفاتار
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.brandTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      avatarLetter,
                      style: GoogleFonts.lemonada(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // الاسم والوصف
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'دفترك الشخصي',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: AppColors.inkFaint,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // زر التحديث
                  if (onRefresh != null)
                    IconButton(
                      icon: DwIcons.svg(DwIcons.refresh, color: AppColors.inkMuted, size: 18),
                      onPressed: onRefresh,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),

                  // زر الإشعارات
                  if (onNotificationsPressed != null)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: DwIcons.svg(DwIcons.bell, color: AppColors.inkMuted, size: 19),
                          onPressed: onNotificationsPressed,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        if (unreadNotificationsCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              height: 15,
                              constraints: const BoxConstraints(minWidth: 15),
                              decoration: BoxDecoration(
                                color: AppColors.health,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.surfaceCard, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$unreadNotificationsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                  // زر تسجيل الخروج
                  IconButton(
                    icon: const Text(
                      '⎋',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.inkFaint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    tooltip: 'خروج',
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavGroup(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 12, bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.inkFaint,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required DwTab tab,
    required String title,
    String? subtitle,
    required String svgIcon,
    required Color activeColor,
    required Color washColor,
    required Color indicatorColor,
  }) {
    final isActive = currentTab == tab;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => onSelectTab(tab),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? washColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: isActive
                ? Border(
                    right: BorderSide(color: indicatorColor, width: 3.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: DwIcons.svg(
                  svgIcon,
                  color: isActive ? activeColor : AppColors.inkMuted,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: GoogleFonts.tajawal(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isActive ? activeColor : AppColors.inkMuted,
                    ),
                    children: [
                      if (subtitle != null)
                        TextSpan(
                          text: '  $subtitle',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkFaint,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionNavButton({
    required String title,
    required String svgIcon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: DwIcons.svg(
                  svgIcon,
                  color: AppColors.inkMuted,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
