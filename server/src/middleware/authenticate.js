import jwt from 'jsonwebtoken';
import { config } from '../core/config.js';
import { AppError, ErrorCodes } from '../core/errors.js';
import { User } from '../models/User.js';
import { normaliseRole } from '../core/roles.js';

export async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError(ErrorCodes.UNAUTHENTICATED, 'Authorization token required', 401);
    }

    const token = authHeader.substring(7);
    let decoded;
    try {
      decoded = jwt.verify(token, config.JWT_SECRET);
    } catch (jwtErr) {
      throw new AppError(ErrorCodes.UNAUTHENTICATED, 'Invalid or expired token', 401);
    }

    if (!decoded.sub) {
      throw new AppError(ErrorCodes.UNAUTHENTICATED, 'Invalid token payload', 401);
    }

    const user = await User.findById(decoded.sub);
    if (!user || user.status === 'suspended') {
      throw new AppError(ErrorCodes.UNAUTHENTICATED, 'User not found or account suspended', 401);
    }

    user.role = normaliseRole(user.role); // an old `villager` account acts as a CFR holder
    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
}
