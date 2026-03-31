import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WhisperService {
  static const String _whisperApiUrl = 'https://api.openai.com/v1/audio/transcriptions';
  String? _apiKey;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<bool> initialize({String? apiKey}) async {
    _apiKey = apiKey;
    _isInitialized = apiKey != null && apiKey.isNotEmpty;
    return _isInitialized;
  }

  Future<String?> transcribe(String audioPath, {String? apiKey}) async {
    final key = apiKey ?? _apiKey;
    if (key == null || key.isEmpty) {
      print('No API key provided for Whisper transcription');
      return null;
    }

    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        print('Audio file not found: $audioPath');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_whisperApiUrl),
      );
      request.headers['Authorization'] = 'Bearer $key';
      request.fields['model'] = 'whisper-1';
      request.files.add(
        await http.MultipartFile.fromPath('file', audioPath),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text'] as String?;
      } else {
        print('Whisper API error: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Transcription error: $e');
      return null;
    }
  }

  Future<bool> isModelDownloaded() async {
    return false;
  }

  void dispose() {
    _isInitialized = false;
  }
}
