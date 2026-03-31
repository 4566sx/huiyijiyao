class AiConfig {
  final String modelName;
  final String apiKey;
  final String baseUrl;
  final AiModelType modelType;

  AiConfig({
    required this.modelName,
    required this.apiKey,
    required this.baseUrl,
    required this.modelType,
  });

  Map<String, dynamic> toMap() {
    return {
      'modelName': modelName,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'modelType': modelType.name,
    };
  }

  factory AiConfig.fromMap(Map<String, dynamic> map) {
    return AiConfig(
      modelName: map['modelName'] ?? '',
      apiKey: map['apiKey'] ?? '',
      baseUrl: map['baseUrl'] ?? '',
      modelType: AiModelType.values.firstWhere(
        (e) => e.name == map['modelType'],
        orElse: () => AiModelType.openai,
      ),
    );
  }

  AiConfig copyWith({
    String? modelName,
    String? apiKey,
    String? baseUrl,
    AiModelType? modelType,
  }) {
    return AiConfig(
      modelName: modelName ?? this.modelName,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      modelType: modelType ?? this.modelType,
    );
  }

  static AiConfig getDefault(AiModelType type) {
    switch (type) {
      case AiModelType.openai:
        return AiConfig(
          modelName: 'gpt-4',
          apiKey: '',
          baseUrl: 'https://api.openai.com/v1/chat/completions',
          modelType: AiModelType.openai,
        );
      case AiModelType.qwen:
        return AiConfig(
          modelName: 'qwen-turbo',
          apiKey: '',
          baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
          modelType: AiModelType.qwen,
        );
      case AiModelType.ernie:
        return AiConfig(
          modelName: 'ernie-bot',
          apiKey: '',
          baseUrl: 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions',
          modelType: AiModelType.ernie,
        );
      case AiModelType.deepseek:
        return AiConfig(
          modelName: 'deepseek-chat',
          apiKey: '',
          baseUrl: 'https://api.deepseek.com/v1/chat/completions',
          modelType: AiModelType.deepseek,
        );
    }
  }
}

enum AiModelType {
  openai,
  qwen,
  ernie,
  deepseek,
}

extension AiModelTypeExtension on AiModelType {
  String get displayName {
    switch (this) {
      case AiModelType.openai:
        return 'OpenAI';
      case AiModelType.qwen:
        return '通义千问';
      case AiModelType.ernie:
        return '文心一言';
      case AiModelType.deepseek:
        return 'DeepSeek';
    }
  }
}
