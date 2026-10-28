import { Listing } from '../models/Listing.js';
import { Category } from '../models/Category.js';
import { User } from '../models/User.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { normaliseString } from '../core/normalise.js';
import { serializeListing } from '../core/serializers.js';
import { TradeService } from './trade.service.js';

const OPEN = { status: 'active', quantityAvailable: { $gt: 0 } };

/** Every active listing that still has stock. The pilot is small, so grouping and sorting happen here. */
async function loadOpen() {
  return Listing.find(OPEN)
    .populate('categoryId', 'slug name')
    .populate('gramSabhaId', 'village taluka')
    .sort({ createdAt: -1, _id: -1 })
    .limit(1000);
}

function matchesQuery(listing, tokens) {
  if (tokens.length === 0) return true;
  const hay = [...(listing.searchTerms ?? []), normaliseString(listing.title?.en), normaliseString(listing.title?.mr)].join(' ');
  return tokens.every((t) => hay.includes(t));
}

/** The display name of each seller (the account name), by owner id, for the rows we are about to send. */
async function ownerNames(rows) {
  const ids = [...new Set(rows.map((l) => String(l.ownerId)))];
  if (ids.length === 0) return new Map();
  const users = await User.find({ _id: { $in: ids } }).select('name');
  return new Map(users.map((u) => [String(u._id), u.name]));
}

/** One seller row on a product page. */
function sellerRow(listing, names = new Map()) {
  const doc = serializeListing(listing);
  return {
    ...doc,
    seller: {
      ownerId: String(listing.ownerId),
      name: names.get(String(listing.ownerId)) ?? null,
      type: listing.ownerType === 'villager' ? 'cfrholder' : listing.ownerType, // gramsabha | cfrholder
      village: listing.village,
      taluka: listing.taluka
    }
  };
}

function groupKey(listing) {
  return `${listing.productCode || `item:${listing._id}`}|${listing.unit}`;
}

const byNewest = (a, b) => new Date(b.createdAt) - new Date(a.createdAt);

/** Group listings into products (same product code and unit): the lowest price, the sellers, the best discount. */
function groupProducts(rows) {
  const groups = new Map();
  for (const l of rows) {
    const key = groupKey(l);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(l);
  }
  return [...groups.values()].map((listings) => {
    const cards = listings.map((l) => serializeListing(l));
    const cheapest = cards.reduce((a, b) => (b.pricePerUnitPaise < a.pricePerUnitPaise ? b : a));
    return {
      productCode: listings[0].productCode ?? null,
      listingId: listings.length === 1 ? String(listings[0]._id) : null, // a product with one seller opens that listing
      title: cheapest.title,
      category: listings[0].categoryId ? { slug: listings[0].categoryId.slug, name: listings[0].categoryId.name } : null,
      unit: listings[0].unit,
      imageUrl: cards.find((c) => c.imageUrl)?.imageUrl ?? null,
      sellerCount: listings.length,
      minPricePaise: Math.min(...cards.map((c) => c.pricePerUnitPaise)),
    startingAtPaise: Math.min(...cards.map((c) => c.pricePerUnitPaise)), // "Starting at" on the deals row
      maxPricePaise: Math.max(...cards.map((c) => c.pricePerUnitPaise)),
      bestDiscountPercent: Math.max(...cards.map((c) => c.discountPercent)),
      totalAvailable: cards.reduce((n, c) => n + c.quantityAvailable, 0),
      totalSold: cards.reduce((n, c) => n + c.quantitySold, 0),
      newestAt: cards.map((c) => c.createdAt).sort().pop()
    };
  });
}


export class ShopService {
  /** Products: listings grouped by product code and unit, with the lowest price and the number of sellers. */
  static async products({ q, category, sort = 'popular', limit = 24, cursor } = {}) {
    const tokens = normaliseString(q).split(' ').filter(Boolean);
    const rows = (await loadOpen()).filter((l) => (!category || l.categoryId?.slug === category) && matchesQuery(l, tokens));

    let products = groupProducts(rows);

    if (sort === 'price_asc') products.sort((a, b) => a.minPricePaise - b.minPricePaise);
    else if (sort === 'discount_desc') products.sort((a, b) => b.bestDiscountPercent - a.bestDiscountPercent || b.totalSold - a.totalSold);
    else if (sort === 'newest') products.sort((a, b) => new Date(b.newestAt) - new Date(a.newestAt));
    else products.sort((a, b) => b.totalSold - a.totalSold || b.sellerCount - a.sellerCount || new Date(b.newestAt) - new Date(a.newestAt));

    const offset = Math.max(0, parseInt(cursor, 10) || 0);
    const size = Number(limit);
    const page = products.slice(offset, offset + size);
    return { products: page, nextCursor: products.length > offset + size ? String(offset + size) : null, total: products.length };
  }

  /** All sellers of one product, cheapest first, with the best price marked. */
  static async sellers(productCode, { unit, sort = 'price_asc' } = {}) {
    const code = String(productCode || '').toLowerCase();
    const rows = (await loadOpen()).filter((l) => l.productCode === code && (!unit || l.unit === unit));
    if (rows.length === 0) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'No seller has this product right now', 404);
    }
    const names = await ownerNames(rows);
    const list = rows.map((l) => sellerRow(l, names));
    if (sort === 'discount_desc') list.sort((a, b) => b.discountPercent - a.discountPercent || a.pricePerUnitPaise - b.pricePerUnitPaise);
    else if (sort === 'newest') list.sort(byNewest);
    else list.sort((a, b) => a.pricePerUnitPaise - b.pricePerUnitPaise || byNewest(a, b));
    const lowest = Math.min(...list.map((l) => l.pricePerUnitPaise));
    return {
      productCode: code,
      title: list[0].title,
      sellerCount: list.length,
      lowestPricePaise: lowest,
      highestPricePaise: Math.max(...list.map((l) => l.pricePerUnitPaise)),
      totalAvailable: list.reduce((n, l) => n + l.quantityAvailable, 0),
      sellers: list.map((l) => ({ ...l, isLowestPrice: l.pricePerUnitPaise === lowest }))
    };
  }

  /** One call for the home screen: deals, best sellers, new arrivals and the categories with counts. */
  static async home() {
    const rows = await loadOpen();
    const names = await ownerNames(rows);
    const cards = rows.map((l) => sellerRow(l, names));
    const deals = cards.filter((c) => c.discountPercent > 0)
      .sort((a, b) => b.discountPercent - a.discountPercent || b.discountPaise - a.discountPaise).slice(0, 12);
    const bestSellers = cards.filter((c) => c.quantitySold > 0)
      .sort((a, b) => b.quantitySold - a.quantitySold).slice(0, 12);
    const newArrivals = [...cards].sort(byNewest).slice(0, 12);

    const cats = await Category.find({ active: { $ne: false } }).sort({ order: 1, 'name.en': 1 });
    const counts = new Map();
    for (const l of rows) {
      const slug = l.categoryId?.slug;
      if (slug) counts.set(slug, (counts.get(slug) ?? 0) + 1);
    }
    // Only categories that have products are shown on the home screen, so no tile opens an empty page.
    // (A seller still sees every category in the add-product form: that comes from /categories.)
    const categories = cats.map((c) => ({
      id: String(c._id), slug: c.slug, name: c.name, description: c.description ?? null, listingCount: counts.get(c.slug) ?? 0
    })).filter((c) => c.listingCount > 0);
    // "Top deals, starting at Rs X": one tile per product, biggest discount first, with the lowest price among its sellers
    const topDeals = groupProducts(rows).filter((p) => p.bestDiscountPercent > 0)
      .sort((a, b) => b.bestDiscountPercent - a.bestDiscountPercent || a.startingAtPaise - b.startingAtPaise).slice(0, 12);
    return { deals, topDeals, bestSellers, newArrivals, categories, openListings: rows.length };
  }

  /** The numbers for the live "sold / left" bar. Cheap: the app can ask for a few products every few seconds. */
  static async stock(ids) {
    const rows = await Listing.find({ _id: { $in: ids } }).select('quantityAvailable quantityTotal status unit');
    return rows.map((l) => {
      const c = serializeListing(l);
      return {
        id: String(l._id), status: l.status, unit: l.unit,
        quantityAvailable: c.quantityAvailable, quantityTotal: c.quantityTotal,
        quantitySold: c.quantitySold, soldPercent: c.soldPercent
      };
    });
  }

  /**
   * Cart checkout: one request per product, so each seller approves or counters on their own and is paid on their own.
   * Items that cannot be requested (no stock, below the seller's minimum) are reported, the rest go through.
   */
  static async checkout(user, { items, ...rest }) {
    const created = [];
    const failed = [];
    for (const item of items) {
      try {
        const request = await TradeService.createRequest(user, { ...rest, listingId: item.listingId, quantity: item.quantity });
        created.push({ listingId: item.listingId, quantity: item.quantity, request });
      } catch (err) {
        failed.push({ listingId: item.listingId, code: err.code ?? 'INTERNAL', message: err.message });
      }
    }
    if (created.length === 0) {
      const fields = Object.fromEntries(failed.map((f) => [f.listingId, f.message]));
      throw new AppError(ErrorCodes.CONFLICT, 'None of the products in the cart could be requested', 409, fields);
    }
    return { created, failed };
  }
}
