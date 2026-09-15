import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class NotifModal extends StatelessWidget {
  const NotifModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotifModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: AppColors.ink, width: 2),
          left: BorderSide(color: AppColors.ink, width: 2),
          right: BorderSide(color: AppColors.ink, width: 2),
        ),
        boxShadow: [AppShadows.lg],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Head
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإشعارات',
                    style: GoogleFonts.lemonada(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'تعليم الكل مقروء',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandDeep,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Text(
                          '✕',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.inkFaint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.hairline, height: 1),

            // Content
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد إشعارات جديدة',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'سنخبرك هنا بكل تذكير وتحديث يخص أهدافك وعاداتك.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
