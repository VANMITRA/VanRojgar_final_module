import { TradeService } from '../services/trade.service.js';
import { successEnvelope } from '../core/serializers.js';

export class TradeController {
  static async createRequest(req, res, next) {
    try {
      const request = await TradeService.createRequest(req.user, req.body);
      return res.status(201).json(successEnvelope(request));
    } catch (err) {
      next(err);
    }
  }

  static async updateStatus(req, res, next) {
    try {
      const { action, note } = req.body;
      const result = await TradeService.updateStatus(req.params.id, req.user, action, note);
      return res.json(successEnvelope(result));
    } catch (err) {
      next(err);
    }
  }

  static async counterOffer(req, res, next) {
    try {
      const request = await TradeService.counterOffer(req.params.id, req.user, req.body);
      return res.json(successEnvelope(request));
    } catch (err) {
      next(err);
    }
  }

  static async respondCounter(req, res, next) {
    try {
      const { action, note } = req.body;
      const result = await TradeService.respondCounter(req.params.id, req.user, action, note);
      return res.json(successEnvelope(result));
    } catch (err) {
      next(err);
    }
  }

  static async getRequests(req, res, next) {
    try {
      const requests = await TradeService.getRequests({
        user: req.user,
        scope: req.query.scope,
        status: req.query.status
      });
      return res.json(successEnvelope(requests));
    } catch (err) {
      next(err);
    }
  }

  static async getById(req, res, next) {
    try {
      const request = await TradeService.getById(req.params.id, req.user);
      return res.json(successEnvelope(request));
    } catch (err) {
      next(err);
    }
  }
}
