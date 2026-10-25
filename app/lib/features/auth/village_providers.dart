import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/gram_sabha.dart';
import 'auth_providers.dart';

/// Every village of one taluka, from the server (the CFR register plus the demo villages), sorted by name.
/// A village name is listed once even if the register has it under two census codes.
final talukaVillagesProvider = FutureProvider.family<List<GramSabhaModel>, String>((ref, taluka) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/gramsabhas', queryParameters: {'taluka': taluka, 'limit': 500});
  final seen = <String>{};
  final villages = <GramSabhaModel>[];
  for (final e in (res as List)) {
    final gs = GramSabhaModel.fromJson(Map<String, dynamic>.from(e as Map));
    if (gs.villageMr.isNotEmpty && seen.add(gs.villageMr)) villages.add(gs);
  }
  villages.sort((a, b) => a.villageMr.compareTo(b.villageMr));
  return villages;
});
