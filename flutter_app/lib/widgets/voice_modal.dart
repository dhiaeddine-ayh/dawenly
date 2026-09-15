import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/design_system/sketch_button.dart';
import '../providers/voice_provider.dart';
import '../providers/data_provider.dart';

class VoiceModal extends StatefulWidget {
  const VoiceModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceModal(),
    );
  }

  @override
  State<VoiceModal> createState() => _VoiceModalState();
}

class _VoiceModalState extends State<VoiceModal> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceProvider>().startRecording();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.ink, width: 2.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E282420),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.inkFaint,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              voice.isProcessing
                  ? 'جاري ترتيب تدويناتك بالذكاء الاصطناعي…'
                  : 'احكيلي يومك، مصاريفك، أو عاداتك… 🎙️',
              style: GoogleFonts.lemonada(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              voice.isProcessing
                  ? 'ثواني وبنرتّب كل حاجة في مكانها في دفترك'
                  : 'اتكلّم بطبيعتك، ودوّنلي هيستخرج كل حاجة تلقائياً 🌿',
              style: GoogleFonts.tajawal(
                fontSize: 12.5,
                color: AppColors.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Pulsing Voice Indicator with ink border and soft glow
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = voice.isRecording ? 1.0 + (_animController.value * 0.12) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: voice.isProcessing
                          ? AppColors.habits
                          : AppColors.brand,
                      border: Border.all(color: AppColors.ink, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: (voice.isProcessing ? AppColors.habits : AppColors.brand)
                              .withOpacity(0.35 + (_animController.value * 0.2)),
                          blurRadius: 25,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: voice.isProcessing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          : const Icon(Icons.mic, size: 46, color: Colors.white),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: Text(
                voice.formattedDuration,
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Controls: Cancel & Done
            if (!voice.isProcessing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SketchButton.ghost(
                    text: '✕ إلغاء',
                    onPressed: () async {
                      await voice.cancelRecording();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  SketchButton.primary(
                    text: '✓ حفظ وتسجيل',
                    onPressed: () async {
                      final result = await voice.stopAndSend();
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (result != null) {
                          context.read<DataProvider>().loadAll();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                voice.lastResultText ?? 'اتسجّلت بياناتك بنجاح ✅',
                                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.brand,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (voice.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                voice.errorMessage!,
                                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
