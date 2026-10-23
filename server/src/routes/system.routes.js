import { Router } from 'express';
import { SystemController } from '../controllers/system.controller.js';

export const systemRouter = Router();

systemRouter.get('/health', SystemController.health);
systemRouter.get('/meta', SystemController.meta);
