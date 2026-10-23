import { AppError, ErrorCodes } from '../core/errors.js';

export function notImplemented(featureName = 'This feature', phase = 'B4') {
  return (req, res, next) => {
    next(new AppError(
      ErrorCodes.NOT_IMPLEMENTED,
      `${featureName} is planned for Phase ${phase} and is not yet implemented.`,
      501,
      null,
      phase
    ));
  };
}
