import { Listing, ResourceCategory } from '../types';
import { calculateFairPriceRange } from '../utils/marketplace';
import { normaliseItemCode } from '../utils/itemCode';

/** What the marketplace server (`GET /api/v1/search`) returns for one listing; only the fields used here. */
export interface ServerListing {
  _id?: string;
  itemCode?: string | null;
  title?: { mr?: string; en?: string; hi?: string };
  description?: string;
  categoryId?: { slug?: string } | string | null;
  productCode?: string | null;
  quantityAvailable?: number;
  unit?: string;
  pricePerUnitPaise?: number;
  mode?: string;
  barterWants?: string;
  village?: string;
  taluka?: string;
  district?: string;
  status?: string;
  distanceKm?: number | null;
  ratingAvg?: number;
  ratingCount?: number;
  provenance?: { sourceForestArea?: string; collectionNote?: string; sustainableDeclared?: boolean };
  gramSabha?: { _id?: string; village?: { mr?: string; en?: string }; verificationStatus?: string } | null;
  gramSabhaId?: string | { _id?: string; village?: { mr?: string; en?: string }; verificationStatus?: string };
}

const CATEGORY_BY_SLUG: Record<string, ResourceCategory> = {
  'medicinal-plants': 'medicinal',
  'forest-produce': 'forest_produce',
  'handicrafts-bamboo': 'handicrafts',
  'water-land-resources': 'water_land',
};

const ICON_BY_PRODUCT: Record<string, Listing['iconType']> = {
  honey: 'honey',
  bamboo: 'bamboo',
  herb: 'herbs',
  seed: 'seeds',
  preserve: 'honey',
  'dried-fruit': 'seeds',
  'leaf-plate': 'bamboo',
  fibre: 'bamboo',
};

const MODES = ['sell', 'barter', 'both'] as const;

/**
 * One server listing as a website listing, or null when it has no valid item code (a listing the app could
 * not find by code is of no use here). Fields the server does not have stay honest: no invented rating,
 * no invented distance, and the fair-price range is only a band around the asking price.
 */
export function mapServerListing(raw: ServerListing): Listing | null {
  const itemCode = normaliseItemCode(raw.itemCode);
  if (!itemCode) return null;
  const gs = raw.gramSabha ?? (typeof raw.gramSabhaId === 'object' ? raw.gramSabhaId : null);
  const slug = typeof raw.categoryId === 'object' && raw.categoryId ? raw.categoryId.slug ?? '' : '';
  const title = raw.title?.en || raw.title?.mr || raw.title?.hi || 'Forest produce';
  const price = Math.round((raw.pricePerUnitPaise ?? 0) / 100);
  const village = raw.village || gs?.village?.mr || gs?.village?.en || '';
  const mode = MODES.find((m) => m === raw.mode) ?? 'sell';
  const id = String(raw._id ?? itemCode);
  return {
    id,
    itemCode,
    source: 'live',
    title: raw.title?.mr && raw.title.en ? `${raw.title.en} (${raw.title.mr})` : title,
    category: CATEGORY_BY_SLUG[slug] ?? 'others',
    quantity: raw.quantityAvailable ?? 0,
    unit: raw.unit ?? 'kg',
    pricePerUnit: price,
    fairPriceRange: calculateFairPriceRange(price),
    mode,
    barterWants: raw.barterWants,
    gramSabhaId: typeof raw.gramSabhaId === 'string' ? raw.gramSabhaId : gs?._id ?? '',
    gramSabhaName: village ? `Gram Sabha ${village}` : 'Gram Sabha',
    village,
    district: raw.district || 'Nashik',
    distanceKm: raw.distanceKm ?? 0,
    rating: raw.ratingAvg ?? 0,
    reviewCount: raw.ratingCount ?? 0,
    isVerified: ['verified', 'verified_seed'].includes(gs?.verificationStatus ?? ''),
    sourceArea: raw.provenance?.sourceForestArea ?? '',
    collectionMethod: raw.provenance?.collectionNote ?? '',
    isSustainable: raw.provenance?.sustainableDeclared ?? true,
    isGroupListing: false,
    iconType: ICON_BY_PRODUCT[raw.productCode ?? ''] ?? 'herbs',
    description: raw.description ?? '',
    harvestSeason: '',
    status: raw.status === 'paused' || raw.status === 'sold_out' ? raw.status : 'active',
  };
}

/** The marketplace's live listings, or null when the server is not set up or not reachable (callers then show Sample). */
export async function fetchLiveListings(
  apiUrl: string,
  fetchImpl: typeof fetch = fetch,
): Promise<Listing[] | null> {
  if (!apiUrl) return null;
  try {
    const res = await fetchImpl(`${apiUrl}/api/v1/search?limit=50`, { headers: { Accept: 'application/json' } });
    if (!res.ok) return null;
    const body = (await res.json()) as { data?: { listings?: ServerListing[] } };
    const rows = body?.data?.listings;
    if (!Array.isArray(rows)) return null;
    return rows.map(mapServerListing).filter((l): l is Listing => l !== null);
  } catch {
    return null;
  }
}
