import 'package:flutter/material.dart';
import '../models/ai_config.dart';
import '../services/storage_service.dart';

class ConfigProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  AiConfig? _currentConfig;
  AiModelType _selectedModelType = AiModelType.openai;
  bool _isLoading = false;
  String? _error;

  AiConfig? get currentConfig => _currentConfig;
  AiModelType get selectedModelType => _selectedModelType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedType = await _storage.loadSelectedModelType();
      _selectedModelType = AiModelType.values.firstWhere(
        (e) => e.name == savedType,
        orElse: () => AiModelType.openai,
      );
      _currentConfig = await _storage.loadAiConfig();
      if (_currentConfig == null) {
        _currentConfig = AiConfig.getDefault(_selectedModelType);
      }
    } catch (e) {
      _error = 'Failed to load config: $e';
      _currentConfig = AiConfig.getDefault(_selectedModelType);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectModelType(AiModelType type) async {
    _selectedModelType = type;
    await _storage.saveSelectedModelType(type.name);

    final savedConfig = await _storage.loadAiConfig();
    if (savedConfig != null && savedConfig.modelType == type) {
      _currentConfig = savedConfig;
    } else {
      _currentConfig = AiConfig.getDefault(type);
    }

    notifyListeners();
  }

  Future<void> updateConfig(AiConfig config) async {
    _currentConfig = config;
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.saveAiConfig(config);
      await _storage.saveSelectedModelType(config.modelType.name);
      _selectedModelType = config.modelType;
    } catch (e) {
      _error = 'Failed to save config: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
