import 'package:flutter/material.dart';

import 'screens/premium_shell.dart';
import 'theme/app_theme.dart';

class FintechApp extends StatelessWidget {
  const FintechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astra Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const PremiumShell(),
    );
  }
}
