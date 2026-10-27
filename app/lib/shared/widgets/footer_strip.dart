import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class FooterStrip extends StatelessWidget {
  const FooterStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return Container(
      width: double.infinity,
      height: 28,
      color: tokens.brandPrimary,
      alignment: Alignment.center,
      child: VrText(
        'वन हक्क कायदा 2006 | गोपनीयता धोरण • Forest Rights Act 2006 | Privacy',
        style: TextStyle(
          color: tokens.onBrand,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
