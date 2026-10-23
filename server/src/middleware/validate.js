import { AppError, ErrorCodes } from '../core/errors.js';

export function validate(schema, source = 'body') {
  return async (req, res, next) => {
    try {
      const dataToValidate = source === 'query' ? { ...req.query } : req[source];
      const parsed = await schema.parseAsync(dataToValidate);
      if (source === 'query') {
        req.validatedQuery = parsed;
      } else {
        req[source] = parsed;
      }
      next();
    } catch (err) {
      if (err.errors) {
        const fields = {};
        for (const issue of err.errors) {
          const path = issue.path.join('.') || 'root';
          fields[path] = issue.message;
        }
        return next(new AppError(ErrorCodes.VALIDATION_ERROR, 'Validation failed for request parameters', 422, fields));
      }
      next(err);
    }
  };
}
