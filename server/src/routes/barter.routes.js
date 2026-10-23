import { Router } from 'express';
import { BarterController } from '../controllers/barter.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { validate } from '../middleware/validate.js';
import { createBarterSchema, respondBarterSchema } from '../validators/barter.schema.js';

export const barterRouter = Router();

barterRouter.post('/', authenticate, validate(createBarterSchema), BarterController.create);
barterRouter.get('/', authenticate, BarterController.getOffers);
barterRouter.post('/:id/respond', authenticate, validate(respondBarterSchema), BarterController.respond);
