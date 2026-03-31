import 'package:whisper_ggml_plus/whisper_ggml_plus.dart';
import 'dart:io';

class WhisperService {
  WhisperGgmlPlus? _whisper;
  bool _isInitialized = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  Function(double)? _onProgressUpdate;

  bool get isInitialized => _isInitialized;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;

  Future<bool> initialize({Function(double)? onProgressUpdate}) async {
    if (_isInitialized) return true;
    try {
      _onProgressUpdate = onProgressUpdate;
      _whisper = WhisperGgmlPlus(
        onDownloadProgress: (progress) {
          _downloadProgress = progress;
          _isDownloading = progress < 1.0;
          _onProgressUpdate?.call(progress);
        },
      );
      await _whisper!.loadModel();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Whisper initialization error: $e');
      return false;
    }
  }

  Future<String?> transcribe(String audioPath) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!_isInitialized || _whisper == null) return null;

    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        print('Audio file not found: $audioPath');
        return null;
      }

      final result = await _whisper!.transcribe(audioPath);
      return result;
    } catch (e) {
      print('Transcription error: $e');
      return null;
    }
  }

  Future<bool> isModelDownloaded() async {
    try {
      return await _whisper?.isModelDownloaded() ?? false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _whisper = null;
    _isInitialized = false;
  }
}
