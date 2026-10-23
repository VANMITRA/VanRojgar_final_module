import 'package:flutter/material.dart';
import 'tokens.dart';
import 'typography.dart';

class VrTheme {
  static ThemeData light() {
    const tokens = VrTokens.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: tokens.brandPrimary,
      scaffoldBackgroundColor: tokens.background,
      colorScheme: ColorScheme.light(
        primary: tokens.brandPrimary,
        secondary: tokens.brandSecondary,
        surface: tokens.surface,
        error: tokens.error,
        onPrimary: tokens.onBrand,
        onSurface: tokens.textPrimary,
        outline: tokens.outline,
      ),
      textTheme: VrTypography.textTheme(tokens.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.brandPrimary,
        foregroundColor: tokens.onBrand,
        elevation: 0,
        centerTitle: false,
      ),
      extensions: const [tokens],
    );
  }

  static ThemeData dark() {
    const tokens = VrTokens.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: tokens.brandPrimary,
      scaffoldBackgroundColor: tokens.background,
      colorScheme: ColorScheme.dark(
        primary: tokens.brandPrimary,
        secondary: tokens.brandSecondary,
        surface: tokens.surface,
        error: tokens.error,
        onPrimary: tokens.onBrand,
        onSurface: tokens.textPrimary,
        outline: tokens.outline,
      ),
      textTheme: VrTypography.textTheme(tokens.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.brandPrimary,
        foregroundColor: tokens.onBrand,
        elevation: 0,
        centerTitle: false,
      ),
      extensions: const [tokens],
    );
  }
}
