import 'package:flutter/material.dart';
import '../constants.dart';

/// بطاقة سكتش مرسومة باليد (Hand-drawn Sketch Card)
/// تطابق بالضبط فئة .sketch-box في style.css
/// border-radius: 255px 15px 225px 15px / 15px 225px 15px 255px;
/// border: 2px solid #34302A;
class SketchCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool isAlt;
  final VoidCallback? onTap;

  const SketchCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor = AppColors.surfaceCard,
    this.borderColor = AppColors.ink,
    this.borderWidth = 2.0,
    this.isAlt = false,
    this.onTap,
  });

  BorderRadius get _sketchRadius {
    if (isAlt) {
      // radius-sketch-2: 15px 225px 15px 255px / 255px 15px 225px 15px;
      return const BorderRadius.only(
        topLeft: Radius.elliptical(15, 255),
        topRight: Radius.elliptical(225, 15),
        bottomRight: Radius.elliptical(15, 225),
        bottomLeft: Radius.elliptical(255, 15),
      );
    }
    // radius-sketch: 255px 15px 225px 15px / 15px 225px 15px 255px;
    return const BorderRadius.only(
      topLeft: Radius.elliptical(255, 15),
      topRight: Radius.elliptical(15, 225),
      bottomRight: Radius.elliptical(225, 15),
      bottomLeft: Radius.elliptical(15, 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: _sketchRadius,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1434302A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _sketchRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
