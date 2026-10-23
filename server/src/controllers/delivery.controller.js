import { DeliveryService } from '../services/delivery.service.js';
import { successEnvelope } from '../core/serializers.js';

export class DeliveryController {
  static async apply(req, res, next) {
    try {
      const partner = await DeliveryService.apply(req.user, req.body);
      return res.status(201).json(successEnvelope(partner));
    } catch (err) {
      next(err);
    }
  }

  static async getMyProfile(req, res, next) {
    try {
      const partner = await DeliveryService.getMyProfile(req.user);
      return res.json(successEnvelope(partner));
    } catch (err) {
      next(err);
    }
  }

  static async setAvailability(req, res, next) {
    try {
      const partner = await DeliveryService.setAvailability(req.user, req.body.available);
      return res.json(successEnvelope(partner));
    } catch (err) {
      next(err);
    }
  }

  static async getAvailableJobs(req, res, next) {
    try {
      const jobs = await DeliveryService.getAvailableJobs(req.user);
      return res.json(successEnvelope(jobs));
    } catch (err) {
      next(err);
    }
  }

  static async claimJob(req, res, next) {
    try {
      const delivery = await DeliveryService.claimJob(req.params.id, req.user);
      return res.json(successEnvelope(delivery));
    } catch (err) {
      next(err);
    }
  }

  static async updateJobStatus(req, res, next) {
    try {
      const delivery = await DeliveryService.updateJobStatus(
        req.params.id,
        req.user,
        req.body.status,
        req.body.note
      );
      return res.json(successEnvelope(delivery));
    } catch (err) {
      next(err);
    }
  }

  static async getMyDeliveries(req, res, next) {
    try {
      const deliveries = await DeliveryService.getMyDeliveries(req.user);
      return res.json(successEnvelope(deliveries));
    } catch (err) {
      next(err);
    }
  }
}
