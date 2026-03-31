import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecording = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isRecording => _isRecording;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {},
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          } else if (status == 'listening') {
            _isListening = true;
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      print('Speech initialization error: $e');
      return false;
    }
  }

  Future<void> startListening({Function(String)? onResult}) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!_isInitialized) return;

    _speech.listen(
      onResult: (result) {
        onResult?.call(result.recognizedWords);
      },
      listenFor: const Duration(hours: 2),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'zh_CN',
    );
    _isListening = true;
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
  }

  Future<String?> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 16000,
          ),
          path: path,
        );
        _isRecording = true;
        return path;
      }
    } catch (e) {
      print('Recording error: $e');
    }
    return null;
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      print('Stop recording error: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _isRecording = false;
    } catch (e) {
      print('Cancel recording error: $e');
    }
  }

  void dispose() {
    _speech.stop();
    if (_isRecording) {
      _recorder.stop();
    }
  }
}
