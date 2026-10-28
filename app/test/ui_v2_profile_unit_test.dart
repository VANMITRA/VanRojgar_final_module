import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/profile_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/profile_providers.dart';

void main() {
  group('Profile pure helper functions', () {
    test('profileInitial extracts first character or question mark', () {
      expect(profileInitial('Asha Patil'), 'A');
      expect(profileInitial('  ramesh '), 'R');
      expect(profileInitial('आशा'), 'आ');
      expect(profileInitial(''), '?');
      expect(profileInitial('   '), '?');
    });

    test('resolveProfileVillage and resolveProfileVillageLabel resolve pilot villages', () {
      expect(resolveProfileVillage(null), isNull);
      expect(resolveProfileVillage(''), isNull);
      expect(resolveProfileVillage('unknown_village'), isNull);

      final v = resolveProfileVillage('dongargaon');
      expect(v, isNotNull);
      expect(v!.nameEn, 'Dongargaon');
      expect(v.nameMr, 'डोंगरगाव');

      expect(resolveProfileVillageLabel('dongargaon', AppLanguage.en), 'Dongargaon');
      expect(resolveProfileVillageLabel('dongargaon', AppLanguage.hi), 'डोंगरगाव');
      expect(resolveProfileVillageLabel('dongargaon', AppLanguage.mr), 'डोंगरगाव');
      expect(resolveProfileVillageLabel(null, AppLanguage.en), isNull);
    });

    test('visibleActivityKeys and visibleMoreKeys follow role rules', () {
      const buyer = AuthUser(name: 'B', role: 'buyer', phone: '+919000000001');
      const gs = AuthUser(
        name: 'G',
        role: 'gramsabha',
        phone: '+919000000002',
        villageId: 'dongargaon',
      );
      const cfr = AuthUser(
        name: 'C',
        role: 'cfrholder',
        phone: '+919000000003',
        villageId: 'ambai',
      );

      // Guest
      expect(visibleActivityKeys(null), isEmpty);
      expect(visibleMoreKeys(null), ['about', 'credits', 'privacy', 'delivery']);

      // Buyer
      expect(visibleActivityKeys(buyer), ['orders']);
      expect(
        visibleMoreKeys(buyer),
        ['about', 'credits', 'privacy', 'messages', 'barter', 'delivery'],
      );

      // Gram Sabha
      expect(visibleActivityKeys(gs), ['orders', 'sell']);
      expect(
        visibleMoreKeys(gs),
        ['about', 'credits', 'privacy', 'messages', 'barter', 'delivery'],
      );

      // CFR holder
      expect(visibleActivityKeys(cfr), ['orders', 'sell']);
      expect(
        visibleMoreKeys(cfr),
        ['about', 'credits', 'privacy', 'livelihood', 'messages', 'barter', 'delivery'],
      );
    });

    test('isKnownMoreFeatureKey validates the 4 older feature keys', () {
      for (final key in ['messages', 'barter', 'delivery', 'livelihood']) {
        expect(isKnownMoreFeatureKey(key), isTrue);
      }
      expect(isKnownMoreFeatureKey('xyz'), isFalse);
      expect(isKnownMoreFeatureKey(''), isFalse);
    });
  });

  group('ProfileStrings content and language rules', () {
    test('About has 4 to 6 sentences and Credits / Privacy are populated in all 3 languages', () {
      for (final lang in AppLanguage.values) {
        final s = AppStrings.of(lang);
        expect(s.pfAboutSentences.length, inInclusiveRange(4, 6));
        for (final line in s.pfAboutSentences) {
          expect(line.trim(), isNotEmpty);
        }
        expect(s.pfCreditGroups.length, 3);
        for (final group in s.pfCreditGroups) {
          expect(group.heading.trim(), isNotEmpty);
          expect(group.items, isNotEmpty);
          for (final item in group.items) {
            expect(item.what.trim(), isNotEmpty);
            expect(item.source.trim(), isNotEmpty);
            expect(item.terms.trim(), isNotEmpty);
          }
        }
        expect(s.pfPrivacySections.length, greaterThanOrEqualTo(5));
        for (final section in s.pfPrivacySections) {
          expect(section.heading.trim(), isNotEmpty);
          expect(section.body.trim(), isNotEmpty);
        }
        for (final key in ['messages', 'barter', 'delivery', 'livelihood', 'xyz']) {
          expect(s.pfMorePageTitle(key).trim(), isNotEmpty);
          expect(s.pfMorePageSentences(key), isNotEmpty);
        }
      }
    });

    test('Hindi and Marathi ProfileStrings contain no Latin letters and have draft notices', () {
      final latin = RegExp(r'[A-Za-z]');
      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        final s = AppStrings.of(lang);
        expect(s.pfDraftNotice, isNotEmpty);
        final allTexts = <String>[
          s.pfDraftNotice,
          s.pfAccountSectionTitle,
          s.pfSignOutConfirmTitle,
          s.pfSignOutConfirmBody,
          s.pfCancel,
          s.pfSettingsSectionTitle,
          s.pfAppearanceLabel,
          s.pfMyActivityTitle,
          s.pfMyOrders,
          s.pfSellOnVanMitra,
          s.pfMoreSectionTitle,
          s.pfAboutTitle,
          s.pfCreditsTitle,
          s.pfPrivacyTitle,
          s.pfMoreLivelihoodTitle,
          s.pfMoreMessagesTitle,
          s.pfMoreBarterTitle,
          s.pfMoreDeliveryTitle,
          s.pfDemoVersion,
          s.pfOpensInFullApp,
          s.pfUnknownMoreTitle,
          s.pfUnknownMoreBody,
          s.pfCreditsSourceLabel,
          s.pfCreditsTermsLabel,
          ...s.pfAboutSentences,
          for (final g in s.pfCreditGroups) ...[
            g.heading,
            for (final item in g.items) ...[item.what, item.source, item.terms],
          ],
          for (final sec in s.pfPrivacySections) ...[sec.heading, sec.body],
          for (final k in ['messages', 'barter', 'delivery', 'livelihood', 'xyz']) ...[
            s.pfMorePageTitle(k),
            ...s.pfMorePageSentences(k),
          ],
        ];
        for (final text in allTexts) {
          expect(latin.hasMatch(text), isFalse, reason: '$lang had Latin in: $text');
        }
      }
    });

    test('English strings contain no prohibited claims or URLs', () {
      const s = AppStrings.en;
      final forbidden = RegExp(
        r'\b(verified|organic|free|fast|guaranteed|http://|https://)\b',
        caseSensitive: false,
      );
      final allEn = <String>[
        ...s.pfAboutSentences,
        for (final g in s.pfCreditGroups)
          for (final item in g.items) ...[item.what, item.source, item.terms],
        for (final sec in s.pfPrivacySections) ...[sec.heading, sec.body],
        for (final k in ['messages', 'barter', 'delivery', 'livelihood']) ...s.pfMorePageSentences(k),
      ];
      for (final text in allEn) {
        expect(forbidden.hasMatch(text), isFalse, reason: 'Forbidden word in: $text');
      }
    });
  });
}

