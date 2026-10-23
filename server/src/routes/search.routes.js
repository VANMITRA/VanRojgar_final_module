import { Router } from 'express';
import { SearchController } from '../controllers/search.controller.js';
import { validate } from '../middleware/validate.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { searchQuerySchema } from '../validators/search.schema.js';
import { config, parseRateLimit } from '../core/config.js';

export const searchRouter = Router();

const searchLimit = parseRateLimit(config.RATE_LIMIT_SEARCH, 120, 60);

searchRouter.get(
  '/',
  rateLimit({ keyPrefix: 'search', max: searchLimit.max, windowSeconds: searchLimit.windowSeconds }),
  validate(searchQuerySchema, 'query'),
  SearchController.search
);
