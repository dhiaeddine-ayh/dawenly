import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'sketch_card.dart';
import 'sketch_button.dart';

class ComposerCard extends StatefulWidget {
  final Future<void> Function(String text)? onSubmit;
  final VoidCallback? onRecordVoice;

  const ComposerCard({
    super.key,
    this.onSubmit,
    this.onRecordVoice,
  });

  @override
  State<ComposerCard> createState() => _ComposerCardState();
}

class _ComposerCardState extends State<ComposerCard> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(text);
      }
      _controller.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SketchCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكومبوزر: حقل الإدخال مع أيقونة القلم
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  minLines: 2,
                  style: GoogleFonts.tajawal(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'احكِ لي ماذا فعلت اليوم...',
                    hintStyle: GoogleFonts.tajawal(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.inkFaint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  '✏️',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // تلميح سفلي
          Text(
            'اكتب عن يومك، أو سجّل صوتك من هنا 🎙️ وأنا أرتّبه',
            style: GoogleFonts.tajawal(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.inkFaint,
            ),
          ),

          const SizedBox(height: 14),

          // زراير الإجراءات: سجّل (ثانوي) ورتّبها لي (أساسي أخضر)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // زر سجّل
              SketchButton.secondary(
                text: 'سجّل 🎙️',
                isSmall: true,
                onPressed: widget.onRecordVoice,
              ),
              const SizedBox(width: 8),

              // زر رتّبها لي
              SketchButton.primary(
                text: 'رتّبها لي ✎',
                isSmall: true,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
