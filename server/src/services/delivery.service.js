import crypto from 'crypto';
import { DeliveryPartner } from '../models/DeliveryPartner.js';
import { Delivery } from '../models/Delivery.js';
import { Order } from '../models/Order.js';
import { User } from '../models/User.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { isFarmerRole } from '../core/roles.js';

export class DeliveryService {
  static async apply(user, data) {
    if (!isFarmerRole(user.role)) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only forest villagers can apply as delivery partners', 403);
    }

    const existing = await DeliveryPartner.findOne({ userId: user._id });
    if (existing) {
      throw new AppError(ErrorCodes.CONFLICT, 'You have already applied as a delivery partner', 409);
    }

    const licenceHash = crypto.createHash('sha256').update(data.licenceNumber).digest('hex');
    const licenceLast4 = data.licenceNumber.slice(-4);

    const partner = await DeliveryPartner.create({
      userId: user._id,
      vehicle: {
        type: data.vehicleType,
        number: data.vehicleNumber,
        capacityKg: data.capacityKg
      },
      licenceLast4,
      licenceHash,
      serviceTalukas: data.serviceTalukas,
      approvalStatus: 'pending'
    });

    await User.findByIdAndUpdate(user._id, { isDeliveryApplicant: true });
    return partner;
  }

  static async getMyProfile(user) {
    const partner = await DeliveryPartner.findOne({ userId: user._id });
    if (!partner) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Delivery partner profile not found', 404);
    }
    return partner;
  }

  static async setAvailability(user, available) {
    const partner = await DeliveryPartner.findOneAndUpdate(
      { userId: user._id },
      { $set: { available } },
      { new: true }
    );
    if (!partner) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Delivery partner profile not found', 404);
    }
    return partner;
  }

  static async getAvailableJobs(user) {
    const partner = await DeliveryPartner.findOne({ userId: user._id });
    if (!partner || partner.approvalStatus !== 'approved') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only approved delivery partners can view available transport jobs', 403);
    }

    return Delivery.find({
      status: 'available',
      $or: [
        { 'pickup.taluka': { $in: partner.serviceTalukas } },
        { 'drop.taluka': { $in: partner.serviceTalukas } }
      ]
    }).sort({ createdAt: -1 });
  }

  static async claimJob(deliveryId, user) {
    const partner = await DeliveryPartner.findOne({ userId: user._id });
    if (!partner || partner.approvalStatus !== 'approved') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only approved delivery partners can accept transport jobs', 403);
    }

    // Atomic claim to avoid race conditions
    const delivery = await Delivery.findOneAndUpdate(
      { _id: deliveryId, status: 'available' },
      {
        $set: {
          status: 'accepted',
          partnerId: partner._id
        },
        $push: {
          timeline: {
            status: 'accepted',
            at: new Date(),
            note: `Accepted by delivery partner ${user.name}`
          }
        }
      },
      { new: true }
    );

    if (!delivery) {
      throw new AppError(ErrorCodes.CONFLICT, 'Job is no longer available or was already accepted by another partner', 409);
    }

    // Mirror to order status
    await Order.findByIdAndUpdate(delivery.orderId, {
      orderStatus: 'delivery_assigned',
      $push: {
        timeline: {
          status: 'delivery_assigned',
          at: new Date(),
          actorId: user._id,
          note: `Delivery assigned to partner ${user.name}`
        }
      }
    });

    return delivery;
  }

  static async updateJobStatus(deliveryId, user, status, note = '') {
    const partner = await DeliveryPartner.findOne({ userId: user._id });
    if (!partner) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Delivery partner account not found', 403);
    }

    const delivery = await Delivery.findOne({ _id: deliveryId, partnerId: partner._id });
    if (!delivery) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Delivery job not found or not assigned to you', 404);
    }

    const NEXT = { accepted: 'picked_up', picked_up: 'on_the_way', on_the_way: 'delivered' };
    if (NEXT[delivery.status] !== status) {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot move delivery from '${delivery.status}' to '${status}'`, 409);
    }
    delivery.status = status;
    delivery.timeline.push({
      status,
      at: new Date(),
      note: note || `Status updated to ${status}`
    });
    await delivery.save();

    // Mirror to order status
    await Order.findByIdAndUpdate(delivery.orderId, {
      orderStatus: status,
      $push: {
        timeline: {
          status,
          at: new Date(),
          actorId: user._id,
          note: `Delivery status: ${status}`
        }
      }
    });

    if (status === 'delivered') {
      partner.earningsPaise += delivery.feePaise;
      partner.jobsCompleted += 1;
      await partner.save();
    }

    return delivery;
  }

  static async getMyDeliveries(user) {
    const partner = await DeliveryPartner.findOne({ userId: user._id });
    if (!partner) {
      return [];
    }
    return Delivery.find({ partnerId: partner._id }).sort({ createdAt: -1 });
  }
}
