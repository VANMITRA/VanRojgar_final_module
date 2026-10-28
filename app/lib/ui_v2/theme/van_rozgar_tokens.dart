import 'package:flutter/material.dart';

/// Design tokens for the VanRozgar Phase 1 UI.
///
/// Contains exact light/dark palettes, spacing, typography, radiuses, and
/// elevations as required by the specification.
class VanRozgarTokens {
  VanRozgarTokens._();

  // Font family bundled in the project
  static const String fontFamily = 'NotoSansDevanagari';

  // Fixed neutrals across both light & dark
  static const Color picturePanel = Color(0xFFE4EDCB);
  static const Color white = Color(0xFFFFFFFF);

  // Light Palette
  static const Color lightPage = Color(0xFFF7F2E8);
  static const Color lightPrimaryGreen = Color(0xFF4E7A3A); // white text on it
  static const Color lightHeadingGreen = Color(0xFF2F4A2A);
  static const Color lightPista = Color(0xFFDDE8C6); // chips, circles
  static const Color lightBrown = Color(0xFF5A3B22); // outlined controls
  static const Color lightOrange = Color(0xFFA4551A); // prices & highlights only
  static const Color lightBodyText = Color(0xFF3F4A36);
  static const Color lightMutedText = Color(0xFF7B6A55);
  static const Color lightBorders = Color(0xFFE2D6BE);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Dark Palette
  static const Color darkPage = Color(0xFF1C2619);
  static const Color darkPrimaryGreen = Color(0xFF8DB85A); // dark text #1C2619 on it
  static const Color darkHeadingCream = Color(0xFFF4F7EA);
  static const Color darkCard = Color(0xFF2E3E2B);
  static const Color darkChips = Color(0xFF3A5233); // text #DDE8C6
  static const Color darkTan = Color(0xFFD8B48A); // outlined controls
  static const Color darkOrange = Color(0xFFF0A15A); // prices & highlights only
  static const Color darkBodyText = Color(0xFFE9EFDC);
  static const Color darkMutedText = Color(0xFFA9B49A);
  static const Color darkBorders = Color(0xFF3C4E38);

  // Spacing Tokens: 4, 8, 12, 16, 20, 24, 32
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Radius Tokens: small controls, cards, image panels, pills
  static const double radiusSmall = 8.0;
  static const double radiusImage = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusPill = 999.0;

  static const BorderRadius borderSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderImage = BorderRadius.all(Radius.circular(radiusImage));
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(radiusPill));

  // Minimum touch target
  static const double minTouchTarget = 48.0;

  // Full-screen background artwork paths
  static const String backgroundFullLightAsset = 'assets/backgrounds/bg_full_light.jpg';
  static const String backgroundFullDarkAsset = 'assets/backgrounds/bg_full_dark.jpg';

  // Landing screen slide artwork paths
  static const String landingSlide1Top = 'assets/landing/landing_1a_bamboo.jpg';
  static const String landingSlide1Bottom = 'assets/landing/landing_1b_mango.jpg';
  static const String landingSlide2Top = 'assets/landing/landing_2a_herbs_fresh.jpg';
  static const String landingSlide2Bottom = 'assets/landing/landing_2b_herbs_dried.jpg';
  static const String landingSlide3Top = 'assets/landing/landing_3a_weaving.jpg';
  static const String landingSlide3Bottom = 'assets/landing/landing_3b_village_sorting.jpg';
}

/// Token collection bundle accessible via Theme extension or direct token resolution.
class VanRozgarColorTokens extends ThemeExtension<VanRozgarColorTokens> {
  final Color page;
  final Color primaryGreen;
  final Color onPrimaryGreen;
  final Color heading;
  final Color card;
  final Color chipBg;
  final Color chipText;
  final Color outlinedControl;
  final Color orange;
  final Color bodyText;
  final Color mutedText;
  final Color borders;
  final Color picturePanel;

  const VanRozgarColorTokens({
    required this.page,
    required this.primaryGreen,
    required this.onPrimaryGreen,
    required this.heading,
    required this.card,
    required this.chipBg,
    required this.chipText,
    required this.outlinedControl,
    required this.orange,
    required this.bodyText,
    required this.mutedText,
    required this.borders,
    required this.picturePanel,
  });

  static const light = VanRozgarColorTokens(
    page: VanRozgarTokens.lightPage,
    primaryGreen: VanRozgarTokens.lightPrimaryGreen,
    onPrimaryGreen: VanRozgarTokens.white,
    heading: VanRozgarTokens.lightHeadingGreen,
    card: VanRozgarTokens.lightCard,
    chipBg: VanRozgarTokens.lightPista,
    chipText: VanRozgarTokens.lightHeadingGreen,
    outlinedControl: VanRozgarTokens.lightBrown,
    orange: VanRozgarTokens.lightOrange,
    bodyText: VanRozgarTokens.lightBodyText,
    mutedText: VanRozgarTokens.lightMutedText,
    borders: VanRozgarTokens.lightBorders,
    picturePanel: VanRozgarTokens.picturePanel,
  );

  static const dark = VanRozgarColorTokens(
    page: VanRozgarTokens.darkPage,
    primaryGreen: VanRozgarTokens.darkPrimaryGreen,
    onPrimaryGreen: VanRozgarTokens.darkPage,
    heading: VanRozgarTokens.darkHeadingCream,
    card: VanRozgarTokens.darkCard,
    chipBg: VanRozgarTokens.darkChips,
    chipText: VanRozgarTokens.lightPista,
    outlinedControl: VanRozgarTokens.darkTan,
    orange: VanRozgarTokens.darkOrange,
    bodyText: VanRozgarTokens.darkBodyText,
    mutedText: VanRozgarTokens.darkMutedText,
    borders: VanRozgarTokens.darkBorders,
    picturePanel: VanRozgarTokens.picturePanel,
  );

  @override
  VanRozgarColorTokens copyWith({
    Color? page,
    Color? primaryGreen,
    Color? onPrimaryGreen,
    Color? heading,
    Color? card,
    Color? chipBg,
    Color? chipText,
    Color? outlinedControl,
    Color? orange,
    Color? bodyText,
    Color? mutedText,
    Color? borders,
    Color? picturePanel,
  }) {
    return VanRozgarColorTokens(
      page: page ?? this.page,
      primaryGreen: primaryGreen ?? this.primaryGreen,
      onPrimaryGreen: onPrimaryGreen ?? this.onPrimaryGreen,
      heading: heading ?? this.heading,
      card: card ?? this.card,
      chipBg: chipBg ?? this.chipBg,
      chipText: chipText ?? this.chipText,
      outlinedControl: outlinedControl ?? this.outlinedControl,
      orange: orange ?? this.orange,
      bodyText: bodyText ?? this.bodyText,
      mutedText: mutedText ?? this.mutedText,
      borders: borders ?? this.borders,
      picturePanel: picturePanel ?? this.picturePanel,
    );
  }

  @override
  VanRozgarColorTokens lerp(ThemeExtension<VanRozgarColorTokens>? other, double t) {
    if (other is! VanRozgarColorTokens) return this;
    return VanRozgarColorTokens(
      page: Color.lerp(page, other.page, t)!,
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      onPrimaryGreen: Color.lerp(onPrimaryGreen, other.onPrimaryGreen, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
      card: Color.lerp(card, other.card, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      outlinedControl: Color.lerp(outlinedControl, other.outlinedControl, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      borders: Color.lerp(borders, other.borders, t)!,
      picturePanel: Color.lerp(picturePanel, other.picturePanel, t)!,
    );
  }
}
