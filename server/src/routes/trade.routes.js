import { Router } from 'express';
import { TradeController } from '../controllers/trade.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { validate } from '../middleware/validate.js';
import { idempotencyMiddleware } from '../middleware/idempotency.js';
import {
  createRequestSchema,
  updateRequestStatusSchema,
  counterRequestSchema,
  counterRespondSchema
} from '../validators/trade.schema.js';

export const tradeRouter = Router();

tradeRouter.post('/', authenticate, idempotencyMiddleware(), validate(createRequestSchema), TradeController.createRequest);
tradeRouter.get('/', authenticate, TradeController.getRequests);
tradeRouter.get('/:id', authenticate, TradeController.getById);
tradeRouter.patch('/:id/status', authenticate, validate(updateRequestStatusSchema), TradeController.updateStatus);
tradeRouter.post('/:id/counter', authenticate, validate(counterRequestSchema), TradeController.counterOffer);
tradeRouter.post('/:id/counter/respond', authenticate, validate(counterRespondSchema), TradeController.respondCounter);
tradeRouter.post('/:id/counter/accept', authenticate, (req, res, next) => { req.body = { action: 'accept' }; next(); }, TradeController.respondCounter);
tradeRouter.post('/:id/counter/decline', authenticate, (req, res, next) => { req.body = { action: 'decline' }; next(); }, TradeController.respondCounter);
