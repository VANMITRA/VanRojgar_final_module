import { BarterService } from '../services/barter.service.js';
import { successEnvelope } from '../core/serializers.js';

export class BarterController {
  static async create(req, res, next) {
    try {
      const barter = await BarterService.create(req.user, req.body);
      return res.status(201).json(successEnvelope(barter));
    } catch (err) {
      next(err);
    }
  }

  static async respond(req, res, next) {
    try {
      const { action, note, ...counterData } = req.body;
      const barter = await BarterService.respond(req.params.id, req.user, action, { ...counterData, note });
      return res.json(successEnvelope(barter));
    } catch (err) {
      next(err);
    }
  }

  static async getOffers(req, res, next) {
    try {
      const offers = await BarterService.getOffers({
        user: req.user,
        scope: req.query.scope
      });
      return res.json(successEnvelope(offers));
    } catch (err) {
      next(err);
    }
  }
}
