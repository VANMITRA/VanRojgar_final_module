import { Router } from 'express';
import { DeliveryController } from '../controllers/delivery.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { validate } from '../middleware/validate.js';
import { idempotencyMiddleware } from '../middleware/idempotency.js';
import {
  deliveryApplicationSchema,
  updateAvailabilitySchema,
  updateDeliveryStatusSchema
} from '../validators/delivery.schema.js';

export const deliveryRouter = Router();

// Partner routes
deliveryRouter.post('/applications', authenticate, validate(deliveryApplicationSchema), DeliveryController.apply);
deliveryRouter.get('/me', authenticate, DeliveryController.getMyProfile);
deliveryRouter.patch('/me/availability', authenticate, validate(updateAvailabilitySchema), DeliveryController.setAvailability);

// Job routes
deliveryRouter.get('/jobs', authenticate, DeliveryController.getAvailableJobs);
deliveryRouter.post('/jobs/:id/accept', authenticate, idempotencyMiddleware(), DeliveryController.claimJob);
deliveryRouter.patch('/jobs/:id/status', authenticate, validate(updateDeliveryStatusSchema), DeliveryController.updateJobStatus);
deliveryRouter.patch('/:id/status', authenticate, validate(updateDeliveryStatusSchema), DeliveryController.updateJobStatus);
deliveryRouter.get('/mine', authenticate, DeliveryController.getMyDeliveries);
