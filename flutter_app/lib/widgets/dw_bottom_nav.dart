import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import 'dw_icons.dart';

enum DwTab {
  overview,
  health,
  habits,
  goals,
  finances,
  tasks,
  dafter,
  assets,
  ask,
  files,
  chats,
  about,
  settings,
}

class DwBottomNav extends StatelessWidget {
  final DwTab currentTab;
  final ValueChanged<DwTab> onTabSelected;
  final VoidCallback onMorePressed;

  const DwBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 6,
        right: 6,
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding + 4 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.96),
        border: const Border(
          top: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildItem(
            tab: DwTab.overview,
            label: 'الرئيسية',
            svgIcon: DwIcons.overview,
            activeColor: AppColors.brandDeep,
            washColor: AppColors.brandWash,
          ),
          _buildItem(
            tab: DwTab.health,
            label: 'الصحة',
            svgIcon: DwIcons.health,
            activeColor: AppColors.healthDeep,
            washColor: AppColors.healthWash,
          ),
          _buildItem(
            tab: DwTab.habits,
            label: 'العادات',
            svgIcon: DwIcons.habits,
            activeColor: AppColors.habitsDeep,
            washColor: AppColors.habitsWash,
          ),
          _buildItem(
            tab: DwTab.goals,
            label: 'الأهداف',
            svgIcon: DwIcons.goals,
            activeColor: AppColors.goalsDeep,
            washColor: AppColors.goalsWash,
          ),
          _buildItem(
            tab: DwTab.finances,
            label: 'الفلوس',
            svgIcon: DwIcons.finances,
            activeColor: AppColors.financesDeep,
            washColor: AppColors.financesWash,
          ),
          _buildItem(
            tab: DwTab.tasks,
            label: 'المهام',
            svgIcon: DwIcons.tasks,
            activeColor: AppColors.goalsDeep,
            washColor: AppColors.goalsWash,
          ),
          // زر "أكتر"
          Expanded(
            child: InkWell(
              onTap: onMorePressed,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: DwIcons.svg(
                      DwIcons.more,
                      color: AppColors.inkFaint,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أكتر',
                    style: GoogleFonts.tajawal(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkFaint,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required DwTab tab,
    required String label,
    required String svgIcon,
    required Color activeColor,
    required Color washColor,
  }) {
    final isActive = currentTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? washColor : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: DwIcons.svg(
                svgIcon,
                color: isActive ? activeColor : AppColors.inkFaint,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isActive ? activeColor : AppColors.inkFaint,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
