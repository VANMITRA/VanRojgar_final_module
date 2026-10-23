import { CatalogueService } from '../services/catalogue.service.js';
import { successEnvelope, serializeGramSabha } from '../core/serializers.js';

export class CatalogueController {
  static async getCategories(req, res, next) {
    try {
      const categories = await CatalogueService.getCategories();
      return res.json(successEnvelope(categories));
    } catch (err) {
      next(err);
    }
  }

  static async getGramSabhas(req, res, next) {
    try {
      const gramsabhas = await CatalogueService.getGramSabhas(req.query);
      return res.json(successEnvelope(gramsabhas.map(serializeGramSabha)));
    } catch (err) {
      next(err);
    }
  }

  static async getGramSabhaDetail(req, res, next) {
    try {
      const detail = await CatalogueService.getGramSabhaDetail(req.params.id);
      return res.json(successEnvelope({
        ...detail,
        gramSabha: serializeGramSabha(detail.gramSabha)
      }));
    } catch (err) {
      next(err);
    }
  }

  static async getResources(req, res, next) {
    try {
      const resources = await CatalogueService.getResources(req.query);
      return res.json(successEnvelope(resources));
    } catch (err) {
      next(err);
    }
  }

  static async createResource(req, res, next) {
    try {
      const resource = await CatalogueService.createResource(req.user, req.body);
      return res.status(201).json(successEnvelope(resource));
    } catch (err) {
      next(err);
    }
  }
}
