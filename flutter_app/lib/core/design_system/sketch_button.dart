import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

enum SketchButtonType {
  primary,
  secondary,
  ghost,
}

class SketchButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final SketchButtonType type;
  final bool isSmall;
  final bool isLoading;

  const SketchButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.type = SketchButtonType.primary,
    this.isSmall = false,
    this.isLoading = false,
  });

  const SketchButton.primary({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isSmall = false,
    this.isLoading = false,
  }) : type = SketchButtonType.primary;

  const SketchButton.secondary({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isSmall = false,
    this.isLoading = false,
  }) : type = SketchButtonType.secondary;

  const SketchButton.ghost({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isSmall = false,
    this.isLoading = false,
  }) : type = SketchButtonType.ghost;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow> shadows = [];

    switch (type) {
      case SketchButtonType.primary:
        bg = AppColors.brand;
        fg = AppColors.onAccent;
        border = Border.all(color: AppColors.brandDeep, width: 2.0);
        shadows = const [
          BoxShadow(
            color: Color(0x1434302A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ];
        break;
      case SketchButtonType.secondary:
        bg = AppColors.surfaceCard;
        fg = AppColors.ink;
        border = Border.all(color: AppColors.ink, width: 2.0);
        shadows = const [
          BoxShadow(
            color: Color(0x0F34302A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ];
        break;
      case SketchButtonType.ghost:
        bg = Colors.transparent;
        fg = AppColors.brandDeep;
        border = null;
        shadows = [];
        break;
    }

    final verticalPadding = isSmall ? 8.0 : 12.0;
    final horizontalPadding = isSmall ? 14.0 : 20.0;
    final fontSize = isSmall ? 13.0 : 15.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: shadows,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: fontSize,
                  height: fontSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.tajawal(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
