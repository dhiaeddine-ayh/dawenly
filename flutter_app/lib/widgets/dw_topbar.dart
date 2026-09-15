import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import 'dw_icons.dart';

class DwTopbar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onNotificationsPressed;
  final int unreadNotificationsCount;

  const DwTopbar({
    super.key,
    this.onMenuPressed,
    this.onRefresh,
    this.onNotificationsPressed,
    this.unreadNotificationsCount = 0,
  });

  @override
  State<DwTopbar> createState() => _DwTopbarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _DwTopbarState extends State<DwTopbar> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _spinController.repeat();
    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
    } finally {
      if (mounted) {
        _spinController.stop();
        _spinController.reset();
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 6,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اليمين في RTL: الشعار الأصلي
          SvgPicture.asset(
            'assets/logo/dawwenli-logo.svg',
            height: 30,
            fit: BoxFit.contain,
          ),

          // اليسار في RTL: أزرار التحديث، الإشعارات، القائمة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر التحديث الدوّار
              InkWell(
                onTap: _handleRefresh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: AnimatedBuilder(
                    animation: _spinController,
                    builder: (_, child) => Transform.rotate(
                      angle: -_spinController.value * 2 * math.pi,
                      child: child,
                    ),
                    child: DwIcons.svg(
                      DwIcons.refresh,
                      color: AppColors.ink,
                      size: 21,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // زر الإشعارات مع الشارة
              InkWell(
                onTap: widget.onNotificationsPressed,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      DwIcons.svg(
                        DwIcons.bell,
                        color: AppColors.ink,
                        size: 22,
                      ),
                      if (widget.unreadNotificationsCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            height: 17,
                            constraints: const BoxConstraints(minWidth: 17),
                            decoration: BoxDecoration(
                              color: AppColors.health,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.paper, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${widget.unreadNotificationsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // زر القائمة الجانبية (☰)
              InkWell(
                onTap: widget.onMenuPressed,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '☰',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
