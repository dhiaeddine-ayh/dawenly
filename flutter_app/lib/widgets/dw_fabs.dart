import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'dw_icons.dart';

class DwFabs extends StatefulWidget {
  final VoidCallback onVoicePressed;
  final VoidCallback onToolsPressed;

  const DwFabs({
    super.key,
    required this.onVoicePressed,
    required this.onToolsPressed,
  });

  @override
  State<DwFabs> createState() => _DwFabsState();
}

class _DwFabsState extends State<DwFabs> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomBase = 82.0 + bottomPadding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. زر أدوات "اسأل دوّنلي" (فوق زر المايك)
          Positioned(
            right: 16,
            bottom: bottomBase + 56 + 12,
            child: _buildToolsFab(),
          ),

          // 2. زر المايك الصوتي "احكِ لي بصوتك"
          Positioned(
            right: 16,
            bottom: bottomBase,
            child: _buildVoiceFab(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsFab() {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
        boxShadow: [AppShadows.toolsFab],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onToolsPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: DwIcons.svg(
              DwIcons.toolsChat,
              color: AppColors.paper,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // الحلقة النابضة الخارجية
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Transform.scale(
                scale: _pulseScale.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brand.withOpacity(_pulseOpacity.value),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),

          // الزر الرئيسي
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
              boxShadow: [AppShadows.voiceFab],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onVoicePressed,
                customBorder: const CircleBorder(),
                child: Center(
                  child: DwIcons.svg(
                    DwIcons.voiceMic,
                    color: AppColors.onAccent,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
