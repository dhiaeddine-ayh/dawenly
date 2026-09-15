import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'sketch_card.dart';

enum WorldKind {
  health,
  habits,
  goals,
  finances,
}

class WorldCard extends StatelessWidget {
  final WorldKind kind;
  final String title;
  final String metric;
  final String caption;
  final VoidCallback? onTap;

  const WorldCard({
    super.key,
    required this.kind,
    required this.title,
    required this.metric,
    required this.caption,
    this.onTap,
  });

  Color get _washColor {
    switch (kind) {
      case WorldKind.health:
        return AppColors.healthWash;
      case WorldKind.habits:
        return AppColors.habitsWash;
      case WorldKind.goals:
        return AppColors.goalsWash;
      case WorldKind.finances:
        return AppColors.financesWash;
    }
  }

  Color get _deepColor {
    switch (kind) {
      case WorldKind.health:
        return AppColors.healthDeep;
      case WorldKind.habits:
        return AppColors.habitsDeep;
      case WorldKind.goals:
        return AppColors.goalsDeep;
      case WorldKind.finances:
        return AppColors.financesDeep;
    }
  }

  String get _assetPath {
    switch (kind) {
      case WorldKind.health:
        return 'assets/illustrations/world-health.svg';
      case WorldKind.habits:
        return 'assets/illustrations/world-habits.svg';
      case WorldKind.goals:
        return 'assets/illustrations/world-goals.svg';
      case WorldKind.finances:
        return 'assets/illustrations/world-finances.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SketchCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت: خلفية ملونة ناعمة مع الرسم التوضيحي الأصلي
          Container(
            height: 84,
            color: _washColor,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              _assetPath,
              width: 62,
              height: 62,
              fit: BoxFit.contain,
            ),
          ),

          // جسم الكارت
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // التاج الصغير
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _washColor,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _deepColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // الرقم أو المقياس
                Text(
                  metric,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lemonada(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),

                // الوصف التوضيحي
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
