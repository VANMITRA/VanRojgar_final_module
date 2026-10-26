import { Order } from '../models/Order.js';
import { Message } from '../models/Message.js';
import { Delivery } from '../models/Delivery.js';
import { DeliveryPartner } from '../models/DeliveryPartner.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { config } from '../core/config.js';
import { buildUpiLink, CASH_STAGES } from '../core/payment.js';

const same = (a, b) => Boolean(a && b && a.toString() === b.toString());

async function load(id) {
  const order = await Order.findById(id);
  if (!order) throw new AppError(ErrorCodes.NOT_FOUND, 'Order not found', 404);
  return order;
}

function note(order, status, actorId, text) {
  order.timeline.push({ status: `payment_${status}`, at: new Date(), actorId, note: text });
}

async function tell(order, actor, recipientId, title, body) {
  await Message.create({
    recipientId, actorId: actor._id, type: 'order_payment', orderId: order._id,
    title: { mr: title.mr, en: title.en }, body: { mr: body.mr, en: body.en }
  });
}

export class PaymentService {
  /** Buyer picks UPI or cash on delivery, once, while the order is live. */
  static async chooseMethod(id, user, method) {
    const order = await load(id);
    if (!same(order.buyerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer chooses how to pay', 403);
    }
    if (['cancelled', 'closed'].includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot set payment on an order that is ${order.orderStatus}`, 409);
    }
    if (order.paymentMethod) {
      throw new AppError(ErrorCodes.CONFLICT, 'The payment method is already chosen for this order', 409);
    }
    order.paymentMethod = method;
    order.paymentStatus = method === 'upi' ? 'awaiting_payment' : 'cod_pending';
    note(order, order.paymentStatus, user._id, method === 'upi' ? 'Buyer chose UPI' : 'Buyer chose cash on delivery');
    await order.save();
    await tell(order, user, order.sellerId,
      { mr: 'पेमेंट पद्धत निवडली', en: 'Payment method chosen' },
      {
        mr: method === 'upi' ? 'खरेदीदार यूपीआयने पैसे देईल' : 'खरेदीदार डिलिव्हरीवर रोख देईल',
        en: method === 'upi' ? 'The buyer will pay by UPI' : 'The buyer will pay cash on delivery'
      });
    return order;
  }

  /** The UPI link the buyer's phone opens. Needs the team UPI ID in the server settings. */
  static async upiLink(id, user) {
    const order = await load(id);
    if (!same(order.buyerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can pay this order', 403);
    }
    if (order.paymentMethod !== 'upi' || order.paymentStatus !== 'awaiting_payment') {
      throw new AppError(ErrorCodes.CONFLICT, 'This order is not waiting for a UPI payment', 409);
    }
    const link = buildUpiLink({
      upiId: config.UPI_ID, payeeName: config.UPI_PAYEE_NAME,
      totalPaise: order.line.totalPaise, orderId: order._id
    });
    if (!link) {
      throw new AppError(ErrorCodes.INTERNAL, 'UPI is not set up on the server yet. Choose cash on delivery.', 503);
    }
    return { link, amountPaise: order.line.totalPaise };
  }

  /** Buyer says they paid and gives the reference from their UPI app. */
  static async reportPayment(id, user, reference) {
    const order = await load(id);
    if (!same(order.buyerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can report a payment', 403);
    }
    if (order.paymentStatus !== 'awaiting_payment') {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot report a payment when it is '${order.paymentStatus}'`, 409);
    }
    order.paymentStatus = 'payment_reported';
    order.set('payment.reference', reference);
    order.set('payment.reportedAt', new Date());
    note(order, 'reported', user._id, `Buyer reported UPI payment, reference ${reference}`);
    await order.save();
    await tell(order, user, order.sellerId,
      { mr: 'खरेदीदाराने पैसे दिल्याचे सांगितले', en: 'Buyer reports a UPI payment' },
      { mr: `संदर्भ ${reference}. पैसे मिळाले असल्यास पुष्टी करा.`, en: `Reference ${reference}. Confirm once the money reaches you.` });
    return order;
  }

  /** The seller confirms the money arrived. Only a person can say so: the app cannot see the bank. */
  static async confirmPayment(id, user) {
    const order = await load(id);
    if (!same(order.sellerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the seller can confirm that the money arrived', 403);
    }
    if (order.paymentStatus !== 'payment_reported') {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot confirm a payment when it is '${order.paymentStatus}'`, 409);
    }
    order.paymentStatus = 'payment_confirmed';
    order.set('payment.confirmedAt', new Date());
    note(order, 'confirmed', user._id, 'Seller confirmed the UPI payment arrived');
    await order.save();
    await tell(order, user, order.buyerId,
      { mr: 'पेमेंटची पुष्टी झाली', en: 'Payment confirmed' },
      { mr: 'विक्रेत्याने पैसे मिळाल्याची पुष्टी केली.', en: 'The seller confirmed the money arrived.' });
    return order;
  }

  /** COD: the delivery partner on the job, or the seller for a pickup order, marks the cash as received. */
  static async cashReceived(id, user) {
    const order = await load(id);
    if (order.paymentStatus !== 'cod_pending') {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot mark cash received when payment is '${order.paymentStatus}'`, 409);
    }
    let allowed = false;
    if (order.fulfilment?.method === 'delivery' && order.deliveryId) {
      const delivery = await Delivery.findById(order.deliveryId);
      const partner = delivery?.partnerId
        ? await DeliveryPartner.findOne({ _id: delivery.partnerId, userId: user._id })
        : null;
      allowed = Boolean(partner);
    } else {
      allowed = same(order.sellerId, user._id);
    }
    if (!allowed) {
      throw new AppError(ErrorCodes.FORBIDDEN,
        'Only the delivery partner on this job (or the seller, for pickup) can mark the cash received', 403);
    }
    if (!CASH_STAGES.includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, 'The goods have not left the seller yet', 409);
    }
    order.paymentStatus = 'cash_received';
    order.set('payment.cashReceivedAt', new Date());
    order.set('payment.cashReceivedBy', user._id);
    note(order, 'cash_received', user._id, 'Cash received on delivery');
    await order.save();
    for (const to of [order.sellerId, order.buyerId].filter((x) => !same(x, user._id))) {
      await tell(order, user, to,
        { mr: 'रोख रक्कम मिळाली', en: 'Cash received' },
        { mr: 'डिलिव्हरीवर रोख रक्कम मिळाल्याची नोंद झाली.', en: 'Cash on delivery was recorded as received.' });
    }
    return order;
  }
}
