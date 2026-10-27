import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_providers.dart';

final _devanagari = RegExp(r'[ऀ-ॿ]');

/// Picks the Marathi or English half of a bilingual label such as
/// "मराठी • English", "मराठी | English" or "मराठी (English)" for [lang].
/// Strings without a clean Marathi/English pair are returned unchanged.
String bi(String s, String lang) {
  for (final sep in [' • ', ' | ']) {
    final i = s.indexOf(sep);
    if (i > 0) {
      final r = _pick(s.substring(0, i), s.substring(i + sep.length), lang);
      if (r != null) return r;
    }
  }
  final m = RegExp(r'^(.*?)\s*\(([^()]*)\)\s*(\S*)$').firstMatch(s);
  if (m != null && m.group(3)!.isEmpty) {
    final r = _pick(m.group(1)!, m.group(2)!, lang);
    if (r != null) return r;
  }
  return s;
}

String? _pick(String a, String b, String lang) {
  final aMr = _devanagari.hasMatch(a), bMr = _devanagari.hasMatch(b);
  if (aMr == bMr) return null;
  final mr = aMr ? a : b, en = aMr ? b : a;
  return lang == 'en' ? en.trim() : mr.trim();
}

/// The text for the active language: English, Hindi or Marathi. Hindi and Marathi are drafts until a native reader checks them.
String tr3(String lang, {required String en, required String hi, required String mr}) =>
    lang == 'hi' ? hi : (lang == 'mr' ? mr : en);

/// Drop-in replacement for [Text] that follows the app language.
class VrText extends ConsumerWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const VrText(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(activeLocaleProvider);
    return Text(bi(data, lang), style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow, softWrap: softWrap);
  }
}
