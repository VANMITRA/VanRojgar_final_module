import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User } from '../models/User.js';
import { GramSabha } from '../models/GramSabha.js';
import { config } from '../core/config.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { VILLAGE_ROLES, isFarmerRole } from '../core/roles.js';
import { serializeUser } from '../core/serializers.js';
import { loadRaah, gramSabhaFields, SOURCE as RAAH_SOURCE } from '../seed/raah.js';


const { villages: DATASET, blockTowns: BLOCK_TOWNS } = loadRaah();

const norm = (t) => String(t ?? '').trim().toLowerCase().replace(/s+/g, ' ');

/** The dataset village for (village, taluka), by Marathi or English name, or undefined. */
export function findDatasetVillage(village, taluka) {
  return DATASET.find((v) => norm(v.taluka) === norm(taluka) && [v.nameMr, v.nameEn].some((n) => norm(n) === norm(village)));
}

export const isDatasetVillage = (village, taluka) => Boolean(findDatasetVillage(village, taluka));

export class AuthService {
  static async register(data) {
    const existing = await User.findOne({ phone: data.phone });
    if (existing) {
      throw new AppError(ErrorCodes.CONFLICT, 'User with this phone number is already registered', 409);
    }

    const salt = await bcrypt.genSalt(config.BCRYPT_COST);
    const passwordHash = await bcrypt.hash(data.password, salt);

    let gramSabhaId = data.gramSabhaId;

    // Only the villages of the dataset (the 14 CFR villages of the Raah Foundation report) can be registered.
    if (VILLAGE_ROLES.includes(data.role) && !isDatasetVillage(data.village, data.taluka)) {
      throw new AppError(ErrorCodes.VALIDATION_ERROR, 'This village is not in the VanRozgar dataset', 422);
    }

    if (data.role === 'gramsabha') {
      // Find matching Gram Sabha or create a new one
      let gs = await GramSabha.findOne({
        taluka: data.taluka,
        $or: [
          { 'village.mr': data.village },
          { 'village.en': data.village }
        ]
      });
      if (!gs) {
        // The database was not seeded yet: build the record of this dataset village now
        gs = await GramSabha.create({
          ...gramSabhaFields(findDatasetVillage(data.village, data.taluka), BLOCK_TOWNS),
          verificationStatus: 'pending',
          verificationNote: RAAH_SOURCE
        });
      }

      if (gs) {
        gramSabhaId = gs._id;
        // A record from the district CFR register (or a seeded demo village) is not owned by anyone yet:
        // the first person to register files a claim, and the team approves it before they can list.
        if (gs.verificationStatus === 'verified_seed' || !gs.claim || gs.claim.status === 'none') {
          gs.claim = {
            claimantName: data.name,
            claimantPhone: data.phone,
            designation: data.contactPerson || data.designation || 'ग्रामसभा सचिव (Secretary)',
            resolutionNo: data.resolutionNo || 'ठराव क्र. CFR/2026',
            status: 'pending',
            claimedAt: new Date()
          };
          // Do not demote verificationStatus on an unreviewed claim; keep verified_seed intact while claim is pending
          gs.verificationNote = `दावा दाखल: ${data.name} (${data.phone}) - प्रशासकीय मंजुरी प्रलंबित`;
          await gs.save();
        }
      }
    } else if (isFarmerRole(data.role) && !gramSabhaId && data.village) {
      // The same village name exists in several talukas, so use the taluka whenever the app sends it
      const gs = await GramSabha.findOne({
        ...(data.taluka ? { taluka: data.taluka } : {}),
        $or: [
          { 'village.mr': data.village },
          { 'village.en': data.village }
        ]
      });
      if (gs) {
        gramSabhaId = gs._id;
      }
    }

    const user = await User.create({
      name: data.name,
      phone: data.phone,
      email: data.email || undefined,
      businessName: data.businessName || undefined,
      city: data.city || undefined,
      role: data.role,
      language: data.language || 'mr',
      passwordHash,
      gramSabhaId,
      village: data.village,
      taluka: data.taluka,
      district: data.district || 'Nashik'
    });

    const token = jwt.sign(
      { sub: user._id.toString(), role: user.role },
      config.JWT_SECRET,
      { expiresIn: config.JWT_EXPIRES_IN }
    );

    return {
      token,
      user: serializeUser(user)
    };
  }

  static async login({ phone, password }) {
    const user = await User.findOne({ phone }).select('+passwordHash');
    if (!user) {
      // Avoid account enumeration: generic message
      throw new AppError(ErrorCodes.UNAUTHENTICATED, 'Invalid phone number or password', 401);
    }

    if (user.status === 'suspended') {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Your account has been suspended. Please contact Gram Sabha / support.', 403);
    }

    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) {
      throw new AppError(ErrorCodes.UNAUTHENTICATED, 'Invalid phone number or password', 401);
    }

    const token = jwt.sign(
      { sub: user._id.toString(), role: user.role },
      config.JWT_SECRET,
      { expiresIn: config.JWT_EXPIRES_IN }
    );

    return {
      token,
      user: serializeUser(user)
    };
  }

  static async updateProfile(userId, updateData) {
    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    );
    if (!user) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'User not found', 404);
    }
    return serializeUser(user);
  }
}
