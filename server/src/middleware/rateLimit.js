import { RateLimit } from '../models/RateLimit.js';
import { AppError, ErrorCodes } from '../core/errors.js';

export function rateLimit({ keyPrefix = 'rl', max = 60, windowSeconds = 60 }) {
  return async (req, res, next) => {
    try {
      let identifier;
      if (req.user) {
        identifier = req.user._id.toString();
      } else if (keyPrefix === 'login' && req.body?.phone) {
        const cleanPhone = String(req.body.phone).replace(/\s+/g, '');
        identifier = `${req.ip || 'anon'}:${cleanPhone}`;
      } else {
        identifier = req.ip || 'anonymous';
      }
      const key = `${keyPrefix}:${identifier}`;
      req._rateLimitKey = key; // store for controller to clear on success

      const now = new Date();
      const expiresAt = new Date(now.getTime() + windowSeconds * 1000);

      // For login: check existing count WITHOUT incrementing yet
      // (increment only happens on failure, via auth.controller)
      if (keyPrefix === 'login') {
        const existing = await RateLimit.findOne({ key });
        if (existing && existing.count >= max) {
          return next(new AppError(ErrorCodes.RATE_LIMITED, 'Too many failed login attempts. Please wait 15 minutes before trying again.', 429));
        }
        next();
        return;
      }

      const record = await RateLimit.findOneAndUpdate(
        { key },
        {
          $inc: { count: 1 },
          $setOnInsert: { key, expiresAt }
        },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );

      if (record.count > max) {
        return next(new AppError(ErrorCodes.RATE_LIMITED, 'Too many requests, please try again later', 429));
      }

      next();
    } catch (err) {
      // In case of DB hiccups, do not block regular traffic
      next();
    }
  };
}
