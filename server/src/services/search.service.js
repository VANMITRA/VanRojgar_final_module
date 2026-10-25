import { Listing } from '../models/Listing.js';
import { GramSabha } from '../models/GramSabha.js';
import { Resource } from '../models/Resource.js';
import { Category } from '../models/Category.js';
import { normaliseString } from '../core/normalise.js';
import { normaliseItemCode } from '../core/itemCode.js';
import { serializeListing, serializeGramSabha } from '../core/serializers.js';

function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

const MAX_MATCHES = 500;

/** Sorts serialized listings. Unknown distances always go last for "nearest". */
export function sortListings(list, sort, hasCoord) {
  const out = [...list];
  const byNewest = (a, b) => new Date(b.createdAt) - new Date(a.createdAt);
  if (sort === 'nearest' && hasCoord) {
    out.sort((a, b) => {
      if (a.distanceKm === null && b.distanceKm === null) return byNewest(a, b);
      if (a.distanceKm === null) return 1;
      if (b.distanceKm === null) return -1;
      return a.distanceKm - b.distanceKm || byNewest(a, b);
    });
  } else if (sort === 'price_asc') {
    out.sort((a, b) => a.pricePerUnitPaise - b.pricePerUnitPaise || byNewest(a, b));
  } else if (sort === 'price_desc') {
    out.sort((a, b) => b.pricePerUnitPaise - a.pricePerUnitPaise || byNewest(a, b));
  } else if (sort === 'rating_desc') {
    out.sort((a, b) => (b.ratingAvg || 0) - (a.ratingAvg || 0) || byNewest(a, b));
  } else {
    out.sort(byNewest);
  }
  return out;
}

/** The cursor is an offset into the sorted result; null means no more pages. */
export function pageOf(list, cursor, limit) {
  const size = Number(limit);
  const offset = Math.max(0, parseInt(cursor, 10) || 0);
  const items = list.slice(offset, offset + size);
  return { items, nextCursor: list.length > offset + size ? String(offset + size) : null };
}

export class SearchService {
  /**
   * Calculates Haversine distance in km between two [lng, lat] points
   */
  static calculateDistance(coord1, coord2) {
    if (!coord1 || !coord2 || coord1.length < 2 || coord2.length < 2) return null;
    const [lon1, lat1] = coord1;
    const [lon2, lat2] = coord2;
    const R = 6371; // km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c * 10) / 10;
  }

  static async globalSearch({ q, category, minPrice, maxPrice, minQty, taluka, district, mode, verifiedOnly, lat, lng, radiusKm, sort = 'newest', limit = 20, cursor }) {
    const normQ = normaliseString(q);
    // An item code (from the website, any spelling) finds exactly that listing, so the words are not searched
    const itemCode = normaliseItemCode(q);
    const tokens = !itemCode && normQ ? normQ.split(' ').filter(Boolean) : [];

    // Build listings filter
    const listingFilter = { status: 'active' };
    if (itemCode) listingFilter.itemCode = itemCode;

    if (tokens.length > 0) {
      listingFilter.searchTerms = {
        $in: tokens.map(t => new RegExp(`^${escapeRegex(t)}`, 'i'))
      };
    }

    if (category) {
      const isObjectId = /^[0-9a-fA-F]{24}$/.test(category);
      const cat = await Category.findOne(isObjectId ? { _id: category } : { slug: category });
      if (cat) {
        listingFilter.categoryId = cat._id;
      }
    }

    if (minPrice !== undefined || maxPrice !== undefined) {
      listingFilter.pricePerUnitPaise = {};
      if (minPrice !== undefined) listingFilter.pricePerUnitPaise.$gte = Math.round(minPrice * 100);
      if (maxPrice !== undefined) listingFilter.pricePerUnitPaise.$lte = Math.round(maxPrice * 100);
    }

    if (minQty !== undefined) {
      listingFilter.quantityAvailable = { $gte: Number(minQty) };
    }

    if (taluka) listingFilter.taluka = taluka;
    if (district) listingFilter.district = district;
    if (mode) listingFilter.mode = mode;

    if (verifiedOnly) {
      const ids = await GramSabha.find({ verificationStatus: { $in: ['verified', 'verified_seed'] } }).distinct('_id');
      listingFilter.gramSabhaId = { $in: ids };
    }

    // The pilot data set is small, so filter in the database, then sort and page the whole match in memory.
    // This keeps "nearest" and the cursor correct (the cursor is an offset into the sorted result).
    const listings = await Listing.find(listingFilter)
      .populate('gramSabhaId')
      .populate('categoryId')
      .sort({ createdAt: -1, _id: -1 })
      .limit(MAX_MATCHES);

    // Compute distance and sort
    const userCoord = (lng !== undefined && lat !== undefined) ? [Number(lng), Number(lat)] : null;

    let processedListings = listings.map(l => {
      const serialized = serializeListing(l);
      let distanceKm = null;
      if (userCoord && l.location && l.location.coordinates) {
        distanceKm = this.calculateDistance(userCoord, l.location.coordinates);
      }
      return {
        ...serialized,
        distanceKm,
        gramSabha: l.gramSabhaId ? serializeGramSabha(l.gramSabhaId) : null
      };
    });

    if (radiusKm && userCoord) {
      processedListings = processedListings.filter(l => l.distanceKm !== null && l.distanceKm <= Number(radiusKm));
    }

    processedListings = sortListings(processedListings, sort, Boolean(userCoord));
    const { items, nextCursor } = pageOf(processedListings, cursor, limit);
    processedListings = items;

    // Also search Gram Sabhas
    const gsFilter = {};
    if (tokens.length > 0) {
      gsFilter.searchTerms = { $in: tokens.map(t => new RegExp(`^${escapeRegex(t)}`, 'i')) };
    }
    if (taluka) gsFilter.taluka = taluka;
    const gramsabhas = itemCode ? [] : await GramSabha.find(gsFilter).limit(5);

    // Also search Resources
    const resFilter = {};
    if (tokens.length > 0) {
      resFilter.searchTerms = { $in: tokens.map(t => new RegExp(`^${escapeRegex(t)}`, 'i')) };
    }
    const resources = itemCode ? [] : await Resource.find(resFilter).populate('categoryId').limit(5);

    // Suggestions if empty
    let suggestions = [];
    if (processedListings.length === 0) {
      suggestions = await Category.find().limit(4);
    }

    return {
      listings: processedListings,
      nextCursor,
      gramsabhas: gramsabhas.map(serializeGramSabha),
      resources,
      suggestions: suggestions.length > 0 ? suggestions : undefined
    };
  }
}
