import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'voice_modal.dart';

class VoiceFab extends StatelessWidget {
  const VoiceFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'voice_fab_tag',
      onPressed: () => VoiceModal.show(context),
      backgroundColor: AppColors.brand,
      icon: const Icon(Icons.mic, color: Colors.white, size: 24),
      label: const Text(
        'احكِ يومك',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
