import { ListingService } from '../services/listing.service.js';
import { successEnvelope } from '../core/serializers.js';

export class ListingController {
  static async create(req, res, next) {
    try {
      const listing = await ListingService.create(req.user, req.body);
      return res.status(201).json(successEnvelope(listing));
    } catch (err) {
      next(err);
    }
  }

  static async map(req, res, next) {
    try {
      const points = await ListingService.mapPoints({ productCode: req.query.product });
      return res.json(successEnvelope({ points }));
    } catch (err) {
      next(err);
    }
  }

  static async getByCode(req, res, next) {
    try {
      const listing = await ListingService.getByItemCode(req.params.code);
      return res.json(successEnvelope(listing));
    } catch (err) {
      next(err);
    }
  }

  static async getById(req, res, next) {
    try {
      const listing = await ListingService.getById(req.params.id, req.user);
      return res.json(successEnvelope(listing));
    } catch (err) {
      next(err);
    }
  }

  static async update(req, res, next) {
    try {
      const listing = await ListingService.update(req.params.id, req.user, req.body);
      return res.json(successEnvelope(listing));
    } catch (err) {
      next(err);
    }
  }

  static async updateStatus(req, res, next) {
    try {
      const listing = await ListingService.updateStatus(req.params.id, req.user, req.body.status);
      return res.json(successEnvelope(listing));
    } catch (err) {
      next(err);
    }
  }

  static async getMine(req, res, next) {
    try {
      const listings = await ListingService.getMine(req.user);
      return res.json(successEnvelope(listings));
    } catch (err) {
      next(err);
    }
  }
}
