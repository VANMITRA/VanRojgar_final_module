/**
 * Pure business logic and calculation helpers for VanRozgar Marketplace.
 * Decoupled from UI to enable fast unit testing and deterministic verification.
 */

export const LARGE_ORDER_THRESHOLD = 25; // Units (kg/jars/pieces) above which sustainability reason is required

/**
 * Checks whether an order quantity is classified as large,
 * requiring a mandatory sustainability harvest reason.
 */
export function checkIsLargeOrder(quantity: number): boolean {
  return quantity >= LARGE_ORDER_THRESHOLD;
}

/**
 * Generates the suggested fair price range based on recent market transactions.
 * Returns [minPrice, maxPrice] in ₹.
 */
export function calculateFairPriceRange(basePrice: number): [number, number] {
  if (basePrice <= 0) return [0, 0];
  const min = Math.round(basePrice * 0.88);
  const max = Math.round(basePrice * 1.14);
  return [min, max];
}

export interface BarterEvaluation {
  ratio: number;
  verdict: 'balanced' | 'favorable_to_offerer' | 'favorable_to_receiver';
  label: string;
  advice: string;
}

/**
 * Evaluates barter fairness balance between offered goods value and requested goods value.
 */
export function evaluateBarterBalance(offeredValue: number, requestedValue: number): BarterEvaluation {
  if (offeredValue <= 0 || requestedValue <= 0) {
    return {
      ratio: 0,
      verdict: 'balanced',
      label: 'Insufficient Data',
      advice: 'Enter valid quantities and values to evaluate balance.',
    };
  }

  const ratio = Number((offeredValue / requestedValue).toFixed(2));

  if (ratio >= 0.85 && ratio <= 1.15) {
    return {
      ratio,
      verdict: 'balanced',
      label: 'Balanced Swap',
      advice: 'The proposed exchange is within the equitable fair-market range (±15%).',
    };
  } else if (ratio > 1.15) {
    return {
      ratio,
      verdict: 'favorable_to_receiver',
      label: 'Offerer Gives Higher Value',
      advice: `Offerer is contributing ~${Math.round((ratio - 1) * 100)}% more estimated value than requested.`,
    };
  } else {
    return {
      ratio,
      verdict: 'favorable_to_offerer',
      label: 'Offerer Gives Lower Value',
      advice: `Offerer is contributing ~${Math.round((1 - ratio) * 100)}% less estimated value than requested.`,
    };
  }
}

/**
 * Calculate demo estimated delivery remuneration for rural drivers.
 * Note: Actual pay model (fixed vs mileage) is an open product decision.
 */
export function calculateDeliveryPay(distanceKm: number, weightKg: number): number {
  const baseFare = 80; // ₹80 base pickup allowance
  const perKmRate = 12; // ₹12 per km
  const weightSurcharge = Math.max(0, weightKg - 10) * 1.5; // ₹1.5 per kg above 10kg
  return Math.round(baseFare + (distanceKm * perKmRate) + weightSurcharge);
}

export interface ProducerContribution {
  id: string;
  name: string;
  quantity: number;
}

export interface ProducerShareResult {
  id: string;
  name: string;
  quantity: number;
  sharePct: number;
  earnings: number;
}

/**
 * Computes individual Gram Sabha producer payouts for a pooled group listing.
 */
export function calculateGroupSellingSplit(
  contributions: ProducerContribution[],
  soldQuantity: number,
  pricePerUnit: number
): ProducerShareResult[] {
  const totalPooledQty = contributions.reduce((sum, c) => sum + c.quantity, 0);
  if (totalPooledQty === 0) return [];

  const actualSold = Math.min(soldQuantity, totalPooledQty);
  const totalRevenue = actualSold * pricePerUnit;

  return contributions.map((c) => {
    const sharePct = Number(((c.quantity / totalPooledQty) * 100).toFixed(1));
    const producerQtySold = (c.quantity / totalPooledQty) * actualSold;
    const earnings = Math.round(producerQtySold * pricePerUnit);

    return {
      id: c.id,
      name: c.name,
      quantity: c.quantity,
      sharePct,
      earnings,
    };
  });
}
