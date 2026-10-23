import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/authenticate.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { registerSchema, loginSchema, updateProfileSchema } from '../validators/auth.schema.js';
import { config, parseRateLimit } from '../core/config.js';

export const authRouter = Router();

const loginLimit = parseRateLimit(config.RATE_LIMIT_LOGIN, 120, 900);
const loginMax = config.NODE_ENV === 'development' ? 500 : loginLimit.max;

authRouter.post('/register', validate(registerSchema), AuthController.register);
authRouter.post('/login', rateLimit({ keyPrefix: 'login', max: loginMax, windowSeconds: loginLimit.windowSeconds }), validate(loginSchema), AuthController.login);
authRouter.get('/me', authenticate, AuthController.me);
authRouter.patch('/profile', authenticate, validate(updateProfileSchema), AuthController.updateProfile);
authRouter.post('/logout', authenticate, AuthController.logout);
