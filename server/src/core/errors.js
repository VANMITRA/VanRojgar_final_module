export class AppError extends Error {
  /**
   * @param {string} code Stable UPPER_SNAKE code
   * @param {string} message Human readable error message
   * @param {number} statusCode HTTP status code
   * @param {Record<string, string>|null} [fields] Field validation errors
   * @param {string|null} [phase] Architecture phase if not implemented
   */
  constructor(code, message, statusCode = 400, fields = null, phase = null) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.statusCode = statusCode;
    this.fields = fields;
    this.phase = phase;
  }
}

export const ErrorCodes = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  UNAUTHENTICATED: 'UNAUTHENTICATED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  CONFLICT: 'CONFLICT',
  INSUFFICIENT_STOCK: 'INSUFFICIENT_STOCK',
  BULK_REASON_REQUIRED: 'BULK_REASON_REQUIRED',
  RESTRICTED_ITEM: 'RESTRICTED_ITEM',
  INVALID_TRANSITION: 'INVALID_TRANSITION',
  RATE_LIMITED: 'RATE_LIMITED',
  NOT_IMPLEMENTED: 'NOT_IMPLEMENTED',
  INTERNAL: 'INTERNAL'
};
