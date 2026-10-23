import { SearchService } from '../services/search.service.js';
import { successEnvelope } from '../core/serializers.js';

export class SearchController {
  static async search(req, res, next) {
    try {
      const results = await SearchService.globalSearch(req.validatedQuery || req.query);
      return res.json(successEnvelope(results));
    } catch (err) {
      next(err);
    }
  }

  static async getListings(req, res, next) {
    try {
      const results = await SearchService.globalSearch(req.validatedQuery || req.query);
      return res.json(successEnvelope(results.listings));
    } catch (err) {
      next(err);
    }
  }
}
