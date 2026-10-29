import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/live_listings_repository.dart';
import '../data/sell_catalog.dart';
import '../l10n/app_strings.dart';
import '../l10n/live_strings.dart';
import '../models/catalog_models.dart';
import '../models/sell_models.dart';
import 'catalog_providers.dart';
import 'live_feedback.dart';
import 'sell_providers.dart';

/// The seller's listings on the shop server; null when no server address was given.
final listingsRepositoryProvider = Provider<LiveListingsRepository?>((ref) {
  final api = ref.watch(shopApiClientProvider);
  return api == null ? null : LiveListingsRepository(api);
});

/// True once the seller has ticked "I confirm this produce was collected sustainably" on the Sell form.
/// The server refuses a new listing without it. The form clears it after publishing.
final sellSustainableDeclaredProvider = StateProvider<bool>((ref) => false);

/// Keeps the Sell screens in step with the server. A screen that shows or changes the seller's listings
/// watches this provider once (`ref.watch(liveSellSyncProvider);`). It loads the listings from the server,
/// and when the screen adds, changes, pauses or removes one in [myListingsProvider] it sends that to the server.
/// If the server refuses, the list goes back to how it was and a message is shown. Without a server it does nothing.
final liveSellSyncProvider = Provider.autoDispose<void>((ref) {
  final repo = ref.watch(listingsRepositoryProvider);
  if (repo == null) return;
  final strings = AppStrings.of(ref.read(uiV2LanguageProvider));
  final notifier = ref.read(myListingsProvider.notifier);
  var applying = false;

  void setList(List<MyListing> list) {
    applying = true;
    notifier.state = list;
    applying = false;
  }

  Future<void> load() async {
    try {
      setList(await repo.mine());
    } catch (e) {
      showLiveMessage(strings.lvErrorText(e));
    }
  }

  Future<void> push(List<MyListing> before, List<MyListing> after) async {
    final beforeById = {for (final l in before) l.id: l};
    final afterById = {for (final l in after) l.id: l};
    try {
      // taken down: the server has no delete, so the listing is paused there
      for (final old in before) {
        if (!afterById.containsKey(old.id) && !old.id.startsWith('my-')) await repo.pause(old.id);
      }
      for (final item in after) {
        final old = beforeById[item.id];
        if (old == null) {
          final catalog = await ref.read(sellCatalogProvider.future);
          final product = catalog.cast<ShopProduct?>().firstWhere((p) => p!.productCode == item.productCode, orElse: () => null);
          if (product == null) throw StateError('Unknown product ${item.productCode}');
          final created = await repo.create(
            product: product,
            quantity: item.quantityTotal,
            mrpPaise: item.mrpPaise,
            pricePaise: item.pricePaise,
            minOrderQuantity: item.minOrderQuantity,
            fulfilment: item.fulfilment,
            sustainableDeclared: ref.read(sellSustainableDeclaredProvider),
          );
          ref.read(sellSustainableDeclaredProvider.notifier).state = false;
          setList([for (final l in notifier.state) if (l.id == item.id) created else l]);
        } else if (old.status != item.status) {
          if (item.status == 'active') {
            await repo.resume(item.id);
          } else {
            await repo.pause(item.id);
          }
        } else if (old.quantityTotal != item.quantityTotal ||
            old.mrpPaise != item.mrpPaise ||
            old.pricePaise != item.pricePaise ||
            old.minOrderQuantity != item.minOrderQuantity ||
            old.fulfilment != item.fulfilment) {
          await repo.update(
            item.id,
            quantityAvailable: item.quantityTotal - item.quantitySold,
            mrpPaise: item.mrpPaise,
            pricePaise: item.pricePaise,
            minOrderQuantity: item.minOrderQuantity,
            fulfilment: item.fulfilment,
          );
        }
      }
    } catch (e) {
      setList(before);
      showLiveMessage(strings.lvErrorText(e));
    }
  }

  ref.listen<List<MyListing>>(myListingsProvider, (previous, next) {
    if (applying || previous == null) return;
    unawaited(push(previous, next));
  });

  Future.microtask(load);
});
