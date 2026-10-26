import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/vr_text.dart';

/// One titled block of the About screen: a heading and plain lines (English and Marathi side by side).
class AboutSection {
  final String title;
  final List<String> lines;
  const AboutSection(this.title, this.lines);
}

/// Credits, data sources and privacy, in plain words. Mirrors CREDITS.md and docs/PRIVACY.md.
/// A DRAFT for the team to read and confirm before the judges see it.
const List<AboutSection> aboutSections = [
  AboutSection('Credits • श्रेय', [
    'Livelihood report and map: Soham.',
    'Marketplace (trade, barter, delivery): Ayush More.',
    'Website: Kaushal.',
    'Design system and the Gram Sabha work this app grew from: the VanMitra team.',
  ]),
  AboutSection('Data we use • आम्ही वापरत असलेला डेटा', [
    'The 14 villages and their forest restoration figures: Raah Foundation report, 1 October 2026.',
    'Map: © OpenStreetMap contributors (ODbL). Resource pins are patchy in rural areas and are marked low confidence.',
    'Typical monthly rain and temperature: Open-Meteo.com (CC BY 4.0). Typical values, not a forecast.',
    'Scheme links go only to the official websites. No amounts, no applications.',
  ]),
  AboutSection('Honest limits • मर्यादा', [
    'The idea library is a draft and has not been reviewed by an expert.',
    'Scheme rows have not been checked by a named person yet.',
    'Marathi and Hindi text are machine-written drafts and have not been read by a native speaker.',
    'The report suggests; you decide. For community forest, the Gram Sabha decides.',
  ]),
  AboutSection('Your privacy • तुमची गोपनीयता', [
    'We keep your name, phone number, village, role and language. Your 6-digit PIN is stored only as a one-way hash, never as the PIN itself.',
    'CFR holders: the details you give for the livelihood report (land size, water, animals, tools, plot position) are kept on our livelihood server and shown only to you.',
    'Listings are public. Their position is rounded to about 1 km. Your phone number is never shown on a listing.',
    'Your phone location is used only if you allow it, to place your plot. You can type a position instead.',
    'No advertising and no analytics are in this app. Map pictures come from OpenStreetMap, which can see your network address when tiles load.',
    'To have your account and report deleted, contact the VanRozgar team.',
  ]),
];

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    return Scaffold(
      appBar: AppBar(title: const VrText('माहिती व गोपनीयता • About & Privacy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final section in aboutSections) ...[
              VrText(
                section.title,
                style: TextStyle(color: tokens.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (final line in section.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6, right: 10),
                        child: Icon(Icons.circle, size: 6, color: tokens.brandSecondary),
                      ),
                      Expanded(
                        child: VrText(line, style: TextStyle(color: tokens.textMuted, fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
