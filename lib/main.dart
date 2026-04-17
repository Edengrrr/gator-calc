import 'package:flutter/foundation.dart' show kIsWeb;
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
      title: 'GATOR Calc',

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

      // On web with a wide window, constrain to phone proportions and center.
      // On mobile the app fills the screen naturally at any phone size.
      // On a narrow web window (< 600px) it also fills naturally.
      builder: (context, child) {
        if (kIsWeb && MediaQuery.of(context).size.width > 600) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child!,
            ),
          );
        }
        return child!;
      },

      home: const AppShell(),
    );
  }
}