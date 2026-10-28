import { pricingOf, stockOf, minimumOrder } from './pricing.js';
/**
 * Serializes standard success response envelope
 */
export function successEnvelope(data, meta = {}) {
  return {
    success: true,
    data,
    meta: {
      ...meta,
      timestamp: new Date().toISOString()
    }
  };
}

/**
 * Sanitizes user object - strictly strips passwordHash
 */
export function serializeUser(user) {
  if (!user) return null;
  const doc = user.toObject ? user.toObject() : { ...user };
  delete doc.passwordHash;
  delete doc.__v;
  return doc;
}

/**
 * Rounds GeoJSON coordinates for public privacy (~1 km)
 */
export function roundLocation(location) {
  if (!location || !Array.isArray(location.coordinates) || location.coordinates.length < 2) {
    return null;
  }
  return {
    type: 'Point',
    coordinates: [
      Math.round(location.coordinates[0] * 100) / 100,
      Math.round(location.coordinates[1] * 100) / 100
    ]
  };
}

/**
 * Serializes a listing
 */
export function serializeListing(listing, { isOwnerOrParticipant = false } = {}) {
  if (!listing) return null;
  const doc = listing.toObject ? listing.toObject() : { ...listing };
  delete doc.__v;

  if (!isOwnerOrParticipant && doc.location) {
    doc.location = roundLocation(doc.location);
  }
  // Shop fields every card needs: MRP and discount, sold and left, the seller's minimum order
  Object.assign(doc, pricingOf(doc), stockOf(doc), { minOrderQuantity: minimumOrder(doc) });
  return doc;
}

/**
 * Serializes a Gram Sabha
 */
export function serializeGramSabha(gs, { includeClaim = false } = {}) {
  if (!gs) return null;
  const doc = gs.toObject ? gs.toObject() : { ...gs };
  delete doc.__v;
  if (doc.claim && !includeClaim) doc.claim = { status: doc.claim.status };
  return doc;
}
