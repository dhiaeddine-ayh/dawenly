import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import 'dw_bottom_nav.dart';

class MoreSheet extends StatelessWidget {
  final ValueChanged<DwTab> onSelectTab;
  final VoidCallback onReportIssue;
  final VoidCallback? onAiSettings;
  final bool isOwner;

  const MoreSheet({
    super.key,
    required this.onSelectTab,
    required this.onReportIssue,
    this.onAiSettings,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E282420),
            blurRadius: 40,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Head
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 12),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.hairline,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'أقسام أكتر',
                        style: GoogleFonts.lemonada(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.hairline, height: 1),

            // Grid
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('دفترك'),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _buildItem(
                          icon: '📔',
                          label: 'دفترك (يوميات/خواطر)',
                          onTap: () {
                            Navigator.pop(context);
                            onSelectTab(DwTab.dafter);
                          },
                        ),
                        _buildItem(
                          icon: '💎',
                          label: 'الأصول (ذهب وعملات)',
                          onTap: () {
                            Navigator.pop(context);
                            onSelectTab(DwTab.assets);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('أدوات'),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _buildItem(
                          icon: '💬',
                          label: 'اسأل دوّنلي',
                          onTap: () {
                            Navigator.pop(context);
                            onSelectTab(DwTab.ask);
                          },
                        ),
                        _buildItem(
                          icon: '📎',
                          label: 'مركز الملفات',
                          onTap: () {
                            Navigator.pop(context);
                            onSelectTab(DwTab.files);
                          },
                        ),
                        _buildItem(
                          icon: '🗨️',
                          label: 'المحادثات',
                          onTap: () {
                            Navigator.pop(context);
                            onSelectTab(DwTab.chats);
                          },
                        ),
                        _buildItem(
                          icon: '🧠',
                          label: 'دوّنلي يعرف عنك',
                          onTap: () {
                            Navigator.pop(context);
                            onSelectTab(DwTab.about);
                          },
                        ),
                        _buildItem(
                          icon: '🐞',
                          label: 'بلّغ عن مشكلة',
                          onTap: () {
                            Navigator.pop(context);
                            onReportIssue();
                          },
                        ),
                        if (isOwner && onAiSettings != null)
                          _buildItem(
                            icon: '⚙️',
                            label: 'إعدادات الذكاء',
                            onTap: () {
                              Navigator.pop(context);
                              onAiSettings!();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.inkMuted,
      ),
    );
  }

  Widget _buildItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.hairline, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
