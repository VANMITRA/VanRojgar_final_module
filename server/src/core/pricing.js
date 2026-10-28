// Price and stock facts shown on every product card: the MRP (original price), the discount, and how much of the
// stock is sold. Older listings have no MRP or total stock saved, so these fall back to what is known.

/** MRP and discount for a listing (paise). A listing without an MRP has no discount. */
export function pricingOf(listing) {
  const price = Number(listing.pricePerUnitPaise) || 0;
  const mrpRaw = Number(listing.mrpPerUnitPaise);
  const mrp = Number.isFinite(mrpRaw) && mrpRaw >= price ? mrpRaw : price;
  const discountPaise = Math.max(0, mrp - price);
  const discountPercent = mrp > 0 ? Math.round((discountPaise / mrp) * 100) : 0;
  return { mrpPerUnitPaise: mrp, discountPaise, discountPercent };
}

/** Total, sold and left for a listing. `sold` counts approved orders (stock leaves at approval). */
export function stockOf(listing) {
  const available = Math.max(0, Number(listing.quantityAvailable) || 0);
  const totalRaw = Number(listing.quantityTotal);
  const total = Number.isFinite(totalRaw) && totalRaw >= available ? totalRaw : available;
  const sold = total - available;
  return {
    quantityTotal: total,
    quantitySold: sold,
    soldPercent: total > 0 ? Math.round((sold / total) * 100) : 0
  };
}

/** The smallest quantity a buyer may ask for. The last few units left can always be bought whole. */
export function minimumOrder(listing) {
  const min = Number(listing.minOrderQuantity);
  return Number.isFinite(min) && min > 0 ? min : 1;
}

/** Check a quantity against the seller's minimum. Returns an error message or null. */
export function minimumOrderProblem(listing, quantity) {
  const min = minimumOrder(listing);
  const left = Number(listing.quantityAvailable) || 0;
  if (quantity >= min || quantity >= left) return null;
  return `The minimum order for this product is ${min} ${listing.unit}`;
}
