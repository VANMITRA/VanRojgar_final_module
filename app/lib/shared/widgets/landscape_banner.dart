import 'package:flutter/material.dart';
import 'hero_banner.dart';

class LandscapeBanner extends StatelessWidget {
  final double height;
  final Widget? overlayChild;

  const LandscapeBanner({
    super.key,
    this.height = 140,
    this.overlayChild,
  });

  @override
  Widget build(BuildContext context) {
    return HeroBanner(
      height: height,
      overlayChild: overlayChild,
    );
  }
}
