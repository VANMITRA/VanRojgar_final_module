import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/villages.dart';
import '../l10n/app_strings.dart';
import 'catalog_providers.dart';

/// Extracts the avatar initial from a user's [name], falling back to '?' when blank.
String profileInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.characters.first.toUpperCase();
}

/// Finds the [VillageInfo] in [pilotVillages] for [villageId], or null if not found.
VillageInfo? resolveProfileVillage(String? villageId) {
  if (villageId == null || villageId.trim().isEmpty) return null;
  for (final v in pilotVillages) {
    if (v.id == villageId) return v;
  }
  return null;
}

/// Returns the localized village name for [villageId] in [language], or null if none.
String? resolveProfileVillageLabel(String? villageId, AppLanguage language) {
  if (villageId == null || villageId.trim().isEmpty) return null;
  final info = resolveProfileVillage(villageId);
  if (info != null) return info.label(language);
  return villageId;
}

/// True when [role] is a seller role ('gramsabha' or 'cfrholder').
bool isSellerRole(String? role) => role == 'gramsabha' || role == 'cfrholder';

/// True when [role] is 'cfrholder' (the only role with access to the livelihood report).
bool isCfrHolderRole(String? role) => role == 'cfrholder';

/// Keys of rows shown in the "My activity" section for [user].
/// Empty when guest; ['orders'] for a buyer; ['orders', 'sell'] for a Gram Sabha or CFR holder.
List<String> visibleActivityKeys(AuthUser? user) {
  if (user == null) return const <String>[];
  if (isSellerRole(user.role)) {
    return const <String>['orders', 'sell'];
  }
  return const <String>['orders'];
}

/// Keys of rows shown in the "More" section for [user]:
/// - 'about', 'credits', 'privacy' for everyone
/// - 'livelihood' only for a CFR holder
/// - 'messages', 'barter' only when signed in
/// - 'delivery' for everyone
List<String> visibleMoreKeys(AuthUser? user) {
  return <String>[
    'about',
    'credits',
    'privacy',
    if (user != null && isCfrHolderRole(user.role)) 'livelihood',
    if (user != null) ...['messages', 'barter'],
    'delivery',
  ];
}

/// Tracks whether the sign-out confirmation prompt is open.
final signOutConfirmPendingProvider = StateProvider<bool>((ref) => false);

/// Completes sign-out by clearing [signOutConfirmPendingProvider] and setting [authUserProvider] to null.
void completeSignOut(WidgetRef ref) {
  ref.read(signOutConfirmPendingProvider.notifier).state = false;
  ref.read(authUserProvider.notifier).state = null;
}

