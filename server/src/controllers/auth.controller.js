import { AuthService } from '../services/auth.service.js';
import { successEnvelope, serializeUser } from '../core/serializers.js';
import { RateLimit } from '../models/RateLimit.js';

export class AuthController {
  static async register(req, res, next) {
    try {
      const result = await AuthService.register(req.body);
      return res.status(201).json(successEnvelope(result));
    } catch (err) {
      next(err);
    }
  }

  static async login(req, res, next) {
    const key = req._rateLimitKey; // set by rateLimit middleware
    try {
      const result = await AuthService.login(req.body);
      // Success: clear the failed-login counter for this phone+IP
      if (key) await RateLimit.deleteOne({ key }).catch(() => {});
      return res.json(successEnvelope(result));
    } catch (err) {
      // Failure: increment the counter (only failed attempts count)
      if (key) {
        const now = new Date();
        const expiresAt = new Date(now.getTime() + 15 * 60 * 1000);
        await RateLimit.findOneAndUpdate(
          { key },
          { $inc: { count: 1 }, $setOnInsert: { key, expiresAt } },
          { upsert: true, setDefaultsOnInsert: true }
        ).catch(() => {});
      }
      next(err);
    }
  }

  static async me(req, res, next) {
    try {
      return res.json(successEnvelope(serializeUser(req.user)));
    } catch (err) {
      next(err);
    }
  }

  static async updateProfile(req, res, next) {
    try {
      const updated = await AuthService.updateProfile(req.user._id, req.body);
      return res.json(successEnvelope(updated));
    } catch (err) {
      next(err);
    }
  }

  static async logout(req, res) {
    return res.status(204).send();
  }
}
