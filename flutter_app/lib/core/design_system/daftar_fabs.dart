import 'package:flutter/material.dart';
import '../constants.dart';
import '../../widgets/dw_icons.dart';

class DaftarFabs extends StatefulWidget {
  final VoidCallback onVoicePressed;
  final VoidCallback onToolsPressed;

  const DaftarFabs({
    super.key,
    required this.onVoicePressed,
    required this.onToolsPressed,
  });

  @override
  State<DaftarFabs> createState() => _DaftarFabsState();
}

class _DaftarFabsState extends State<DaftarFabs> with SingleTickerProviderStateMixin {
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

    _pulseScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
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
    final bottomBase = 72.0 + bottomPadding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. زر المحادثة "اسأل دوّنلي" (الزر العلوي الحبري الأسود مع الهالة)
          Positioned(
            right: 18,
            bottom: bottomBase + 58 + 12,
            child: _buildChatButton(),
          ),

          // 2. زر المايك "احكِ لي بصوتك" (الزر السفلي الأخضر مع الهالة والنبض)
          Positioned(
            right: 18,
            bottom: bottomBase,
            child: _buildVoiceButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الهالة الناعمة المحيطة بالزر العلوي (الموجودة في لقطة الشاشة)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ink.withOpacity(0.06),
            ),
          ),

          // الزر الحبري
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33282420),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
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
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الهالة الناعمة المحيطة بالزر السفلي (الموجودة في لقطة الشاشة)
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brand.withOpacity(0.12),
            ),
          ),

          // حلقة النبض الخفيفة
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

          // الزر الأخضر الأساسي
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D5C8A6B),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
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
