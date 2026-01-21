import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MediaProjectionService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.example.truthlens/media_projection');

  bool _isRecording = false;
  bool _isProcessing = false;
  String? _currentRecordingPath;
  String? _error;
  int _recordingSeconds = 0;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  int get recordingSeconds => _recordingSeconds;
  String? get currentRecordingPath => _currentRecordingPath;

  MediaProjectionService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRecordingStatusChanged':
        final success = call.arguments['success'] as bool;
        if (success) {
          _isRecording = true;
          _startTimer();
        } else {
          _error = 'User denied screen recording permission';
          _isRecording = false;
        }
        notifyListeners();
        break;
    }
  }

  void _startTimer() {
    _recordingSeconds = 0;
    Future.doWhile(() async {
      if (!_isRecording) return false;
      await Future.delayed(const Duration(seconds: 1));
      _recordingSeconds++;
      notifyListeners();
      return true;
    });
  }

  Future<void> startRecording() async {
    try {
      _error = null;

      // Create output file path
      final directory = await getTemporaryDirectory();
      _currentRecordingPath = '${directory.path}/media_capture_${DateTime.now().millisecondsSinceEpoch}.pcm';

      // Start MediaProjection
      await _channel.invokeMethod('startMediaProjection', {
        'outputPath': _currentRecordingPath,
      });

      // Status will be updated via callback

    } catch (e) {
      _error = 'Failed to start recording: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<String?> stopRecording() async {
    try {
      await _channel.invokeMethod('stopMediaProjection');

      _isRecording = false;
      _isProcessing = true;
      notifyListeners();

      // Give the service time to finish writing
      await Future.delayed(const Duration(milliseconds: 500));

      // Convert PCM to M4A (you'll need to add audio conversion)
      // For now, return the PCM file path
      final path = _currentRecordingPath;
      _currentRecordingPath = null;

      _isProcessing = false;
      notifyListeners();

      return path;

    } catch (e) {
      _error = 'Failed to stop recording: $e';
      _isRecording = false;
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> convertPcmToM4a(String pcmPath) async {
    // TODO: Implement PCM to M4A conversion
    // You'll need to use FFmpeg or a similar library
    // For now, we'll return the PCM path directly
    // Note: Your backend may need to handle PCM format

    return pcmPath;
  }

  void reset() {
    _isRecording = false;
    _isProcessing = false;
    _error = null;
    _recordingSeconds = 0;
    _currentRecordingPath = null;
    notifyListeners();
  }
}