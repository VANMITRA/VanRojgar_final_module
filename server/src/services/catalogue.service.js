import { Category } from '../models/Category.js';
import { GramSabha } from '../models/GramSabha.js';
import { Resource } from '../models/Resource.js';
import { CfrClaim } from '../models/CfrClaim.js';
import { VillageProfile } from '../models/VillageProfile.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { buildSearchTokens } from '../core/normalise.js';

function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export class CatalogueService {
  static async getCategories() {
    return Category.find().sort({ order: 1 });
  }

  static async getGramSabhas({ taluka, verified, limit = 50 }) {
    const filter = {};
    if (taluka) filter.taluka = taluka;
    if (verified === true || verified === 'true') {
      filter.verificationStatus = { $in: ['verified', 'verified_seed'] };
    }
    return GramSabha.find(filter).limit(Number(limit));
  }

  static async getGramSabhaDetail(id) {
    const gs = await GramSabha.findById(id);
    if (!gs) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Gram Sabha not found', 404);
    }

    const claims = await CfrClaim.find({
      $or: [
        { gramSabhaId: gs._id },
        { taluka: gs.taluka, village: gs.village.mr }
      ]
    });

    let villageProfile = null;
    if (gs.censusCode) {
      villageProfile = await VillageProfile.findOne({ censusCode: gs.censusCode });
    }
    if (!villageProfile) {
      villageProfile = await VillageProfile.findOne({
        taluka: gs.taluka,
        villageName: { $regex: new RegExp(escapeRegex(gs.village.mr), 'i') }
      });
    }

    return {
      gramSabha: gs,
      claims,
      villageProfile
    };
  }

  static async getResources({ gramSabhaId, categoryId }) {
    const filter = {};
    if (gramSabhaId) filter.gramSabhaId = gramSabhaId;
    if (categoryId) filter.categoryId = categoryId;
    return Resource.find(filter).populate('categoryId');
  }

  static async createResource(user, data) {
    if (user.role !== 'gramsabha' || !user.gramSabhaId) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only Gram Sabha representatives can create catalogue resources', 403);
    }

    const searchTerms = buildSearchTokens(data.nameMr, data.nameEn);
    return Resource.create({
      gramSabhaId: user.gramSabhaId,
      name: { mr: data.nameMr, en: data.nameEn },
      categoryId: data.categoryId,
      unit: data.unit || 'kg',
      seasonMonths: data.seasonMonths || [],
      description: data.description,
      searchTerms
    });
  }
}
