import 'package:flutter/material.dart';
import 'package:nyawit/core/theme/app_theme.dart';
import 'package:nyawit/navigation/main_navigation.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  void setDarkMode(bool enabled) {
    final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == newMode) return;
    _themeMode = newMode;
    notifyListeners();
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
