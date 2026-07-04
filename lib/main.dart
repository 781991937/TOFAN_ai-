import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/main_navigation.dart';

void main() {
  runApp(const ProviderScope(child: TofanAiApp()));
}

class TofanAiApp extends ConsumerWidget {
  const TofanAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}
