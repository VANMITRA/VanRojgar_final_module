import { IdempotencyKey } from '../models/IdempotencyKey.js';

export function idempotencyMiddleware() {
  return async (req, res, next) => {
    const key = req.headers['idempotency-key'];
    if (!key || !req.user) {
      return next();
    }

    try {
      const existing = await IdempotencyKey.findOne({
        userId: req.user._id,
        key: String(key)
      });

      if (existing && existing.response) {
        return res.status(existing.response.status).json(existing.response.body);
      }

      // Capture original json send
      const originalJson = res.json.bind(res);
      res.json = (body) => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          IdempotencyKey.create({
            userId: req.user._id,
            key: String(key),
            response: {
              status: res.statusCode,
              body
            }
          }).catch(() => {});
        }
        return originalJson(body);
      };

      next();
    } catch (err) {
      next();
    }
  };
}
