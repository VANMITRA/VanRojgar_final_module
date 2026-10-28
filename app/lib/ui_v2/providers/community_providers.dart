import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/community_repositories.dart';
import '../data/live_community_repositories.dart';
import '../models/community_models.dart';
import 'catalog_providers.dart' show shopApiClientProvider;

export '../data/community_repositories.dart';

/// Until the live servers are connected (and in tests that do not override them) these repositories say
/// that nothing is available. The screens show their "nothing here yet" state, never made-up data.
class _EmptyDelivery implements DeliveryRepository {
  const _EmptyDelivery();
  @override
  Future<DeliveryPartnerProfile?> myProfile() async => null;
  @override
  Future<void> apply(DeliveryApplication application) async => throw StateError('Delivery is not connected');
  @override
  Future<void> setAvailable(bool available) async => throw StateError('Delivery is not connected');
  @override
  Future<List<DeliveryJob>> openJobs() async => const [];
  @override
  Future<void> acceptJob(String jobId) async => throw StateError('Delivery is not connected');
  @override
  Future<void> updateJobStatus(String jobId, String status, {String? note}) async =>
      throw StateError('Delivery is not connected');
  @override
  Future<List<DeliveryJob>> myJobs() async => const [];
}

class _EmptyMessages implements MessagesRepository {
  const _EmptyMessages();
  @override
  Future<List<AppMessage>> messages() async => const [];
  @override
  Future<int> unreadCount() async => 0;
  @override
  Future<void> markRead(List<String> messageIds) async {}
}

class _EmptyBarter implements BarterRepository {
  const _EmptyBarter();
  @override
  Future<List<BarterOffer>> offers({required bool incoming}) async => const [];
  @override
  Future<void> create(NewBarterOffer offer) async => throw StateError('Barter is not connected');
  @override
  Future<void> respond(String offerId, String action,
          {String? counterOfferedTitle, int? counterOfferedQuantity, int? counterWantedQuantity, String? note}) async =>
      throw StateError('Barter is not connected');
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final api = ref.watch(shopApiClientProvider);
  return api == null ? const _EmptyDelivery() : LiveDeliveryRepository(api);
});
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final api = ref.watch(shopApiClientProvider);
  return api == null ? const _EmptyMessages() : LiveMessagesRepository(api);
});
final barterRepositoryProvider = Provider<BarterRepository>((ref) {
  final api = ref.watch(shopApiClientProvider);
  return api == null ? const _EmptyBarter() : LiveBarterRepository(api);
});

/// The signed-in user's delivery partner profile (null = never applied). Invalidate it after applying or changing availability.
final deliveryProfileProvider = FutureProvider.autoDispose<DeliveryPartnerProfile?>(
  (ref) => ref.watch(deliveryRepositoryProvider).myProfile(),
);

final deliveryOpenJobsProvider = FutureProvider.autoDispose<List<DeliveryJob>>(
  (ref) => ref.watch(deliveryRepositoryProvider).openJobs(),
);

final deliveryMyJobsProvider = FutureProvider.autoDispose<List<DeliveryJob>>(
  (ref) => ref.watch(deliveryRepositoryProvider).myJobs(),
);

final messagesProvider = FutureProvider.autoDispose<List<AppMessage>>(
  (ref) => ref.watch(messagesRepositoryProvider).messages(),
);

final unreadMessagesProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(messagesRepositoryProvider).unreadCount(),
);

/// Barter offers made TO my listings.
final incomingBarterProvider = FutureProvider.autoDispose<List<BarterOffer>>(
  (ref) => ref.watch(barterRepositoryProvider).offers(incoming: true),
);

/// Barter offers I made.
final outgoingBarterProvider = FutureProvider.autoDispose<List<BarterOffer>>(
  (ref) => ref.watch(barterRepositoryProvider).offers(incoming: false),
);
