import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/fact_check_result.dart';

// Import your ApiService
import 'api_service.dart';

class RecordingService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final ApiService _apiService = ApiService(); // Use the ApiService class

  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcript = '';
  String _error = '';
  String _recordingPath = '';
  Timer? _timer;
  int _secondsRecorded = 0;
  FactCheckResult? _factCheckResult;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get transcript => _transcript;
  String get error => _error;
  String get recordingDuration => _formatDuration(_secondsRecorded);
  FactCheckResult? get factCheckResult => _factCheckResult;

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> startRecording() async {
    try {
      _error = '';
      _secondsRecorded = 0;

      final directory = await getTemporaryDirectory();
      // We use .m4a which is standard for AAC
      _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc, // Standard mobile encoder
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath,
        );

        _isRecording = true;
        _startTimer();
        notifyListeners();
      } else {
        _error = 'Microphone permission denied';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Start Error: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRecorded++;
      notifyListeners();
    });
  }

  Future<void> stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _recorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        await _processRecording(path);
      }
    } catch (e) {
      _error = 'Stop Error: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> cancelRecording() async {
    _timer?.cancel();
    if (_isRecording) await _recorder.stop();
    _isRecording = false;
    _secondsRecorded = 0;
    notifyListeners();
  }

  Future<void> _processRecording(String audioPath) async {
    _isProcessing = true;
    _error = '';
    notifyListeners();

    try {
      // Step 1: Transcribe
      final transcriptResult = await _apiService.transcribeAudio(audioPath);

      if (transcriptResult['transcript'] == null) {
        throw Exception('Server returned empty transcript');
      }

      _transcript = transcriptResult['transcript'];
      notifyListeners();

      // Step 2: Fact Check
      final factCheckData = await _apiService.factCheck(_transcript);

      // Handle the case where server saves to DB but doesn't return full object
      if (factCheckData['success'] == true) {
        _factCheckResult = FactCheckResult.fromJson({
          ...factCheckData,
          'language': transcriptResult['language'] ?? 'English',
        });
      } else {
        throw Exception(factCheckData['error'] ?? 'Unknown fact check error');
      }

      _isProcessing = false;
      notifyListeners();

    } catch (e) {
      print("CRITICAL ERROR: $e"); // View this in your Run console
      // This ensures you see the REAL error on the screen
      _error = e.toString().replaceAll("Exception:", "");
      _isProcessing = false;
      notifyListeners();
    } finally {
      // Cleanup
      try { await File(audioPath).delete(); } catch (_) {}
    }
  }

  void reset() {
    _isRecording = false;
    _isProcessing = false;
    _transcript = '';
    _error = '';
    _secondsRecorded = 0;
    _factCheckResult = null;
    notifyListeners();
  }
}