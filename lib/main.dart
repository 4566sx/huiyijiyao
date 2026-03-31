import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/meeting_provider.dart';
import 'providers/config_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  Intl.defaultLocale = 'zh_CN';
  runApp(const MeetingAIApp());
}

class MeetingAIApp extends StatelessWidget {
  const MeetingAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
      ],
      child: MaterialApp(
        title: 'AI Meeting Minutes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
