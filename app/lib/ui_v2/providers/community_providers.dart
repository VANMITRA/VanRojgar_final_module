import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_models.dart';

/// Delivery partner data (`/delivery-partners`, `/deliveries`).
abstract class DeliveryRepository {
  /// The signed-in user's partner profile, or null when they have not applied.
  Future<DeliveryPartnerProfile?> myProfile();
  Future<void> apply(DeliveryApplication application);
  Future<void> setAvailable(bool available);

  /// Open jobs an approved partner can take.
  Future<List<DeliveryJob>> openJobs();
  Future<void> acceptJob(String jobId);

  /// [status]: picked_up, on_the_way or delivered.
  Future<void> updateJobStatus(String jobId, String status, {String? note});

  /// The jobs this partner has taken.
  Future<List<DeliveryJob>> myJobs();
}

/// Notices from the server (`/messages`).
abstract class MessagesRepository {
  Future<List<AppMessage>> messages();
  Future<int> unreadCount();
  Future<void> markRead(List<String> messageIds);
}

/// Barter offers (`/barter-requests`).
abstract class BarterRepository {
  /// [incoming] true = offers made to my listings, false = offers I made.
  Future<List<BarterOffer>> offers({required bool incoming});
  Future<void> create(NewBarterOffer offer);

  /// [action]: accept, reject or counter. A counter gives a new offered title/quantity and/or wanted quantity.
  Future<void> respond(
    String offerId,
    String action, {
    String? counterOfferedTitle,
    int? counterOfferedQuantity,
    int? counterWantedQuantity,
    String? note,
  });
}

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

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) => const _EmptyDelivery());
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) => const _EmptyMessages());
final barterRepositoryProvider = Provider<BarterRepository>((ref) => const _EmptyBarter());

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
