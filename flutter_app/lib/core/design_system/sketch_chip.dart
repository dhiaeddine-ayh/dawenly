import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class SketchChip extends StatelessWidget {
  final String text;
  final Widget? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const SketchChip({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor = AppColors.surfaceCard,
    this.textColor = AppColors.inkMuted,
    this.borderColor = AppColors.hairline,
    this.onTap,
  });

  factory SketchChip.date({required String date, VoidCallback? onTap}) {
    return SketchChip(
      text: date,
      backgroundColor: AppColors.surfaceCard,
      textColor: AppColors.inkMuted,
      borderColor: AppColors.hairline,
      onTap: onTap,
    );
  }

  factory SketchChip.streak({required String streak, VoidCallback? onTap}) {
    return SketchChip(
      text: streak,
      icon: const Text('🔥', style: TextStyle(fontSize: 14)),
      backgroundColor: AppColors.habitsWash,
      textColor: AppColors.habitsDeep,
      borderColor: AppColors.habitsTint,
      onTap: onTap,
    );
  }

  factory SketchChip.cost({required String cost, VoidCallback? onTap}) {
    return SketchChip(
      text: cost,
      icon: const Text('💸', style: TextStyle(fontSize: 14)),
      backgroundColor: AppColors.financesWash,
      textColor: AppColors.financesDeep,
      borderColor: AppColors.financesTint,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F34302A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
