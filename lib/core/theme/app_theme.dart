import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF176B3A);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7F4),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );

    return base.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE8F5E9),
        shadowColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(thickness: 1, space: 0),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: base.colorScheme.surfaceContainerLow,
        selectedColor: base.colorScheme.secondaryContainer,
        side: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.onPrimary
              : base.colorScheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : base.colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF66BB6A),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF101510),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: base.colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: base.colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: base.colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: base.colorScheme.surfaceContainerHigh,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: base.colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: base.colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: base.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: base.colorScheme.secondaryContainer,
        shadowColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: base.colorScheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          side: BorderSide(color: base.colorScheme.outline),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: base.colorScheme.surfaceContainerLow,
        selectedColor: base.colorScheme.secondaryContainer,
        side: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.onPrimary
              : base.colorScheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : base.colorScheme.surfaceContainerHighest,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: base.colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: base.colorScheme.onInverseSurface),
      ),
    );
  }
}
