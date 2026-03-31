import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_config.dart';
import '../utils/prompts.dart';

class ApiService {
  Future<String?> generateMinutes(AiConfig config, String transcript) async {
    if (transcript.isEmpty) {
      return 'No transcript provided.';
    }

    try {
      if (config.modelType == AiModelType.ernie) {
        return await _callErnieApi(config, transcript);
      } else {
        return await _callOpenAiCompatibleApi(config, transcript);
      }
    } catch (e) {
      print('API call error: $e');
      return 'Error generating minutes: $e';
    }
  }

  Future<String> _callOpenAiCompatibleApi(AiConfig config, String transcript) async {
    final response = await http.post(
      Uri.parse(config.baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
      },
      body: jsonEncode({
        'model': config.modelName,
        'messages': [
          {'role': 'system', 'content': Prompts.meetingMinutesSystem},
          {'role': 'user', 'content': Prompts.getMeetingMinutesPrompt(transcript)},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _callErnieApi(AiConfig config, String transcript) async {
    final tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token'
        '?grant_type=client_credentials'
        '&client_id=${config.apiKey.split('|')[0]}'
        '&client_secret=${config.apiKey.split('|')[1]}';

    final tokenResponse = await http.get(Uri.parse(tokenUrl));
    if (tokenResponse.statusCode != 200) {
      throw Exception('Failed to get access token');
    }

    final tokenData = jsonDecode(tokenResponse.body);
    final accessToken = tokenData['access_token'];

    final chatUrl = 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions'
        '?access_token=$accessToken';

    final response = await http.post(
      Uri.parse(chatUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': Prompts.meetingMinutesSystem},
          {'role': 'user', 'content': Prompts.getMeetingMinutesPrompt(transcript)},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] as String;
    } else {
      throw Exception('Ernie API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> testConnection(AiConfig config) async {
    try {
      if (config.modelType == AiModelType.ernie) {
        final tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token'
            '?grant_type=client_credentials'
            '&client_id=${config.apiKey.split('|')[0]}'
            '&client_secret=${config.apiKey.split('|')[1]}';
        final response = await http.get(Uri.parse(tokenUrl));
        return response.statusCode == 200;
      } else {
        final response = await http.post(
          Uri.parse(config.baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${config.apiKey}',
          },
          body: jsonEncode({
            'model': config.modelName,
            'messages': [
              {'role': 'user', 'content': 'Hi'},
            ],
            'max_tokens': 10,
          }),
        );
        return response.statusCode == 200;
      }
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }
}
