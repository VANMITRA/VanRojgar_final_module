import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/livelihood_strings.dart';
import 'package:vanrozgar/features/livelihood/livelihood_strings_extra.dart';
import 'package:vanrozgar/features/livelihood/livelihood_strings_hi.dart';

final _placeholder = RegExp(r'\{(\w+)\}');
final _devanagari = RegExp(r'[ऀ-ॿ]');

Set<String> _placeholders(String text) => _placeholder.allMatches(text).map((m) => m.group(1)!).toSet();

/// The English keys, read from the source file (the table itself is private to the library).
Set<String> _englishKeys() {
  final src = File('lib/features/livelihood/livelihood_strings.dart').readAsStringSync().replaceAll('\r\n', '\n');
  final start = src.indexOf("  'en': {") + 9; // skip the table's own name
  final end = src.indexOf("  'mr': {");
  // a key is a quoted name followed by a colon at the start of a line or after a comma (two keys can share a line)
  return RegExp(r"(?:^|,)\s*'([A-Za-z0-9_.]+)':", multiLine: true)
      .allMatches(src.substring(start, end))
      .map((m) => m.group(1)!)
      .toSet();
}

void main() {
  const en = LivelihoodStrings('en');
  const mr = LivelihoodStrings('mr');
  const hi = LivelihoodStrings('hi');
  final keys = _englishKeys();

  test('the English table was read (a sanity check on the test itself)', () {
    expect(keys.length, greaterThan(300));
    expect(keys, contains('lv_title'));
  });

  test('Hindi has exactly the keys English has: nothing missing, nothing left over', () {
    expect(keys.difference(hindiText.keys.toSet()), isEmpty, reason: 'English keys with no Hindi');
    expect(hindiText.keys.toSet().difference(keys), isEmpty, reason: 'Hindi keys that English does not have');
  });

  test('every Hindi string keeps the same placeholders as English', () {
    for (final key in keys) {
      expect(_placeholders(hi.t(key)), _placeholders(en.t(key)), reason: key);
    }
  });

  test('every Marathi string keeps the same placeholders as English', () {
    for (final key in keys) {
      expect(_placeholders(mr.t(key)), _placeholders(en.t(key)), reason: key);
    }
  });

  test('Hindi is really Hindi: Devanagari everywhere except a few names that stay in Latin letters', () {
    const latinOk = {'sch.tab_ngo'};
    for (final key in keys) {
      if (latinOk.contains(key)) continue;
      expect(_devanagari.hasMatch(hindiText[key]!), isTrue, reason: '$key = ${hindiText[key]}');
    }
  });

  test('Hindi never falls back to English for a screen string', () {
    const sameInBoth = {'sch.tab_ngo'}; // "NGO" is written the same way in every language
    for (final key in keys.difference(sameInBoth)) {
      expect(hi.t(key), isNot(en.t(key)), reason: '$key is still English in Hindi');
    }
  });

  test('the marketplace, map and PDF strings exist in all three languages with the same placeholders', () {
    final base = extraText['en']!;
    for (final lang in ['mr', 'hi']) {
      expect(extraText[lang]!.keys.toSet(), base.keys.toSet(), reason: '$lang keys');
      for (final key in base.keys) {
        expect(_placeholders(extraText[lang]![key]!), _placeholders(base[key]!), reason: '$lang $key');
        expect(_devanagari.hasMatch(extraText[lang]![key]!), isTrue, reason: '$lang $key');
      }
    }
  });

  test('a key that does not exist is shown as the key, never as a blank', () {
    expect(hi.t('no.such.key'), 'no.such.key');
  });

  test('parameters are filled in Hindi', () {
    expect(hi.t('lv_step_of', {'n': 2, 'total': 5}), 'चरण 2 / 5');
    expect(hi.t('lv_report_for', {'name': 'रमेश'}), 'रमेश के लिए');
  });
}
