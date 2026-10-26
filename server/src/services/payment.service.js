import { Order } from '../models/Order.js';
import { Delivery } from '../models/Delivery.js';
import { DeliveryPartner } from '../models/DeliveryPartner.js';
import { Message } from '../models/Message.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { config } from '../core/config.js';

const same = (a, b) => a && b && a.toString() === b.toString();

/** A UPI payment reference is a number or code the bank shows after paying (usually 12 digits). */
export const UPI_REFERENCE = /^[A-Za-z0-9]{8,30}$/;

export function upiEnabled() {
  return Boolean(config.UPI_ID);
}

/** upi://pay link for the buyer's UPI app. Amount is in rupees with two decimals. */
export function buildUpiLink({ orderId, totalPaise }) {
  const params = new URLSearchParams({
    pa: config.UPI_ID,
    pn: config.UPI_PAYEE_NAME,
    am: (totalPaise / 100).toFixed(2),
    tn: `VanRozgar order ${orderId.toString().slice(-8)}`,
    cu: 'INR'
  });
  // URLSearchParams writes spaces as '+', but UPI apps want %20
  return `upi://pay?${params.toString().replace(/\+/g, '%20')}`;
}

async function loadOrder(id) {
  const order = await Order.findById(id);
  if (!order) throw new AppError(ErrorCodes.NOT_FOUND, 'Order not found', 404);
  return order;
}

function notify(order, recipientId, actorId, title, body) {
  return Message.create({ recipientId, actorId, type: 'order_status_changed', orderId: order._id, title, body });
}

export class PaymentService {
  static options() {
    return { upi: upiEnabled(), cod: true };
  }

  /** Buyer only: the UPI link for an order that is waiting for payment. */
  static async getUpiLink(id, user) {
    const order = await loadOrder(id);
    if (!same(order.buyerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can pay for this order', 403);
    }
    if (order.paymentMethod !== 'upi' || order.paymentStatus !== 'awaiting_payment') {
      throw new AppError(ErrorCodes.CONFLICT, 'This order is not waiting for a UPI payment', 409);
    }
    if (!upiEnabled()) {
      throw new AppError(ErrorCodes.CONFLICT, 'UPI is not set up on this server yet. Choose cash on delivery.', 409);
    }
    return {
      link: buildUpiLink({ orderId: order._id, totalPaise: order.line.totalPaise }),
      payeeName: config.UPI_PAYEE_NAME,
      upiId: config.UPI_ID,
      amountPaise: order.line.totalPaise
    };
  }

  /** Buyer says "I paid" and gives the reference. Nothing is verified here: the seller confirms. */
  static async reportPayment(id, user, reference) {
    const order = await loadOrder(id);
    if (!same(order.buyerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can report a payment', 403);
    }
    if (order.paymentMethod !== 'upi') {
      throw new AppError(ErrorCodes.CONFLICT, 'This order is cash on delivery', 409);
    }
    if (order.paymentStatus !== 'awaiting_payment') {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot report a payment when it is '${order.paymentStatus}'`, 409);
    }
    if (['cancelled', 'closed'].includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, `Order is ${order.orderStatus}`, 409);
    }
    order.paymentStatus = 'payment_reported';
    order.payment.reference = reference;
    order.payment.reportedAt = new Date();
    order.timeline.push({
      status: 'payment_reported',
      at: new Date(),
      actorId: user._id,
      note: `Buyer says the UPI payment was made (reference ${reference}). Not yet confirmed by the seller.`
    });
    await order.save();
    await notify(order, order.sellerId, user._id,
      { mr: 'खरेदीदाराने UPI पेमेंट केल्याचे सांगितले', en: 'Buyer reports a UPI payment' },
      { mr: `संदर्भ क्रमांक ${reference}. तुमच्या खात्यात पैसे आले का ते पाहून पुष्टी करा.`,
        en: `Reference ${reference}. Check your account, then confirm that the money arrived.` });
    return order;
  }

  /** Seller confirms the money reached their account. Only a person can say this. */
  static async confirmPayment(id, user) {
    const order = await loadOrder(id);
    if (!same(order.sellerId, user._id)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the seller can confirm that the money arrived', 403);
    }
    if (order.paymentStatus !== 'payment_reported') {
      throw new AppError(ErrorCodes.CONFLICT, `Nothing to confirm: payment is '${order.paymentStatus}'`, 409);
    }
    order.paymentStatus = 'payment_confirmed';
    order.payment.confirmedAt = new Date();
    order.payment.confirmedBy = user._id;
    order.timeline.push({
      status: 'payment_confirmed',
      at: new Date(),
      actorId: user._id,
      note: 'Seller confirmed that the money arrived'
    });
    await order.save();
    await notify(order, order.buyerId, user._id,
      { mr: 'विक्रेत्याने पेमेंटची पुष्टी केली', en: 'Seller confirmed your payment' },
      { mr: 'विक्रेत्याने पैसे मिळाल्याची पुष्टी केली आहे.', en: 'The seller confirmed that the money arrived.' });
    return order;
  }

  /**
   * Cash on delivery: the cash is collected by the assigned delivery partner (delivery orders)
   * or by the seller (pickup orders). The other side sees it on the order.
   */
  static async markCashReceived(id, user) {
    const order = await loadOrder(id);
    if (order.paymentMethod !== 'cod') {
      throw new AppError(ErrorCodes.CONFLICT, 'This order is paid by UPI', 409);
    }
    if (order.paymentStatus !== 'cod_pending') {
      throw new AppError(ErrorCodes.CONFLICT, `Cash was already handled: payment is '${order.paymentStatus}'`, 409);
    }
    if (['cancelled', 'closed'].includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, `Order is ${order.orderStatus}`, 409);
    }

    let recipientId = order.sellerId;
    let deliveryToMark = null;
    if (order.fulfilment.method === 'delivery') {
      const delivery = order.deliveryId ? await Delivery.findById(order.deliveryId) : null;
      const partner = await DeliveryPartner.findOne({ userId: user._id });
      if (!delivery || !partner || !same(delivery.partnerId, partner._id)) {
        throw new AppError(ErrorCodes.FORBIDDEN, 'Only the delivery partner of this order can mark the cash as received', 403);
      }
      if (!['on_the_way', 'delivered'].includes(delivery.status)) {
        throw new AppError(ErrorCodes.CONFLICT, 'Cash can be marked as received once the goods are on the way', 409);
      }
      deliveryToMark = delivery;
    } else {
      if (!same(order.sellerId, user._id)) {
        throw new AppError(ErrorCodes.FORBIDDEN, 'For a pickup order the seller marks the cash as received', 403);
      }
      if (!['approved', 'handed_over', 'delivered'].includes(order.orderStatus)) {
        throw new AppError(ErrorCodes.CONFLICT, `Cannot take cash on an order that is '${order.orderStatus}'`, 409);
      }
      recipientId = order.buyerId;
    }

    order.paymentStatus = 'cash_received';
    order.payment.cashReceivedAt = new Date();
    order.payment.cashReceivedBy = user._id;
    order.timeline.push({
      status: 'cash_received',
      at: new Date(),
      actorId: user._id,
      note: 'Cash on delivery was received'
    });
    await order.save();
    if (deliveryToMark) {
      deliveryToMark.cashCollected = true;
      await deliveryToMark.save();
    }
    await notify(order, recipientId, user._id,
      { mr: 'रोख रक्कम मिळाली', en: 'Cash received' },
      { mr: `${order.line.title.mr} साठी रोख रक्कम मिळाल्याची नोंद झाली.`,
        en: `Cash for ${order.line.title.en} was marked as received.` });
    return order;
  }
}
