import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_config.dart';
import '../providers/config_provider.dart';
import '../services/api_service.dart';
import '../widgets/model_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelNameController;

  bool _isTesting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController();
    _modelNameController = TextEditingController();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  void _updateControllers(AiConfig? config) {
    if (config != null) {
      _apiKeyController.text = config.apiKey;
      _baseUrlController.text = config.baseUrl;
      _modelNameController.text = config.modelName;
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
    });

    final configProvider = context.read<ConfigProvider>();
    final config = AiConfig(
      modelName: _modelNameController.text,
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      modelType: configProvider.selectedModelType,
    );

    final success = await _apiService.testConnection(config);

    if (mounted) {
      setState(() {
        _isTesting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connection successful!' : 'Connection failed. Check your settings.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final configProvider = context.read<ConfigProvider>();
    final config = AiConfig(
      modelName: _modelNameController.text,
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      modelType: configProvider.selectedModelType,
    );

    await configProvider.updateConfig(config);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ConfigProvider>(
        builder: (context, configProvider, child) {
          if (configProvider.isLoading && configProvider.currentConfig == null) {
            return const Center(child: CircularProgressIndicator());
          }

          _updateControllers(configProvider.currentConfig);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModelSelector(
                    selectedType: configProvider.selectedModelType,
                    onTypeChanged: (type) {
                      configProvider.selectModelType(type);
                      final defaultConfig = AiConfig.getDefault(type);
                      _apiKeyController.text = defaultConfig.apiKey;
                      _baseUrlController.text = defaultConfig.baseUrl;
                      _modelNameController.text = defaultConfig.modelName;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'API Configuration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      hintText: 'Enter your API key',
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'API key is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Base URL',
                      hintText: 'Enter API endpoint URL',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Base URL is required';
                      }
                      if (!value.startsWith('http')) {
                        return 'URL must start with http:// or https://';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelNameController,
                    decoration: const InputDecoration(
                      labelText: 'Model Name',
                      hintText: 'e.g., gpt-4, qwen-turbo',
                      prefixIcon: Icon(Icons.model_training),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Model name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.wifi),
                          label: const Text('Test Connection'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveSettings,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Model Presets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPresetCard(
                    'OpenAI',
                    'https://api.openai.com/v1/chat/completions',
                    'gpt-4, gpt-3.5-turbo',
                    Icons.cloud,
                  ),
                  const SizedBox(height: 8),
                  _buildPresetCard(
                    '通义千问 (Qwen)',
                    'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
                    'qwen-turbo, qwen-plus',
                    Icons.cloud,
                  ),
                  const SizedBox(height: 8),
                  _buildPresetCard(
                    '文心一言 (Ernie)',
                    'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions',
                    'ernie-bot, ernie-bot-4',
                    Icons.cloud,
                    note: 'API Key format: API_KEY|SECRET_KEY',
                  ),
                  const SizedBox(height: 8),
                  _buildPresetCard(
                    'DeepSeek',
                    'https://api.deepseek.com/v1/chat/completions',
                    'deepseek-chat, deepseek-coder',
                    Icons.cloud,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetCard(String name, String url, String models, IconData icon, {String? note}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              url,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Models: $models',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(
                note,
                style: const TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
