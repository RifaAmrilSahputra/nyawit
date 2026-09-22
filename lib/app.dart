import 'package:flutter/material.dart';
import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/core/theme/app_theme.dart';
import 'package:nyawit/navigation/main_navigation.dart';
import 'package:sqflite/sqflite.dart';

enum AppThemePreference { light, dark, system }

class ThemeController extends ChangeNotifier {
  static const _themePreferenceKey = 'theme_mode';

  AppThemePreference _preference = AppThemePreference.light;
  bool _hasUserSelectedPreference = false;

  AppThemePreference get preference => _preference;
  ThemeMode get themeMode {
    return switch (_preference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system => ThemeMode.system,
    };
  }

  bool isUsingDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> load() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'app_settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [_themePreferenceKey],
        limit: 1,
      );
      if (rows.isEmpty) return;
      if (_hasUserSelectedPreference) return;

      final storedValue = rows.first['value'];
      final loadedPreference = AppThemePreference.values.firstWhere(
        (preference) => preference.name == storedValue,
        orElse: () => _migrateLegacyPreference(storedValue),
      );
      if (_preference == loadedPreference) return;
      _preference = loadedPreference;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference == preference) return;
    _hasUserSelectedPreference = true;
    _preference = preference;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('app_settings', {
        'key': _themePreferenceKey,
        'value': preference.name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  AppThemePreference _migrateLegacyPreference(Object? storedValue) {
    return switch (storedValue) {
      'true' => AppThemePreference.dark,
      'false' => AppThemePreference.light,
      _ => AppThemePreference.light,
    };
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope tidak ditemukan pada widget tree.');
    return scope!.notifier!;
  }
}

class NyawitApp extends StatefulWidget {
  const NyawitApp({super.key});

  @override
  State<NyawitApp> createState() => _NyawitAppState();
}

class _NyawitAppState extends State<NyawitApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
    _themeController.load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) => ThemeScope(
        controller: _themeController,
        child: MaterialApp(
          title: 'Nyawit',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          home: const MainNavigationShell(),
        ),
      ),
    );
  }
}
