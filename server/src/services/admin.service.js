import { GramSabha } from '../models/GramSabha.js';
import { DeliveryPartner } from '../models/DeliveryPartner.js';
import { RestrictedItem } from '../models/RestrictedItem.js';
import { AuditLog } from '../models/AuditLog.js';
import { Message } from '../models/Message.js';
import { User } from '../models/User.js';
import { AppError, ErrorCodes } from '../core/errors.js';

export class AdminService {
  static async listPendingGramSabhas() {
    return GramSabha.find({ verificationStatus: 'pending' }).sort({ createdAt: -1 });
  }

  static async verifyGramSabha(id, user, { status, note }) {
    const gs = await GramSabha.findById(id);
    if (!gs) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Gram Sabha not found', 404);
    }

    gs.verificationStatus = status;
    gs.verificationNote = note;

    if (gs.claim && gs.claim.status === 'pending') {
      gs.claim.status = status === 'verified' ? 'approved' : 'rejected';
      gs.claim.note = note || (status === 'verified' ? 'Approved by district administration' : 'Rejected by team');
      if (status === 'verified') {
        gs.contactPerson = `${gs.claim.claimantName} (${gs.claim.designation || 'सचिव'})`;
        gs.phone = gs.claim.claimantPhone;
      }
    }

    await gs.save();

    await AuditLog.create({
      actorId: user._id,
      action: `gramsabha_verification_${status}`,
      targetType: 'GramSabha',
      targetId: gs._id,
      note
    });

    const secretary = await User.findOne({ gramSabhaId: gs._id, role: 'gramsabha' });
    if (secretary) {
      await Message.create({
        recipientId: secretary._id,
        actorId: user._id,
        type: 'verification_update',
        title: {
          mr: status === 'verified' ? 'ग्रामसभा पडताळणी यशस्वी!' : 'ग्रामसभा पडताळणी अपडेट',
          en: status === 'verified' ? 'Gram Sabha Verified!' : 'Gram Sabha Verification Update'
        },
        body: {
          mr: `आपल्या ग्रामसभेची पडताळणी स्थिती: ${status}. ${note || ''}`,
          en: `Your Gram Sabha verification status is now: ${status}. ${note || ''}`
        }
      });
    }

    return gs;
  }

  static async listPendingPartners() {
    return DeliveryPartner.find({ approvalStatus: 'pending' })
      .populate('userId', 'name phone village taluka')
      .sort({ createdAt: -1 });
  }

  static async reviewPartner(id, user, { status, note }) {
    const partner = await DeliveryPartner.findById(id);
    if (!partner) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Delivery partner not found', 404);
    }

    partner.approvalStatus = status;
    partner.reviewNote = note;
    await partner.save();

    await AuditLog.create({
      actorId: user._id,
      action: `delivery_partner_${status}`,
      targetType: 'DeliveryPartner',
      targetId: partner._id,
      note
    });

    await Message.create({
      recipientId: partner.userId,
      actorId: user._id,
      type: status === 'approved' ? 'delivery_approved' : 'delivery_rejected',
      title: {
        mr: status === 'approved' ? 'डिलिव्हरी पार्टनर अर्ज मंजूर!' : 'डिलिव्हरी पार्टनर अर्ज नाकारला',
        en: status === 'approved' ? 'Delivery Partner Application Approved!' : 'Delivery Partner Application Rejected'
      },
      body: {
        mr: status === 'approved'
          ? 'तुमचा डिलिव्हरी पार्टनर अर्ज मंजूर झाला आहे. आता तुम्ही डिलिव्हरी कामे स्वीकारू शकता.'
          : `तुमचा अर्ज नाकारण्यात आला: ${note || 'कृपया पडताळणी तपशील तपासा.'}`,
        en: status === 'approved'
          ? 'Your application has been approved. You can now accept delivery jobs.'
          : `Your application was rejected: ${note || 'Please review your details.'}`
      }
    });

    return partner;
  }

  static async createRestrictedItem(user, data) {
    const item = await RestrictedItem.create({
      name: { mr: data.nameMr, en: data.nameEn },
      terms: data.terms.map(t => t.toLowerCase().trim()),
      reason: { mr: data.reasonMr, en: data.reasonEn },
      schedule: data.schedule || 'Scheduled Specie / FRA restriction',
      verified: false
    });

    await AuditLog.create({
      actorId: user._id,
      action: 'restricted_item_created',
      targetType: 'RestrictedItem',
      targetId: item._id,
      note: `Added ${data.nameEn}`
    });

    return item;
  }
}
