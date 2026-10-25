import { Router } from 'express';
import { ListingController } from '../controllers/listing.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { validate } from '../middleware/validate.js';
import { createListingSchema, updateListingSchema, updateListingStatusSchema } from '../validators/listing.schema.js';

export const listingRouter = Router();

listingRouter.post('/', authenticate, validate(createListingSchema), ListingController.create);
listingRouter.get('/mine', authenticate, ListingController.getMine);
listingRouter.get('/map', ListingController.map);
listingRouter.get('/code/:code', ListingController.getByCode);
listingRouter.get('/:id', ListingController.getById);
listingRouter.patch('/:id', authenticate, validate(updateListingSchema), ListingController.update);
listingRouter.patch('/:id/status', authenticate, validate(updateListingStatusSchema), ListingController.updateStatus);
