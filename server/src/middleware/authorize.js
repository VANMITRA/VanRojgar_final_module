import { AppError, ErrorCodes } from '../core/errors.js';

export function authorize(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError(ErrorCodes.UNAUTHENTICATED, 'Authentication required', 401));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(new AppError(ErrorCodes.FORBIDDEN, `Role '${req.user.role}' is not authorized for this action`, 403));
    }

    next();
  };
}
