import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../../widgets/dw_icons.dart';
import '../../widgets/dw_bottom_nav.dart';

class DaftarBottomNav extends StatelessWidget {
  final DwTab currentTab;
  final ValueChanged<DwTab> onTabSelected;
  final VoidCallback onMorePressed;

  const DaftarBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.96),
        border: const Border(
          top: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 4,
        right: 4,
        top: 7,
        bottom: bottomPadding > 0 ? bottomPadding + 4 : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(
            tab: DwTab.overview,
            label: 'الرئيسية',
            svgIcon: DwIcons.overview,
            activeColor: AppColors.brandDeep,
            washColor: AppColors.brandWash,
          ),
          _buildTabItem(
            tab: DwTab.health,
            label: 'الصحة',
            svgIcon: DwIcons.health,
            activeColor: AppColors.healthDeep,
            washColor: AppColors.healthWash,
          ),
          _buildTabItem(
            tab: DwTab.habits,
            label: 'العادات',
            svgIcon: DwIcons.habits,
            activeColor: AppColors.habitsDeep,
            washColor: AppColors.habitsWash,
          ),
          _buildTabItem(
            tab: DwTab.goals,
            label: 'الأهداف',
            svgIcon: DwIcons.goals,
            activeColor: AppColors.goalsDeep,
            washColor: AppColors.goalsWash,
          ),
          _buildTabItem(
            tab: DwTab.finances,
            label: 'الفلوس',
            svgIcon: DwIcons.finances,
            activeColor: AppColors.financesDeep,
            washColor: AppColors.financesWash,
          ),
          _buildTabItem(
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
                    width: 52,
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
                  const SizedBox(height: 3),
                  Text(
                    'أكتر',
                    style: GoogleFonts.tajawal(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkFaint,
                      height: 1.0,
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

  Widget _buildTabItem({
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
              width: 52,
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
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isActive ? activeColor : AppColors.inkFaint,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
