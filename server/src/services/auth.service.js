import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User } from '../models/User.js';
import { GramSabha } from '../models/GramSabha.js';
import { config } from '../core/config.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { serializeUser } from '../core/serializers.js';
import { buildSearchTokens } from '../core/normalise.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class AuthService {
  static async register(data) {
    const existing = await User.findOne({ phone: data.phone });
    if (existing) {
      throw new AppError(ErrorCodes.CONFLICT, 'User with this phone number is already registered', 409);
    }

    const salt = await bcrypt.genSalt(config.BCRYPT_COST);
    const passwordHash = await bcrypt.hash(data.password, salt);

    let gramSabhaId = data.gramSabhaId;

    if (data.role === 'gramsabha') {
      // Find matching Gram Sabha or create a new one
      let gs = await GramSabha.findOne({
        taluka: data.taluka,
        $or: [
          { 'village.mr': data.village },
          { 'village.en': data.village }
        ]
      });

      if (gs) {
        gramSabhaId = gs._id;
        // Seeded or unverified Gram Sabha: record formal office-bearer claim
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
        let coords = [73.7898, 19.9975];
        try {
          const villagePointsRaw = JSON.parse(fs.readFileSync(path.join(__dirname, '../seed/data/village_points.json'), 'utf-8'));
          const match = villagePointsRaw.find(p =>
            p.taluka?.toLowerCase() === data.taluka?.toLowerCase() &&
            (p.villageMr === data.village || p.villageEn?.toLowerCase() === data.village?.toLowerCase())
          ) || villagePointsRaw.find(p => p.taluka?.toLowerCase() === data.taluka?.toLowerCase());
          if (match?.coordinates) coords = match.coordinates;
        } catch (_) {}

        gs = await GramSabha.create({
          name: { mr: `ग्रामसभा ${data.village}`, en: `Gram Sabha ${data.village}` },
          village: { mr: data.village, en: data.village },
          taluka: data.taluka,
          district: data.district || 'Nashik',
          contactPerson: data.contactPerson || data.name,
          phone: data.phone,
          verificationStatus: 'pending',
          location: {
            type: 'Point',
            coordinates: coords
          },
          cfr: {
            rights: ['3(1)(c)', '3(1)(d)', '3(1)(i)'],
            approvedAreaHa: 45.5,
            claimCount: 1
          },
          searchTerms: buildSearchTokens(data.village, data.taluka, 'Gram Sabha')
        });
        gramSabhaId = gs._id;
      }
    } else if (data.role === 'villager' && !gramSabhaId && data.village) {
      const gs = await GramSabha.findOne({
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
