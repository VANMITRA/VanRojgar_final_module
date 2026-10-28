import mongoose from 'mongoose';
import { Request } from '../models/Request.js';
import { Listing } from '../models/Listing.js';
import { Order } from '../models/Order.js';
import { Message } from '../models/Message.js';
import { Delivery } from '../models/Delivery.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { config } from '../core/config.js';
import { assertValidTransition } from './requestMachine.js';
import { minimumOrderProblem } from '../core/pricing.js';

export class TradeService {
  static getBulkThreshold(unit) {
    if (['kg', 'g', 'quintal'].includes(unit)) return config.bulkThresholds.mass_kg || 50;
    if (['litre'].includes(unit)) return config.bulkThresholds.volume_l || 50;
    return config.bulkThresholds.count || 100;
  }

  static async createRequest(user, data) {
    const listing = await Listing.findById(data.listingId);
    if (!listing) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Listing not found', 404);
    }

    if (listing.status !== 'active') {
      throw new AppError(ErrorCodes.CONFLICT, `Listing is not active (current status: ${listing.status})`, 409);
    }

    if (listing.ownerId.toString() === user._id.toString()) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You cannot create a purchase request for your own listing', 403);
    }

    if (data.quantity > listing.quantityAvailable) {
      throw new AppError(
        ErrorCodes.INSUFFICIENT_STOCK,
        `Requested quantity (${data.quantity} ${listing.unit}) exceeds available stock (${listing.quantityAvailable} ${listing.unit})`,
        409
      );
    }

    const tooSmall = minimumOrderProblem(listing, data.quantity);
    if (tooSmall) {
      throw new AppError(ErrorCodes.VALIDATION_ERROR, tooSmall, 422, { quantity: tooSmall });
    }

    const threshold = this.getBulkThreshold(listing.unit);
    if (data.quantity >= threshold && (!data.reason || data.reason.trim().length < 5)) {
      throw new AppError(
        ErrorCodes.BULK_REASON_REQUIRED,
        `Orders of ${threshold} ${listing.unit} or more require a sustainability reason / use purpose`,
        422,
        { reason: 'Please provide purpose and planned use for this bulk harvest request' }
      );
    }

    if (data.deliveryPref === 'delivery' && listing.fulfilment === 'pickup') {
      throw new AppError(
        ErrorCodes.VALIDATION_ERROR,
        'This listing is available for pickup only; delivery is not offered',
        422
      );
    }

    if (data.paymentMethod === 'upi' && !config.UPI_ID) {
      throw new AppError(ErrorCodes.CONFLICT, 'UPI payment is not set up yet. Choose cash on delivery.', 409);
    }

    const request = await Request.create({
      listingId: listing._id,
      requesterId: user._id,
      requesterRole: user.role,
      sellerId: listing.ownerId,
      gramSabhaId: listing.gramSabhaId,
      quantity: data.quantity,
      unit: listing.unit,
      deliveryPref: data.deliveryPref || 'pickup',
      dropVillage: data.dropVillage || user.village,
      paymentMethod: data.paymentMethod || 'cod',
      reason: data.reason,
      status: 'pending',
      history: [{
        status: 'pending',
        at: new Date(),
        by: user._id,
        note: 'Purchase request initiated'
      }]
    });

    // Notify seller
    await Message.create({
      recipientId: listing.ownerId,
      actorId: user._id,
      type: 'request_created',
      requestId: request._id,
      title: {
        mr: `नवीन खरेदी विनंती: ${listing.title.mr}`,
        en: `New purchase request: ${listing.title.en}`
      },
      body: {
        mr: `${user.name} यांनी ${data.quantity} ${listing.unit} ची विनंती केली आहे`,
        en: `${user.name} requested ${data.quantity} ${listing.unit}`
      }
    });

    return request;
  }

  static async updateStatus(requestId, user, action, note = '') {
    const request = await Request.findById(requestId).populate('listingId');
    if (!request) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Request not found', 404);
    }

    const isSeller = request.sellerId.toString() === user._id.toString();
    const isRequester = request.requesterId.toString() === user._id.toString();

    if (action === 'approve') {
      if (!isSeller) {
        throw new AppError(ErrorCodes.FORBIDDEN, 'Only the seller can approve requests', 403);
      }
      return this._executeApproval(request, user, note);
    } else if (action === 'reject') {
      if (!isSeller) {
        throw new AppError(ErrorCodes.FORBIDDEN, 'Only the seller can reject requests', 403);
      }
      assertValidTransition(request.status, 'rejected');
      request.status = 'rejected';
      request.decisionNote = note;
      request.history.push({
        status: 'rejected',
        at: new Date(),
        by: user._id,
        note: note || 'Rejected by seller'
      });
      await request.save();

      await Message.create({
        recipientId: request.requesterId,
        actorId: user._id,
        type: 'request_rejected',
        requestId: request._id,
        title: { mr: 'विनंती नाकारली', en: 'Request rejected' },
        body: { mr: `आपली विनंती नाकारण्यात आली: ${note || 'विक्रेत्याने नाकारली'}`, en: `Your request was rejected: ${note || 'Rejected by seller'}` }
      });

      return { request };
    } else if (action === 'cancel') {
      if (!isRequester) {
        throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can cancel their request', 403);
      }
      assertValidTransition(request.status, 'cancelled');
      request.status = 'cancelled';
      request.history.push({
        status: 'cancelled',
        at: new Date(),
        by: user._id,
        note: note || 'Cancelled by requester'
      });
      await request.save();
      return { request };
    }

    throw new AppError(ErrorCodes.VALIDATION_ERROR, `Unknown action: ${action}`, 422);
  }

  static async _executeApproval(request, user, note) {
    assertValidTransition(request.status, 'approved');
    const listingId = request.listingId._id || request.listingId;
    const qty = request.quantity;

    // Use a session if replica set is available, else guarded atomic update
    let session = null;
    try {
      session = await mongoose.startSession();
      session.startTransaction();
    } catch {
      session = null;
    }

    try {
      const listing = await Listing.findOneAndUpdate(
        {
          _id: listingId,
          status: 'active',
          quantityAvailable: { $gte: qty }
        },
        {
          $inc: { quantityAvailable: -qty }
        },
        { new: true, session: session || undefined }
      );

      if (!listing) {
        throw new AppError(
          ErrorCodes.INSUFFICIENT_STOCK,
          'Stock has changed or is insufficient to approve this request',
          409
        );
      }

      if (listing.quantityAvailable === 0) {
        listing.status = 'sold_out';
        await listing.save({ session: session || undefined });
      }

      request.status = 'approved';
      request.history.push({
        status: 'approved',
        at: new Date(),
        by: user._id,
        note: note || 'Approved by seller'
      });
      await request.save({ session: session || undefined });

      // Create Order - respect agreed counter-offer price if present
      const unitPricePaise = (request.counter && request.counter.pricePerUnitPaise)
        ? request.counter.pricePerUnitPaise
        : listing.pricePerUnitPaise;
      const totalPaise = Math.round(qty * unitPricePaise);

      const order = await Order.create([{
        requestId: request._id,
        buyerId: request.requesterId,
        sellerId: request.sellerId,
        gramSabhaId: request.gramSabhaId,
        line: {
          listingId: listing._id,
          title: listing.title,
          quantity: qty,
          unit: listing.unit,
          pricePerUnitPaise: unitPricePaise,
          totalPaise
        },
        fulfilment: {
          method: request.deliveryPref,
          dropVillage: request.dropVillage,
          dropLocation: request.dropLocation
        },
        orderStatus: 'approved',
        paymentMethod: request.paymentMethod || 'cod',
        paymentStatus: request.paymentMethod === 'upi' ? 'awaiting_payment' : 'cod_pending',
        timeline: [{
          status: 'approved',
          at: new Date(),
          actorId: user._id,
          note: 'Order approved and stock reserved'
        }]
      }], { session: session || undefined });

      const createdOrder = order[0];

      // If delivery requested, generate a Delivery job in available state
      if (request.deliveryPref === 'delivery') {
        let weightKg = qty;
        if (listing.unit === 'g') weightKg = Math.max(0.1, qty / 1000);
        else if (listing.unit === 'quintal') weightKg = qty * 100;
        else if (listing.unit === 'litre') weightKg = qty * 1.0;
        else if (['piece', 'bundle', 'jar', 'bag'].includes(listing.unit)) weightKg = Math.max(0.5, qty * 0.5);

        const feePaise = config.DELIVERY_RATE_PAISE_PER_KM * 10; // default 10km demo distance estimate
        const delivery = await Delivery.create([{
          orderId: createdOrder._id,
          pickup: {
            village: listing.village,
            taluka: listing.taluka,
            location: listing.location
          },
          drop: {
            village: request.dropVillage || 'Nashik City',
            taluka: listing.taluka,
            location: request.dropLocation
          },
          goodsSummary: `${listing.title.en} (${qty} ${listing.unit})`,
          weightKg: Math.round(weightKg * 10) / 10,
          distanceKm: 10,
          feePaise,
          collectCashPaise: request.paymentMethod === 'cod' ? totalPaise : 0,
          status: 'available',
          timeline: [{
            status: 'available',
            at: new Date(),
            note: 'Delivery job opened for approved transport partners'
          }]
        }], { session: session || undefined });

        createdOrder.deliveryId = delivery[0]._id;
        await createdOrder.save({ session: session || undefined });
      }

      // Send Messages
      await Message.create([{
        recipientId: request.requesterId,
        actorId: user._id,
        type: 'request_approved',
        orderId: createdOrder._id,
        requestId: request._id,
        title: { mr: 'ऑर्डर मंजूर झाली!', en: 'Order Approved!' },
        body: {
          mr: `${listing.title.mr} साठी तुमची ऑर्डर मंजूर झाली आहे.`,
          en: `Your order for ${listing.title.en} has been approved.`
        }
      }], { session: session || undefined });

      if (session) {
        await session.commitTransaction();
        session.endSession();
      }

      return { request, order: createdOrder };
    } catch (err) {
      if (session) {
        await session.abortTransaction();
        session.endSession();
      }
      if (err?.hasErrorLabel?.('TransientTransactionError') || err?.codeName === 'WriteConflict') {
        throw new AppError(ErrorCodes.INSUFFICIENT_STOCK, 'Stock has changed or is insufficient to approve this request', 409);
      }
      throw err;
    }
  }

  static async counterOffer(requestId, user, data) {
    const request = await Request.findById(requestId).populate('listingId');
    if (!request) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Request not found', 404);
    }

    if (request.sellerId.toString() !== user._id.toString()) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the seller can propose a counter-offer', 403);
    }

    assertValidTransition(request.status, 'countered');

    const version = (request.counter?.version || 0) + 1;
    const pricePerUnitPaise = data.pricePerUnitRupees ? Math.round(data.pricePerUnitRupees * 100) : request.listingId.pricePerUnitPaise;

    request.status = 'countered';
    request.counter = {
      quantity: data.quantity || request.quantity,
      pricePerUnitPaise,
      note: data.note,
      version
    };

    request.history.push({
      status: 'countered',
      at: new Date(),
      by: user._id,
      note: `Counter-offer version ${version}: ${data.quantity || request.quantity} ${request.unit} @ ₹${(pricePerUnitPaise / 100).toFixed(2)}`
    });

    await request.save();

    await Message.create({
      recipientId: request.requesterId,
      actorId: user._id,
      type: 'request_countered',
      requestId: request._id,
      title: { mr: 'विक्रेत्याची प्रति-ऑफर (Counter)', en: 'Seller Counter-Offer' },
      body: {
        mr: `विक्रेत्याने नवीन प्रमाण किंवा दर प्रस्तावित केला आहे`,
        en: `Seller proposed: ${data.quantity || request.quantity} ${request.unit} @ ₹${(pricePerUnitPaise / 100).toFixed(2)}`
      }
    });

    return request;
  }

  static async respondCounter(requestId, user, action, note) {
    const request = await Request.findById(requestId).populate('listingId');
    if (!request) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Request not found', 404);
    }

    if (request.requesterId.toString() !== user._id.toString()) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can respond to a counter-offer', 403);
    }

    if (request.status !== 'countered') {
      throw new AppError(ErrorCodes.CONFLICT, 'Request is not in countered status', 409);
    }

    if (action === 'accept') {
      // Update quantity to counter quantity
      if (request.counter && request.counter.quantity) {
        request.quantity = request.counter.quantity;
      }
      return this._executeApproval(request, user, note || 'Buyer accepted counter offer');
    } else {
      request.status = 'cancelled';
      request.history.push({
        status: 'cancelled',
        at: new Date(),
        by: user._id,
        note: note || 'Buyer declined counter offer'
      });
      await request.save();
      return { request };
    }
  }

  static async getRequests({ user, scope = 'mine', status }) {
    const filter = {};
    if (scope === 'incoming') {
      filter.sellerId = user._id;
    } else {
      filter.requesterId = user._id;
    }
    if (status) {
      filter.status = status;
    }
    const docs = await Request.find(filter)
      .populate('listingId')
      .populate('requesterId', 'name phone village')
      .populate('sellerId', 'name phone village')
      .sort({ createdAt: -1 });

    return docs.map(r => {
      const doc = r.toObject ? r.toObject() : r;
      if (doc.listingId && doc.listingId.location && Array.isArray(doc.listingId.location.coordinates)) {
        const [lng, lat] = doc.listingId.location.coordinates;
        doc.listingId.location.coordinates = [
          Math.round(lng * 100) / 100,
          Math.round(lat * 100) / 100
        ];
      }
      return doc;
    });
  }

  static async getById(id, user) {
    const request = await Request.findById(id)
      .populate('listingId')
      .populate('requesterId', 'name phone village')
      .populate('sellerId', 'name phone village');
    if (!request) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Request not found', 404);
    }
    const uid = user._id.toString();
    const idOf = (v) => (v && v._id ? v._id : v).toString();
    if (user.role !== 'team' && idOf(request.requesterId) !== uid && idOf(request.sellerId) !== uid) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You do not have access to this request', 403);
    }
    const doc = request.toObject ? request.toObject() : request;
    if (doc.listingId && doc.listingId.location && Array.isArray(doc.listingId.location.coordinates)) {
      const [lng, lat] = doc.listingId.location.coordinates;
      doc.listingId.location.coordinates = [
        Math.round(lng * 100) / 100,
        Math.round(lat * 100) / 100
      ];
    }
    return doc;
  }
}
