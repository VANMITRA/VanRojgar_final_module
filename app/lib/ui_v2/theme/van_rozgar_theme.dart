import 'package:flutter/material.dart';
import 'van_rozgar_tokens.dart';

/// Builder for VanRozgar Light & Dark Material 3 Themes.
class VanRozgarTheme {
  VanRozgarTheme._();

  static const List<String> fontFallbacks = [
    'Roboto',
    'Noto Sans',
    'sans-serif',
  ];

  static TextTheme _buildTextTheme({required Color bodyColor, required Color headingColor, required Color mutedColor}) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: headingColor,
      ),
      displayMedium: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: headingColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: headingColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        color: headingColor,
      ),
      titleLarge: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        color: headingColor,
      ),
      titleMedium: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        color: headingColor,
      ),
      titleSmall: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: headingColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodySmall: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: headingColor,
      ),
      labelMedium: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: headingColor,
      ),
      labelSmall: TextStyle(
        fontFamily: VanRozgarTokens.fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: mutedColor,
      ),
    );
  }

  /// Light Theme
  static ThemeData get lightTheme {
    const tokens = VanRozgarColorTokens.light;
    final textTheme = _buildTextTheme(
      bodyColor: tokens.bodyText,
      headingColor: tokens.heading,
      mutedColor: tokens.mutedText,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: tokens.primaryGreen,
      onPrimary: tokens.onPrimaryGreen,
      secondary: tokens.heading,
      onSecondary: tokens.onPrimaryGreen,
      surface: tokens.page,
      onSurface: tokens.bodyText,
      error: tokens.orange,
      onError: VanRozgarTokens.white,
      errorContainer: tokens.chipBg,
      onErrorContainer: tokens.heading,
      outline: tokens.borders,
      outlineVariant: tokens.borders.withValues(alpha: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.page,
      canvasColor: tokens.page,
      fontFamily: VanRozgarTokens.fontFamily,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[
        VanRozgarColorTokens.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: tokens.heading),
      ),
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: 1.0,
        shadowColor: tokens.heading.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: VanRozgarTokens.borderCard,
          side: BorderSide(color: tokens.borders, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VanRozgarTokens.white.withValues(alpha: 0.95),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VanRozgarTokens.space16,
          vertical: VanRozgarTokens.space12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
        border: OutlineInputBorder(
          borderRadius: VanRozgarTokens.borderPill,
          borderSide: BorderSide(color: tokens.borders, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VanRozgarTokens.borderPill,
          borderSide: BorderSide(color: tokens.borders, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VanRozgarTokens.borderPill,
          borderSide: BorderSide(color: tokens.primaryGreen, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.chipBg,
        disabledColor: tokens.borders.withValues(alpha: 0.5),
        selectedColor: tokens.primaryGreen,
        secondarySelectedColor: tokens.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: VanRozgarTokens.space12, vertical: VanRozgarTokens.space8),
        shape: const RoundedRectangleBorder(
          borderRadius: VanRozgarTokens.borderPill,
        ),
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: tokens.chipText),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: tokens.onPrimaryGreen),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primaryGreen,
          foregroundColor: tokens.onPrimaryGreen,
          minimumSize: const Size(VanRozgarTokens.minTouchTarget, VanRozgarTokens.minTouchTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: VanRozgarTokens.borderPill,
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.outlinedControl,
          minimumSize: const Size(VanRozgarTokens.minTouchTarget, VanRozgarTokens.minTouchTarget),
          side: BorderSide(color: tokens.outlinedControl, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: VanRozgarTokens.borderPill,
          ),
          textStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.page,
        elevation: 2.0,
        indicatorColor: tokens.chipBg,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.heading, size: 24.0);
          }
          return IconThemeData(color: tokens.mutedText, size: 24.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: tokens.heading,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: tokens.mutedText,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    const tokens = VanRozgarColorTokens.dark;
    final textTheme = _buildTextTheme(
      bodyColor: tokens.bodyText,
      headingColor: tokens.heading,
      mutedColor: tokens.mutedText,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: tokens.primaryGreen,
      onPrimary: tokens.onPrimaryGreen,
      secondary: tokens.heading,
      onSecondary: tokens.page,
      surface: tokens.page,
      onSurface: tokens.bodyText,
      error: tokens.orange,
      onError: tokens.page,
      errorContainer: tokens.chipBg,
      onErrorContainer: tokens.chipText,
      outline: tokens.borders,
      outlineVariant: tokens.borders.withValues(alpha: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.page,
      canvasColor: tokens.page,
      fontFamily: VanRozgarTokens.fontFamily,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[
        VanRozgarColorTokens.dark,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: tokens.heading),
      ),
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: VanRozgarTokens.borderCard,
          side: BorderSide(color: tokens.borders, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.card.withValues(alpha: 0.95),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VanRozgarTokens.space16,
          vertical: VanRozgarTokens.space12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
        border: OutlineInputBorder(
          borderRadius: VanRozgarTokens.borderPill,
          borderSide: BorderSide(color: tokens.borders, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VanRozgarTokens.borderPill,
          borderSide: BorderSide(color: tokens.borders, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VanRozgarTokens.borderPill,
          borderSide: BorderSide(color: tokens.primaryGreen, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.chipBg,
        disabledColor: tokens.borders.withValues(alpha: 0.5),
        selectedColor: tokens.primaryGreen,
        secondarySelectedColor: tokens.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: VanRozgarTokens.space12, vertical: VanRozgarTokens.space8),
        shape: const RoundedRectangleBorder(
          borderRadius: VanRozgarTokens.borderPill,
        ),
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: tokens.chipText),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: tokens.onPrimaryGreen),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primaryGreen,
          foregroundColor: tokens.onPrimaryGreen,
          minimumSize: const Size(VanRozgarTokens.minTouchTarget, VanRozgarTokens.minTouchTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: VanRozgarTokens.borderPill,
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.outlinedControl,
          minimumSize: const Size(VanRozgarTokens.minTouchTarget, VanRozgarTokens.minTouchTarget),
          side: BorderSide(color: tokens.outlinedControl, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: VanRozgarTokens.borderPill,
          ),
          textStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.page,
        elevation: 2.0,
        indicatorColor: tokens.chipBg,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.chipText, size: 24.0);
          }
          return IconThemeData(color: tokens.mutedText, size: 24.0);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: tokens.heading,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: tokens.mutedText,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
    );
  }
}
