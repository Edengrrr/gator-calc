import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battletech_calc/app/app_shell.dart';
import 'package:battletech_calc/features/settings/logic/theme_provider.dart';

// BattleTech amber — used as the seed for both light and dark color schemes.
const _btSeed = Color(0xFFD4870A);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// MyApp watches the theme provider so the entire app re-themes instantly
// when the user changes the setting.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'BattleTech Calc',

      // Light theme — amber seed, Material 3 light palette.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _btSeed),
        useMaterial3: true,
      ),

      // Dark theme — same amber seed, dark brightness for a military aesthetic.
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _btSeed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Driven by the settings provider; defaults to dark on first launch.
      themeMode: themeMode,

      home: const AppShell(),
    );
  }
}