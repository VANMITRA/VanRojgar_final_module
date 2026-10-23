import { Router } from 'express';
import { CatalogueController } from '../controllers/catalogue.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';
import { validate } from '../middleware/validate.js';
import { createResourceSchema } from '../validators/catalogue.schema.js';

export const catalogueRouter = Router();

catalogueRouter.get('/categories', CatalogueController.getCategories);
catalogueRouter.get('/gramsabhas', CatalogueController.getGramSabhas);
catalogueRouter.get('/gramsabhas/:id', CatalogueController.getGramSabhaDetail);
catalogueRouter.get('/resources', CatalogueController.getResources);
catalogueRouter.post('/resources', authenticate, authorize('gramsabha'), validate(createResourceSchema), CatalogueController.createResource);
