import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../services/local_storage_service.dart';

class VoiceProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final LocalStorageService _storage = LocalStorageService();

  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _lastResultText;
  String? _errorMessage;
  String? _recordedPath;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  int get recordDuration => _recordDuration;
  String? get lastResultText => _lastResultText;
  String? get errorMessage => _errorMessage;

  String get formattedDuration {
    final minutes = (_recordDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<bool> startRecording() async {
    _errorMessage = null;
    _lastResultText = null;

    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _recordedPath = '${dir.path}/dawenly_voice_$timestamp.m4a';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: _recordedPath!);
        _isRecording = true;
        _recordDuration = 0;
        _startTimer();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'لم يتم منح إذن استخدام الميكروفون';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'تعذر بدء التسجيل: $e';
      _isRecording = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> stopAndSend() async {
    _stopTimer();
    final durationText = formattedDuration;
    _isRecording = false;
    _isProcessing = true;
    notifyListeners();

    try {
      final path = await _audioRecorder.stop();
      final audioPath = path ?? _recordedPath;

      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;

      // حفظ التسجيل الصوتي محلياً في دفتر اليوميات
      try {
        final data = await _storage.loadData();
        final entriesList = (data['entries'] ?? []) as List;
        final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
        entriesList.insert(0, {
          'id': newId,
          'content': 'تسجيل صوتي 🎙️ ($durationText)\nتم الحفظ محلياً: ${audioPath != null ? audioPath.split('/').last : 'ملف صوتي'}',
          'type': 'journal',
          'created_at': DateTime.now().toIso8601String(),
        });
        data['entries'] = entriesList;
        await _storage.saveData(data);
      } catch (_) {}

      _lastResultText = 'تم حفظ التسجيل الصوتي محلياً في دفترك بنجاح 🎙️✅ ($durationText)';
      notifyListeners();
      return {
        'ok': true,
        'reply': _lastResultText,
        'path': audioPath,
      };
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء إنهاء التسجيل: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _stopTimer();
    try {
      await _audioRecorder.stop();
      if (_recordedPath != null) {
        final file = File(_recordedPath!);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
    _isRecording = false;
    _isProcessing = false;
    _recordDuration = 0;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordDuration++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _audioRecorder.dispose();
    super.dispose();
  }
}
