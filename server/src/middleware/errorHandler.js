import { AppError, ErrorCodes } from '../core/errors.js';
import { logger } from '../core/logger.js';

export function errorHandler(err, req, res, next) {
  const requestId = req.requestId || 'unknown';

  if (err instanceof AppError) {
    logger.warn({
      code: err.code,
      message: err.message,
      statusCode: err.statusCode,
      fields: err.fields,
      requestId
    }, 'Client AppError');

    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        fields: err.fields || undefined,
        phase: err.phase || undefined,
        requestId
      }
    });
  }

  // Handle mongoose ValidationError
  if (err.name === 'ValidationError') {
    const fields = {};
    for (const key in err.errors) {
      fields[key] = err.errors[key].message;
    }
    return res.status(422).json({
      success: false,
      error: {
        code: ErrorCodes.VALIDATION_ERROR,
        message: 'Validation failed',
        fields,
        requestId
      }
    });
  }

  // Handle duplicate key error (E11000)
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern || {})[0] || 'field';
    return res.status(409).json({
      success: false,
      error: {
        code: ErrorCodes.CONFLICT,
        message: `An entry with this ${field} already exists`,
        requestId
      }
    });
  }

  // Handle Mongoose CastError (bad ObjectId like /orders/nope) → 404
  if (err.name === 'CastError' && err.kind === 'ObjectId') {
    return res.status(404).json({
      success: false,
      error: {
        code: ErrorCodes.NOT_FOUND,
        message: 'Resource not found (invalid ID format)',
        requestId
      }
    });
  }

  if (err.type === 'entity.too.large') {
    return res.status(413).json({ success: false, error: { code: 'PAYLOAD_TOO_LARGE', message: 'Request body is too large', requestId } });
  }
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR', message: 'Malformed JSON body', requestId } });
  }

  // Unhandled internal server error
  logger.error({ err, requestId }, 'Unhandled Internal Server Error');

  return res.status(500).json({
    success: false,
    error: {
      code: ErrorCodes.INTERNAL,
      message: 'An unexpected internal error occurred',
      requestId
    }
  });
}
