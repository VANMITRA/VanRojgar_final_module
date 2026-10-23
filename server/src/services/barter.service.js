import { BarterRequest } from '../models/BarterRequest.js';
import { Listing } from '../models/Listing.js';
import { Order } from '../models/Order.js';
import { Message } from '../models/Message.js';
import { AppError, ErrorCodes } from '../core/errors.js';

export class BarterService {
  static async create(user, data) {
    if (user.role === 'buyer') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'External buyers cannot participate in barter offers', 403);
    }

    const targetListing = await Listing.findById(data.toListId);
    if (!targetListing) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Target listing not found', 404);
    }

    if (targetListing.mode !== 'barter' && targetListing.mode !== 'both') {
      throw new AppError(ErrorCodes.CONFLICT, 'Target listing is not available for barter', 409);
    }

    if (targetListing.ownerId.toString() === user._id.toString()) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Cannot barter with yourself', 403);
    }

    const barter = await BarterRequest.create({
      fromUserId: user._id,
      toOwnerId: targetListing.ownerId,
      toListId: targetListing._id,
      fromListId: data.fromListId,
      offered: {
        title: data.offeredTitle,
        quantity: data.offeredQuantity,
        unit: data.offeredUnit
      },
      wanted: {
        quantity: data.wantedQuantity
      },
      note: data.note,
      status: 'pending',
      versions: [{
        version: 1,
        offered: {
          title: data.offeredTitle,
          quantity: data.offeredQuantity,
          unit: data.offeredUnit
        },
        wanted: {
          quantity: data.wantedQuantity
        },
        proposedBy: user._id,
        note: data.note,
        at: new Date()
      }],
      acceptances: {
        from: { version: 1, at: new Date() }
      }
    });

    await Message.create({
      recipientId: targetListing.ownerId,
      actorId: user._id,
      type: 'barter_created',
      barterId: barter._id,
      title: { mr: 'नवीन वस्तुविनिमय (Barter) ऑफर!', en: 'New Barter Offer!' },
      body: {
        mr: `${user.name} यांनी ${data.offeredTitle} च्या बदल्यात वस्तुविनिमयाची ऑफर दिली आहे`,
        en: `${user.name} offered ${data.offeredTitle} in exchange for your listing`
      }
    });

    return barter;
  }

  static async respond(barterId, user, action, counterData = {}) {
    const barter = await BarterRequest.findById(barterId).populate('toListId');
    if (!barter) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Barter offer not found', 404);
    }

    const isRecipient = barter.toOwnerId.toString() === user._id.toString();
    const isProposer = barter.fromUserId.toString() === user._id.toString();

    if (!isRecipient && !isProposer) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You are not a participant in this barter offer', 403);
    }

    const latestVersion = barter.versions[barter.versions.length - 1];
    if (!['pending', 'countered'].includes(barter.status)) {
      throw new AppError(ErrorCodes.CONFLICT, `This barter offer is already ${barter.status}`, 409);
    }

    if (action === 'accept') {
      if (isRecipient) {
        barter.acceptances.to = { version: latestVersion.version, at: new Date() };
      } else {
        barter.acceptances.from = { version: latestVersion.version, at: new Date() };
      }

      // Check mutual acceptance on the same version
      if (
        barter.acceptances.from?.version === latestVersion.version &&
        barter.acceptances.to?.version === latestVersion.version
      ) {
        barter.status = 'accepted';

        // Form two-sided order
        await Order.create({
          requestId: barter._id,
          buyerId: barter.fromUserId,
          sellerId: barter.toOwnerId,
          gramSabhaId: barter.toListId.gramSabhaId,
          line: {
            listingId: barter.toListId._id,
            title: barter.toListId.title,
            quantity: latestVersion.wanted.quantity,
            unit: barter.toListId.unit,
            pricePerUnitPaise: 0,
            totalPaise: 0
          },
          fulfilment: { method: 'pickup' },
          orderStatus: 'approved',
          paymentStatus: 'not_required',
          timeline: [{
            status: 'approved',
            at: new Date(),
            actorId: user._id,
            note: 'Mutual barter agreement terms accepted'
          }]
        });
      }

      await barter.save();
      return barter;
    } else if (action === 'reject') {
      barter.status = 'rejected';
      await barter.save();
      return barter;
    } else if (action === 'counter') {
      const newVersionNum = latestVersion.version + 1;
      barter.status = 'countered';
      barter.versions.push({
        version: newVersionNum,
        offered: {
          title: counterData.counterOfferedTitle || latestVersion.offered.title,
          quantity: counterData.counterOfferedQuantity || latestVersion.offered.quantity,
          unit: latestVersion.offered.unit
        },
        wanted: {
          quantity: counterData.counterWantedQuantity || latestVersion.wanted.quantity
        },
        proposedBy: user._id,
        note: counterData.note,
        at: new Date()
      });

      if (isRecipient) {
        barter.acceptances.to = { version: newVersionNum, at: new Date() };
        barter.acceptances.from = null;
      } else {
        barter.acceptances.from = { version: newVersionNum, at: new Date() };
        barter.acceptances.to = null;
      }

      await barter.save();
      return barter;
    }
  }

  static async getOffers({ user, scope = 'mine' }) {
    const filter = scope === 'incoming'
      ? { toOwnerId: user._id }
      : { fromUserId: user._id };

    return BarterRequest.find(filter)
      .populate('toListId')
      .populate('fromUserId', 'name phone village')
      .populate('toOwnerId', 'name phone village')
      .sort({ createdAt: -1 });
  }
}
