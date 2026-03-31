class AppConstants {
  static const String appName = 'AI Meeting Minutes';
  static const String appVersion = '1.0.0';

  static const int maxRecordingDuration = 7200;

  static const int speechPauseDuration = 5;

  static const String defaultLanguage = 'zh_CN';

  static const Map<String, String> supportedLanguages = {
    'zh_CN': 'Chinese',
    'en_US': 'English',
    'ja_JP': 'Japanese',
    'ko_KR': 'Korean',
  };
}
