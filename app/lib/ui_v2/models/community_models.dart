import '../l10n/app_strings.dart';

/// A delivery partner's own profile (`GET /delivery-partners/me`).
/// [approvalStatus]: pending, approved, rejected, paused (a team member approves).
class DeliveryPartnerProfile {
  final String approvalStatus;
  final String vehicleType; // bike | tempo | pickup | tractor
  final String vehicleNumber;
  final int capacityKg;
  final List<String> serviceTalukas;
  final bool available;
  final int earningsPaise;
  final int jobsCompleted;
  final String? reviewNote;

  const DeliveryPartnerProfile({
    required this.approvalStatus,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.capacityKg,
    required this.serviceTalukas,
    required this.available,
    required this.earningsPaise,
    required this.jobsCompleted,
    this.reviewNote,
  });

  bool get isApproved => approvalStatus == 'approved';
}

/// What a CFR holder fills in to apply as a delivery partner (`POST /delivery-partners/applications`).
class DeliveryApplication {
  final String vehicleType; // bike | tempo | pickup | tractor
  final String vehicleNumber;
  final int capacityKg;
  final String licenceNumber;
  final List<String> serviceTalukas;

  const DeliveryApplication({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.capacityKg,
    required this.licenceNumber,
    required this.serviceTalukas,
  });
}

/// One step in a delivery job's history.
class DeliveryStep {
  final String status;
  final DateTime at;
  final String? note;

  const DeliveryStep({required this.status, required this.at, this.note});
}

/// A delivery job. [status]: available, accepted, picked_up, on_the_way, delivered, cancelled.
class DeliveryJob {
  final String id;
  final String pickupVillage;
  final String pickupTaluka;
  final String dropVillage;
  final String dropTaluka;
  final String goodsSummary;
  final double weightKg;
  final double distanceKm;
  final int feePaise;

  /// Cash the partner collects from the buyer (cash on delivery); 0 = nothing to collect.
  final int collectCashPaise;
  final bool cashCollected;
  final String status;
  final List<DeliveryStep> timeline;

  const DeliveryJob({
    required this.id,
    required this.pickupVillage,
    required this.pickupTaluka,
    required this.dropVillage,
    required this.dropTaluka,
    required this.goodsSummary,
    required this.weightKg,
    required this.distanceKm,
    required this.feePaise,
    this.collectCashPaise = 0,
    this.cashCollected = false,
    required this.status,
    this.timeline = const [],
  });
}

/// A notice the server writes for the signed-in user (a request arrived, was approved, ...).
/// The server has Marathi and English text only; Hindi shows the English text.
class AppMessage {
  final String id;
  final String type;
  final Map<String, String> title;
  final Map<String, String> body;
  final String? orderId;
  final String? requestId;
  final String? barterId;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.orderId,
    this.requestId,
    this.barterId,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  String _pick(Map<String, String> m, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.mr:
        return m['mr'] ?? m['en'] ?? '';
      case AppLanguage.hi:
      case AppLanguage.en:
        return m['en'] ?? m['mr'] ?? '';
    }
  }

  String localizedTitle(AppLanguage lang) => _pick(title, lang);
  String localizedBody(AppLanguage lang) => _pick(body, lang);
}

/// One side's proposal inside a barter offer.
class BarterVersion {
  final int version;
  final String offeredTitle;
  final int offeredQuantity;
  final String offeredUnit;
  final int wantedQuantity;
  final String? note;
  final DateTime at;

  const BarterVersion({
    required this.version,
    required this.offeredTitle,
    required this.offeredQuantity,
    required this.offeredUnit,
    required this.wantedQuantity,
    this.note,
    required this.at,
  });
}

/// A barter offer: "I give [offered], I want [wanted] of your listing". [status]: pending, accepted, rejected, countered.
class BarterOffer {
  final String id;
  final String status;

  /// The listing that is wanted, with a title the screens can show (may be empty if unknown).
  final String wantedListingId;
  final String wantedTitle;
  final String wantedUnit;
  final String offeredTitle;
  final int offeredQuantity;
  final String offeredUnit;
  final int wantedQuantity;
  final String? note;

  /// True when the signed-in user is the one who OWNS the wanted listing (the offer came in).
  final bool isIncoming;
  final String otherPartyName;
  final List<BarterVersion> versions;
  final DateTime createdAt;

  const BarterOffer({
    required this.id,
    required this.status,
    required this.wantedListingId,
    this.wantedTitle = '',
    this.wantedUnit = '',
    required this.offeredTitle,
    required this.offeredQuantity,
    required this.offeredUnit,
    required this.wantedQuantity,
    this.note,
    required this.isIncoming,
    this.otherPartyName = '',
    this.versions = const [],
    required this.createdAt,
  });
}

/// What a user types to make a barter offer (`POST /barter-requests`).
class NewBarterOffer {
  final String wantedListingId;
  final String offeredTitle;
  final int offeredQuantity;
  final String offeredUnit;
  final int wantedQuantity;
  final String? note;

  const NewBarterOffer({
    required this.wantedListingId,
    required this.offeredTitle,
    required this.offeredQuantity,
    required this.offeredUnit,
    required this.wantedQuantity,
    this.note,
  });
}
