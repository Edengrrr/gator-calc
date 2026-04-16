import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controls the app-wide ThemeMode.
// Defaults to dark immediately; loads the persisted choice asynchronously in
// the background so there is no async gap blocking the initial frame.
class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  SharedPreferences? _prefs;

  @override
  ThemeMode build() {
    // Load the saved preference in the background and apply it if it differs
    // from the default. The brief moment before it resolves uses dark mode,
    // which is also the default — so there's no visible flash.
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      final saved = prefs.getString(_key);
      final loaded = switch (saved) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };
      if (state != loaded) state = loaded;
    });

    // Return dark while the async load completes.
    return ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _prefs?.setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
