import { AppError, ErrorCodes } from '../core/errors.js';

export const RequestTransitions = {
  pending: ['approved', 'rejected', 'countered', 'cancelled'],
  countered: ['approved', 'cancelled'],
  approved: [],
  rejected: [],
  cancelled: []
};

/**
 * Validates whether transition from current status to target status is permitted.
 */
export function assertValidTransition(currentStatus, targetStatus) {
  const allowed = RequestTransitions[currentStatus] || [];
  if (!allowed.includes(targetStatus)) {
    throw new AppError(
      ErrorCodes.INVALID_TRANSITION,
      `Cannot transition request from '${currentStatus}' to '${targetStatus}'`,
      409
    );
  }
}
