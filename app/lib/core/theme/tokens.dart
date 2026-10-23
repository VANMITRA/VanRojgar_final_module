import 'package:flutter/material.dart';

class VrTokens extends ThemeExtension<VrTokens> {
  final Color brandPrimary;
  final Color brandSecondary;
  final Color actionPrimary;
  final Color actionPressed;
  final Color background;
  final Color surface;
  final Color outline;
  final Color textPrimary;
  final Color textMuted;
  final Color onBrand;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Status Chip Backgrounds (10% light / 20% dark tints)
  final Color chipSuccessBg;
  final Color chipWarningBg;
  final Color chipErrorBg;
  final Color chipDefaultBg;

  /// Convenience alias for outline
  Color get border => outline;

  const VrTokens({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.actionPrimary,
    required this.actionPressed,
    required this.background,
    required this.surface,
    required this.outline,
    required this.textPrimary,
    required this.textMuted,
    required this.onBrand,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.chipSuccessBg,
    required this.chipWarningBg,
    required this.chipErrorBg,
    required this.chipDefaultBg,
  });

  static const VrTokens light = VrTokens(
    brandPrimary: Color(0xFF226E45), // Rich vibrant forest green matching reference video
    brandSecondary: Color(0xFF328A5B), // Fresh emerald secondary
    actionPrimary: Color(0xFFFF8D20),
    actionPressed: Color(0xFFD96B00),
    background: Color(0xFFF4F7F5),
    surface: Color(0xFFFFFFFF),
    outline: Color(0xFFE3E9E5),
    textPrimary: Color(0xFF13202B),
    textMuted: Color(0xFF66737C),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFF0B323),
    error: Color(0xFFD7262E),
    info: Color(0xFF2F5FB3),
    chipSuccessBg: Color(0x1A4CAF50),
    chipWarningBg: Color(0x1AF0B323),
    chipErrorBg: Color(0x1AD7262E),
    chipDefaultBg: Color(0x1A66737C),
  );

  static const VrTokens dark = VrTokens(
    brandPrimary: Color(0xFF2B7A4F),
    brandSecondary: Color(0xFF3F9A69),
    actionPrimary: Color(0xFFFF8D20),
    actionPressed: Color(0xFFD96B00),
    background: Color(0xFF112319),
    surface: Color(0xFF193425),
    outline: Color(0xFF2B5741),
    textPrimary: Color(0xFFF4F7F5),
    textMuted: Color(0xFFAAB8B2),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFF0B323),
    error: Color(0xFFD7262E),
    info: Color(0xFF2F5FB3),
    chipSuccessBg: Color(0x334CAF50),
    chipWarningBg: Color(0x33F0B323),
    chipErrorBg: Color(0x33D7262E),
    chipDefaultBg: Color(0x33AAB8B2),
  );

  @override
  ThemeExtension<VrTokens> copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? actionPrimary,
    Color? actionPressed,
    Color? background,
    Color? surface,
    Color? outline,
    Color? textPrimary,
    Color? textMuted,
    Color? onBrand,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? chipSuccessBg,
    Color? chipWarningBg,
    Color? chipErrorBg,
    Color? chipDefaultBg,
  }) {
    return VrTokens(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPressed: actionPressed ?? this.actionPressed,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      onBrand: onBrand ?? this.onBrand,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      chipSuccessBg: chipSuccessBg ?? this.chipSuccessBg,
      chipWarningBg: chipWarningBg ?? this.chipWarningBg,
      chipErrorBg: chipErrorBg ?? this.chipErrorBg,
      chipDefaultBg: chipDefaultBg ?? this.chipDefaultBg,
    );
  }

  @override
  ThemeExtension<VrTokens> lerp(ThemeExtension<VrTokens>? other, double t) {
    if (other is! VrTokens) return this;
    return VrTokens(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      actionPressed: Color.lerp(actionPressed, other.actionPressed, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      chipSuccessBg: Color.lerp(chipSuccessBg, other.chipSuccessBg, t)!,
      chipWarningBg: Color.lerp(chipWarningBg, other.chipWarningBg, t)!,
      chipErrorBg: Color.lerp(chipErrorBg, other.chipErrorBg, t)!,
      chipDefaultBg: Color.lerp(chipDefaultBg, other.chipDefaultBg, t)!,
    );
  }
}

extension VrContextExtension on BuildContext {
  VrTokens get vr => Theme.of(this).extension<VrTokens>() ?? VrTokens.light;
}
