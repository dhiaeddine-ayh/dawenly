import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
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
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              voice.isProcessing
                  ? 'جاري تفريغ الصوت وتحليله بالذكاء الاصطناعي…'
                  : 'احكيلي يومك، مصاريفك، أو عاداتك…',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              voice.isProcessing ? 'ثواني وبنرتّب كل حاجة في مكانها' : 'مساعدك الذكي بيستخرج كل حاجة تلقائياً',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Pulsing Voice Indicator
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = voice.isRecording ? 1.0 + (_animController.value * 0.15) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: voice.isProcessing
                          ? AppColors.accent
                          : AppColors.brand,
                      boxShadow: [
                        BoxShadow(
                          color: (voice.isProcessing ? AppColors.accent : AppColors.brand)
                              .withOpacity(0.35 + (_animController.value * 0.2)),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: voice.isProcessing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          : const Icon(Icons.mic, size: 44, color: Colors.white),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            Text(
              voice.formattedDuration,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Controls: Cancel & Done
            if (!voice.isProcessing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await voice.cancelRecording();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: AppColors.danger),
                    label: const Text('إلغاء', style: TextStyle(color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.brand,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (voice.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(voice.errorMessage!),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('حفظ وتسجيل', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
