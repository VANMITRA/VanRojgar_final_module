import { Router } from 'express';
import { MessageController } from '../controllers/message.controller.js';
import { authenticate } from '../middleware/authenticate.js';

export const messageRouter = Router();

messageRouter.get('/', authenticate, MessageController.getMessages);
messageRouter.get('/unread-count', authenticate, MessageController.getUnreadCount);
messageRouter.post('/read', authenticate, MessageController.markAsRead);
