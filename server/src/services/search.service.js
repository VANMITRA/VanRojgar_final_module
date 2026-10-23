import { Listing } from '../models/Listing.js';
import { GramSabha } from '../models/GramSabha.js';
import { Resource } from '../models/Resource.js';
import { Category } from '../models/Category.js';
import { normaliseString } from '../core/normalise.js';
import { serializeListing, serializeGramSabha } from '../core/serializers.js';

function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
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
    const tokens = normQ ? normQ.split(' ').filter(Boolean) : [];

    // Build listings filter
    const listingFilter = { status: 'active' };

    if (tokens.length > 0) {
      listingFilter.searchTerms = {
        $in: tokens.map(t => new RegExp(`^${escapeRegex(t)}`, 'i'))
      };
    }

    if (cursor) {
      listingFilter._id = { $lt: cursor };
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

    let listings = await Listing.find(listingFilter)
      .populate('gramSabhaId')
      .populate('categoryId')
      .limit(Number(limit) * 2);

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

    if (verifiedOnly) {
      processedListings = processedListings.filter(l => l.gramSabha && ['verified', 'verified_seed'].includes(l.gramSabha.verificationStatus));
    }

    if (radiusKm && userCoord) {
      processedListings = processedListings.filter(l => l.distanceKm !== null && l.distanceKm <= Number(radiusKm));
    }

    // Apply sorting
    if (sort === 'nearest' && userCoord) {
      processedListings.sort((a, b) => {
        if (a.distanceKm === null) return 1;
        if (b.distanceKm === null) return -1;
        return a.distanceKm - b.distanceKm;
      });
    } else if (sort === 'price_asc') {
      processedListings.sort((a, b) => a.pricePerUnitPaise - b.pricePerUnitPaise);
    } else if (sort === 'price_desc') {
      processedListings.sort((a, b) => b.pricePerUnitPaise - a.pricePerUnitPaise);
    } else if (sort === 'rating_desc') {
      processedListings.sort((a, b) => (b.ratingAvg || 0) - (a.ratingAvg || 0));
    } else {
      // newest
      processedListings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    }

    const hasMore = processedListings.length > Number(limit);
    if (hasMore) {
      processedListings = processedListings.slice(0, Number(limit));
    }
    const nextCursor = (hasMore && processedListings.length > 0)
      ? processedListings[processedListings.length - 1].id
      : null;

    // Also search Gram Sabhas
    const gsFilter = {};
    if (tokens.length > 0) {
      gsFilter.searchTerms = { $in: tokens.map(t => new RegExp(`^${escapeRegex(t)}`, 'i')) };
    }
    if (taluka) gsFilter.taluka = taluka;
    const gramsabhas = await GramSabha.find(gsFilter).limit(5);

    // Also search Resources
    const resFilter = {};
    if (tokens.length > 0) {
      resFilter.searchTerms = { $in: tokens.map(t => new RegExp(`^${escapeRegex(t)}`, 'i')) };
    }
    const resources = await Resource.find(resFilter).populate('categoryId').limit(5);

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
