import 'package:flutter/material.dart';

class VrTypography {
  static const String fontPrimary = 'NotoSans';
  static const String fontDevanagari = 'NotoSansDevanagari';

  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      // titleApp (20 / 700)
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.35,
      ),
      // headline (18 / 700)
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.35,
      ),
      // cardTitle (16 / 600)
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.35,
      ),
      // value (30 / 700)
      displaySmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.2,
      ),
      // body (14 / 400)
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.4,
      ),
      // caption (12 / 500)
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      // button (15 / 600)
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
    );
  }
}
