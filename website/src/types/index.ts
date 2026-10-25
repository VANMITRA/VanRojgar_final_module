export type Language = 'en' | 'hi' | 'mr';

export type TabId =
  | 'overview'
  | 'ecosystem'
  | 'how_it_works'
  | 'portals'
  | 'marketplace'
  | 'barter'
  | 'delivery'
  | 'impact';

export type PortalType = 'gram_sabha' | 'villager' | 'buyer';

export type ResourceCategory = 'medicinal' | 'forest_produce' | 'handicrafts' | 'water_land' | 'others';

export type ListingMode = 'sell' | 'barter' | 'both';

export type ListingStatus = 'active' | 'paused' | 'sold_out';

export interface GroupContributor {
  id: string;
  name: string;
  village: string;
  quantity: number;
  sharePct: number;
}

export interface Listing {
  id: string;
  /** The code a person pastes into the app's search to find this item (`VR-K7M2QX`). */
  itemCode: string;
  /** `live` = from the marketplace server; `sample` = made-up demo data, always labelled as such. */
  source: 'live' | 'sample';
  title: string;
  category: ResourceCategory;
  quantity: number;
  unit: string;
  pricePerUnit: number;
  fairPriceRange: [number, number];
  mode: ListingMode;
  barterWants?: string;
  gramSabhaId: string;
  gramSabhaName: string;
  village: string;
  district: string;
  distanceKm: number;
  rating: number;
  reviewCount: number;
  isVerified: boolean;
  sourceArea: string;
  collectionMethod: string;
  isSustainable: boolean;
  isGroupListing: boolean;
  groupContributors?: GroupContributor[];
  iconType: 'herbs' | 'honey' | 'bamboo' | 'water' | 'lac' | 'gum' | 'fish' | 'seeds';
  description: string;
  harvestSeason: string;
  status: ListingStatus;
}

export type RequestStatus = 'pending' | 'approved' | 'rejected' | 'countered';

export interface CounterOffer {
  quantity: number;
  pricePerUnit: number;
  note: string;
}

export interface RequestItem {
  id: string;
  listingId: string;
  resourceTitle: string;
  buyerId: string;
  buyerName: string;
  buyerPortal: PortalType;
  buyerVillage?: string;
  sellerGramSabhaId: string;
  sellerGramSabhaName: string;
  requestedQuantity: number;
  unit: string;
  isBarter: boolean;
  offeredResource?: string;
  offeredQuantity?: number;
  reason?: string;
  isLargeOrder: boolean;
  status: RequestStatus;
  counterOffer?: CounterOffer;
  createdAt: string;
}

export type OrderStatus = 'approved' | 'delivery_assigned' | 'in_transit' | 'delivered' | 'closed';

export interface Order {
  id: string;
  requestId: string;
  listingId: string;
  resourceTitle: string;
  buyerName: string;
  sellerName: string;
  sellerGramSabhaId: string;
  quantity: number;
  unit: string;
  totalAmount: number;
  isBarter: boolean;
  barterDetails?: string;
  deliveryType: 'delivery' | 'pickup';
  status: OrderStatus;
  deliveryPartnerId?: string;
  deliveryPartnerName?: string;
  deliveryPartnerPhone?: string;
  deliveryFee?: number;
  createdAt: string;
  handoverConfirmed?: boolean;
  receivedConfirmed?: boolean;
  ratingGiven?: number;
  reviewGiven?: string;
  partnerRatingGiven?: number;
}

export type VehicleType = 'pickup_truck' | 'tempo' | 'bike' | 'tractor';

export type DeliveryPartnerStatus = 'not_registered' | 'pending_review' | 'approved' | 'rejected';

export interface DeliveryPartner {
  id: string;
  name: string;
  phone: string;
  village: string;
  vehicleType: VehicleType;
  vehicleNumber: string;
  carryingCapacityKg: number;
  licenceDetail: string;
  coveredAreas: string;
  status: DeliveryPartnerStatus;
  isAvailable: boolean;
  totalEarnings: number;
  completedJobs: number;
  rating: number;
  rejectReason?: string;
}

export type JobStatus = 'available' | 'accepted' | 'picked_up' | 'in_transit' | 'delivered';

export interface DeliveryJob {
  id: string;
  orderId: string;
  pickupVillage: string;
  dropVillage: string;
  resourceTitle: string;
  weightKg: number;
  distanceKm: number;
  estimatedPay: number;
  status: JobStatus;
  assignedPartnerId?: string;
}
