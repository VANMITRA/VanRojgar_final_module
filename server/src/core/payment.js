// Payment rules for orders: UPI (the buyer pays in their own UPI app) or cash on delivery.
// There is no payment gateway, so the server never sees the money. A person confirms it:
//   UPI: buyer reports the payment reference -> seller confirms the money arrived.
//   COD: the delivery partner (or the seller, for pickup) marks the cash as received.

export const PAYMENT_METHODS = ['upi', 'cod'];

export const PAYMENT_STATUSES = [
  'demo_pending', 'not_required', 'completed',
  'awaiting_payment', 'payment_reported', 'payment_confirmed',
  'cod_pending', 'cash_received'
];

// Order states from which cash can have changed hands (the goods have left the seller)
export const CASH_STAGES = ['picked_up', 'on_the_way', 'handed_over', 'delivered', 'closed'];

const UPI_ID = /^[A-Za-z0-9._-]{2,64}@[A-Za-z][A-Za-z0-9]{1,31}$/;
const REFERENCE = /^[A-Za-z0-9]{6,35}$/;

export function isValidUpiId(id) {
  return typeof id === 'string' && UPI_ID.test(id);
}

export function isValidReference(ref) {
  return typeof ref === 'string' && REFERENCE.test(ref);
}

/**
 * The link that opens the buyer's UPI app with payee, amount and note filled in.
 * Returns null when the team UPI ID is not configured or is not shaped like a UPI ID.
 */
export function buildUpiLink({ upiId, payeeName, totalPaise, orderId }) {
  if (!isValidUpiId(upiId)) return null;
  const amount = (Math.round(totalPaise) / 100).toFixed(2);
  const note = `VanRozgar order ${String(orderId).slice(-6)}`;
  return `upi://pay?pa=${upiId}&pn=${encodeURIComponent(payeeName || 'VanRozgar')}`
    + `&am=${amount}&tn=${encodeURIComponent(note)}&cu=INR`;
}

/** Plain-language state for the app and for tests. */
export function describePayment(order) {
  switch (order.paymentStatus) {
    case 'awaiting_payment': return 'Waiting for the buyer to pay by UPI';
    case 'payment_reported': return 'Buyer says they paid; the seller must confirm the money arrived';
    case 'payment_confirmed': return 'Seller confirmed the UPI payment arrived';
    case 'cod_pending': return 'Cash on delivery: pay when the goods arrive';
    case 'cash_received': return 'Cash received on delivery';
    default: return 'Payment method not chosen yet';
  }
}
