import { ShopService } from '../services/shop.service.js';
import { successEnvelope } from '../core/serializers.js';

export class ShopController {
  static async products(req, res, next) {
    try {
      return res.json(successEnvelope(await ShopService.products(req.validatedQuery)));
    } catch (err) {
      next(err);
    }
  }

  static async sellers(req, res, next) {
    try {
      return res.json(successEnvelope(await ShopService.sellers(req.params.code, req.validatedQuery)));
    } catch (err) {
      next(err);
    }
  }

  static async home(req, res, next) {
    try {
      return res.json(successEnvelope(await ShopService.home()));
    } catch (err) {
      next(err);
    }
  }

  static async stock(req, res, next) {
    try {
      return res.json(successEnvelope(await ShopService.stock(req.validatedQuery.ids)));
    } catch (err) {
      next(err);
    }
  }

  static async checkout(req, res, next) {
    try {
      return res.status(201).json(successEnvelope(await ShopService.checkout(req.user, req.body)));
    } catch (err) {
      next(err);
    }
  }
}
