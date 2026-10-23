import { Router } from 'express';
import { AdminController } from '../controllers/admin.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';
import { validate } from '../middleware/validate.js';
import {
  verifyGramSabhaSchema,
  reviewPartnerSchema,
  createRestrictedItemSchema
} from '../validators/admin.schema.js';
import { updateListingStatusSchema } from '../validators/listing.schema.js';

export const adminRouter = Router();

// Restricted strictly to 'team' role
adminRouter.use(authenticate, authorize('team'));

adminRouter.get('/gramsabhas', AdminController.listPendingGramSabhas);
adminRouter.patch('/gramsabhas/:id/verification', validate(verifyGramSabhaSchema), AdminController.verifyGramSabha);

adminRouter.get('/delivery-partners', AdminController.listPendingPartners);
adminRouter.patch('/delivery-partners/:id/approval', validate(reviewPartnerSchema), AdminController.reviewPartner);

adminRouter.post('/restricted-items', validate(createRestrictedItemSchema), AdminController.createRestrictedItem);
adminRouter.patch('/listings/:id/status', validate(updateListingStatusSchema), AdminController.updateListingStatus);
