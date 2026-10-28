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
