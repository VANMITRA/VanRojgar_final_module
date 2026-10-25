import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { Listing } from '../models/Listing.js';
import { GramSabha } from '../models/GramSabha.js';
import { RestrictedItem } from '../models/RestrictedItem.js';
import { Category } from '../models/Category.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { config } from '../core/config.js';
import { normaliseString, buildSearchTokens } from '../core/normalise.js';
import { serializeListing, roundLocation } from '../core/serializers.js';
import { inferProductCode } from '../core/productCode.js';

/** One marker for the map layer. Coordinates are rounded to 2 decimals (about 1 km), like everywhere else in public. */
export function toMapPoint(listing) {
  const loc = roundLocation(listing.location);
  if (!loc) return null;
  return {
    id: String(listing._id),
    title: { mr: listing.title?.mr, en: listing.title?.en },
    village: listing.village,
    taluka: listing.taluka,
    category: listing.categoryId?.slug ?? null,
    productCode: listing.productCode ?? null,
    pricePerUnitPaise: listing.pricePerUnitPaise,
    unit: listing.unit,
    lat: loc.coordinates[1],
    lng: loc.coordinates[0]
  };
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class ListingService {
  static async checkRestricted(text) {
    const norm = normaliseString(text);
    if (!norm) return null;

    const restrictedList = await RestrictedItem.find();
    for (const item of restrictedList) {
      for (const term of item.terms) {
        const normTerm = normaliseString(term);
        if (normTerm && norm.includes(normTerm)) {
          return item;
        }
      }
    }
    return null;
  }

  static async create(user, data) {
    if (user.role === 'buyer') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Buyers cannot create listings', 403);
    }

    if (user.role === 'villager' && !config.ALLOW_VILLAGER_LISTINGS) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Villager direct listings are currently disabled in this pilot', 403);
    }

    // Check restricted items
    const restrictedViolation = (await this.checkRestricted(data.titleMr)) ||
                                (await this.checkRestricted(data.titleEn)) ||
                                (data.description ? await this.checkRestricted(data.description) : null);

    if (restrictedViolation) {
      throw new AppError(
        ErrorCodes.RESTRICTED_ITEM,
        `Listing contains protected or restricted forest resource: ${restrictedViolation.name.en} (${restrictedViolation.name.mr}). ${restrictedViolation.reason.en}`,
        422
      );
    }

    // Resolve Gram Sabha
    let gramSabhaId = user.gramSabhaId;
    if (!gramSabhaId && user.village) {
      const gs = await GramSabha.findOne({
        $or: [
          { 'village.mr': user.village },
          { 'village.en': user.village }
        ]
      });
      if (gs) gramSabhaId = gs._id;
    }

    if (!gramSabhaId) {
      throw new AppError(ErrorCodes.VALIDATION_ERROR, 'A valid Gram Sabha association is required to create listings', 422);
    }

    const gramSabha = await GramSabha.findById(gramSabhaId);
    if (!gramSabha) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Gram Sabha record not found', 404);
    }

    if (user.role === 'gramsabha' && gramSabha.claim && gramSabha.claim.status === 'pending' && gramSabha.claim.claimantPhone === user.phone) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Your Gram Sabha claim is awaiting VanRozgar team verification. You can list once it is approved.', 403);
    }

    // Rights hint check (D-9)
    let rightsNotOnRecord = false;
    const category = await Category.findById(data.categoryId);
    const isMfp = category && (category.slug.includes('produce') || category.slug.includes('medicinal'));
    if (isMfp && (!gramSabha.cfr || !gramSabha.cfr.rights || !gramSabha.cfr.rights.includes('3(1)(c)'))) {
      rightsNotOnRecord = true;
    }

    const pricePerUnitPaise = Math.round(data.pricePerUnitRupees * 100);
    const searchTerms = buildSearchTokens(
      data.titleMr,
      data.titleEn,
      gramSabha.village.mr,
      gramSabha.village.en,
      gramSabha.taluka,
      category ? category.name.mr : '',
      category ? category.name.en : ''
    );

    let location = undefined;
    if (data.longitude !== undefined && data.latitude !== undefined) {
      location = {
        type: 'Point',
        coordinates: [Number(data.longitude), Number(data.latitude)]
      };
    } else if (gramSabha.location && Array.isArray(gramSabha.location.coordinates) && gramSabha.location.coordinates.length === 2) {
      location = gramSabha.location;
    } else {
      try {
        const villagePointsRaw = JSON.parse(fs.readFileSync(path.join(__dirname, '../seed/data/village_points.json'), 'utf-8'));
        const match = villagePointsRaw.find(p =>
          p.taluka?.toLowerCase() === gramSabha.taluka?.toLowerCase() &&
          (p.villageMr === gramSabha.village.mr || p.villageEn?.toLowerCase() === gramSabha.village.en?.toLowerCase())
        ) || villagePointsRaw.find(p => p.taluka?.toLowerCase() === gramSabha.taluka?.toLowerCase());
        if (match?.coordinates) {
          location = { type: 'Point', coordinates: match.coordinates };
        }
      } catch (_) {}
    }

    const listing = await Listing.create({
      ownerType: user.role === 'gramsabha' ? 'gramsabha' : 'villager',
      ownerId: user._id,
      gramSabhaId: gramSabha._id,
      title: { mr: data.titleMr, en: data.titleEn },
      categoryId: data.categoryId,
      description: data.description,
      productCode: data.productCode || inferProductCode(data.titleEn, data.titleMr) || undefined,
      quantityAvailable: data.quantityAvailable,
      unit: data.unit,
      pricePerUnitPaise,
      mode: data.mode,
      barterWants: data.barterWants,
      provenance: {
        sourceForestArea: data.sourceForestArea || 'CFR Boundary',
        collectionNote: data.collectionNote,
        sustainableDeclared: true
      },
      fulfilment: data.fulfilment,
      location,
      village: data.village || gramSabha.village.mr,
      taluka: data.taluka || gramSabha.taluka,
      district: gramSabha.district || 'Nashik',
      searchTerms,
      flags: { rightsNotOnRecord }
    });

    return serializeListing(listing, { isOwnerOrParticipant: true });
  }

  /** Active listings that have a position, for the map layer. Optional filter by product code. */
  static async mapPoints({ productCode } = {}) {
    const filter = { status: 'active', 'location.coordinates.1': { $exists: true } };
    if (productCode) filter.productCode = productCode;
    const rows = await Listing.find(filter).populate('categoryId', 'slug').sort({ createdAt: -1, _id: -1 }).limit(500);
    return rows.map(toMapPoint).filter(Boolean);
  }

  static async getById(id, requestingUser = null) {
    const listing = await Listing.findById(id)
      .populate('gramSabhaId')
      .populate('categoryId');
    if (!listing) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Listing not found', 404);
    }
    const isOwner = requestingUser && listing.ownerId.toString() === requestingUser._id.toString();
    return serializeListing(listing, { isOwnerOrParticipant: isOwner });
  }

  static async update(id, user, updateData) {
    const listing = await Listing.findById(id);
    if (!listing) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Listing not found', 404);
    }

    if (listing.ownerId.toString() !== user._id.toString() && user.role !== 'team') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You do not own this listing', 403);
    }

    if (updateData.titleMr || updateData.titleEn) {
      const restrictedViolation = (updateData.titleMr ? await this.checkRestricted(updateData.titleMr) : null) ||
                                  (updateData.titleEn ? await this.checkRestricted(updateData.titleEn) : null);
      if (restrictedViolation) {
        throw new AppError(ErrorCodes.RESTRICTED_ITEM, `Protected item cannot be listed: ${restrictedViolation.name.en}`, 422);
      }
    }

    if (updateData.titleMr) listing.title.mr = updateData.titleMr;
    if (updateData.titleEn) listing.title.en = updateData.titleEn;
    if (updateData.description !== undefined) listing.description = updateData.description;
    if (updateData.quantityAvailable !== undefined) {
      listing.quantityAvailable = updateData.quantityAvailable;
      if (listing.quantityAvailable === 0 && listing.status === 'active') {
        listing.status = 'sold_out';
      }
    }
    if (updateData.pricePerUnitRupees !== undefined) {
      listing.pricePerUnitPaise = Math.round(updateData.pricePerUnitRupees * 100);
    }
    if (updateData.mode) listing.mode = updateData.mode;
    if (updateData.barterWants !== undefined) listing.barterWants = updateData.barterWants;
    if (updateData.status) listing.status = updateData.status;
    if (updateData.fulfilment) listing.fulfilment = updateData.fulfilment;

    await listing.save();
    return serializeListing(listing, { isOwnerOrParticipant: true });
  }

  static async updateStatus(id, user, status) {
    const listing = await Listing.findById(id);
    if (!listing) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Listing not found', 404);
    }

    if (listing.ownerId.toString() !== user._id.toString() && user.role !== 'team') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You do not own this listing', 403);
    }

    if (status === 'rejected' && user.role !== 'team') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the VanRozgar team can reject a listing', 403);
    }
    listing.status = status;
    await listing.save();
    return serializeListing(listing, { isOwnerOrParticipant: true });
  }

  static async getMine(user) {
    const listings = await Listing.find({ ownerId: user._id })
      .populate('categoryId')
      .sort({ createdAt: -1 });
    return listings.map(l => serializeListing(l, { isOwnerOrParticipant: true }));
  }
}
