import { AdminService } from '../services/admin.service.js';
import { ListingService } from '../services/listing.service.js';
import { successEnvelope, serializeGramSabha } from '../core/serializers.js';

export class AdminController {
  static async listPendingGramSabhas(req, res, next) {
    try {
      const gss = await AdminService.listPendingGramSabhas();
      return res.json(successEnvelope(gss.map((g) => serializeGramSabha(g, { includeClaim: true }))));
    } catch (err) {
      next(err);
    }
  }

  static async verifyGramSabha(req, res, next) {
    try {
      const gs = await AdminService.verifyGramSabha(req.params.id, req.user, req.body);
      return res.json(successEnvelope(serializeGramSabha(gs, { includeClaim: true })));
    } catch (err) {
      next(err);
    }
  }

  static async listPendingPartners(req, res, next) {
    try {
      const partners = await AdminService.listPendingPartners();
      return res.json(successEnvelope(partners));
    } catch (err) {
      next(err);
    }
  }

  static async reviewPartner(req, res, next) {
    try {
      const partner = await AdminService.reviewPartner(req.params.id, req.user, req.body);
      return res.json(successEnvelope(partner));
    } catch (err) {
      next(err);
    }
  }

  static async createRestrictedItem(req, res, next) {
    try {
      const item = await AdminService.createRestrictedItem(req.user, req.body);
      return res.status(201).json(successEnvelope(item));
    } catch (err) {
      next(err);
    }
  }

  static async updateListingStatus(req, res, next) {
    try {
      const listing = await ListingService.updateStatus(req.params.id, req.user, req.body.status);
      return res.json(successEnvelope(listing));
    } catch (err) {
      next(err);
    }
  }
}
